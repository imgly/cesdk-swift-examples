import IMGLYEditor
import IMGLYEngine
import SwiftUI

// highlight-refreshAssets-source
/// One record in a simulated external store (a CMS, cloud storage, or upload
/// service).
struct CloudImage {
  let id: String
  let fileName: String
  let name: String
  let width: String
  let height: String
}

/// The external store, standing in for a backend whose contents change while
/// the app runs. Modeled as an `actor` because the asset source reads it from a
/// background task while the UI mutates it from the main actor. Here it simply
/// publishes more of a fixed catalog on demand; a real store would talk to a
/// server.
actor CloudImageStore {
  private let catalog: [CloudImage]
  private var publishedCount = 1

  init(catalog: [CloudImage]) {
    self.catalog = catalog
  }

  /// The images the store currently serves.
  var publishedImages: [CloudImage] {
    Array(catalog.prefix(publishedCount))
  }

  /// Publishes one more image from the catalog. Returns `true` if the published
  /// set actually changed.
  func publishNextImage() -> Bool {
    guard publishedCount < catalog.count else { return false }
    publishedCount += 1
    return true
  }

  /// Resets the store to its initial single image. Returns `true` if anything
  /// changed.
  func reset() -> Bool {
    guard publishedCount > 1 else { return false }
    publishedCount = 1
    return true
  }
}

/// A custom asset source that serves the store's images. The asset library
/// calls `findAssets` whenever it queries the source, so it always reflects the
/// store's current contents.
final class CloudImageAssetSource: NSObject, AssetSource {
  static let sourceID = "cloud-images"

  private let store: CloudImageStore
  private let baseURL: String

  init(store: CloudImageStore, baseURL: String) {
    self.store = store
    self.baseURL = baseURL
    super.init()
  }

  var id: String {
    Self.sourceID
  }

  var supportedMIMETypes: [String]? {
    ["image/jpeg"]
  }

  var credits: AssetCredits? {
    nil
  }

  var license: AssetLicense? {
    nil
  }

  func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    let needle = queryData.query?.lowercased()
    let matches = await store.publishedImages.filter { image in
      guard let needle, !needle.isEmpty else { return true }
      return image.name.lowercased().contains(needle)
    }

    let assets = matches.map { image in
      AssetResult(
        id: image.id,
        label: image.name,
        meta: [
          "uri": "\(baseURL)/ly.img.image/images/\(image.fileName)",
          "thumbUri": "\(baseURL)/ly.img.image/thumbnails/\(image.fileName)",
          // `fillType` makes the inserted block an image fill (the engine would
          // otherwise default to a solid color); `width`/`height` set the aspect
          // ratio before the image finishes loading.
          "fillType": "//ly.img.ubq/fill/image",
          "width": image.width,
          "height": image.height,
        ],
        context: .init(sourceID: id),
      )
    }

    return AssetQueryResult(assets: assets, currentPage: queryData.page, total: assets.count)
  }
}

// highlight-refreshAssets-source

/// Editor demonstrating how the asset library stays in sync with a custom
/// source: navigation-bar buttons change the external store at runtime and the
/// open library refreshes to match.
struct RefreshAssetsSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
    baseURL: secrets.baseURL, // read back below via getSettingString("basePath")
  )

  /// The external store, owned by the view so the navigation-bar buttons and
  /// the registered source share the same instance.
  @State private var store = CloudImageStore(catalog: [
    CloudImage(id: "cloud-1", fileName: "sample_1.jpg", name: "Mountain Landscape", width: "2500", height: "1667"),
    CloudImage(id: "cloud-2", fileName: "sample_2.jpg", name: "Ocean Sunset", width: "2500", height: "1667"),
    CloudImage(id: "cloud-3", fileName: "sample_3.jpg", name: "Forest Path", width: "1667", height: "2500"),
    CloudImage(id: "cloud-4", fileName: "sample_4.jpg", name: "City Skyline", width: "1667", height: "2500"),
  ])

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            // GuideEditorConfiguration ships no scene, so build the page the
            // editor renders on before registering the source.
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            // highlight-refreshAssets-register
            // Wrap the store in an asset source and register it. The source's
            // image URLs resolve against the engine's `basePath`
            // setting—initialized from `EngineSettings(baseURL:)`.
            let source = CloudImageAssetSource(
              store: store,
              baseURL: try engine.editor.getSettingString("basePath"),
            )
            try engine.asset.addSource(source)
            // highlight-refreshAssets-register
          }
          // highlight-refreshAssets-refresh
          builder.navigationBar { navigationBar in
            navigationBar.modify { _, items in
              items.addLast(placement: .topBarLeading) {
                // Publishes another image to the store, then tells the engine
                // the source changed. The editor forwards that to the open
                // library, which re-queries and shows the new image right away.
                NavigationBar.Button(id: "ly.img.guide.navigationBar.button.addCloudImage") { context in
                  let engine = context.engine
                  Task {
                    guard await store.publishNextImage(), let engine else { return }
                    try? engine.asset.assetSourceContentsChanged(sourceID: CloudImageAssetSource.sourceID)
                  }
                } label: { _ in
                  Label("Add Image", systemImage: "plus.circle")
                }
                // Resets the store to its single starting image and refreshes.
                NavigationBar.Button(id: "ly.img.guide.navigationBar.button.resetCloudImages") { context in
                  let engine = context.engine
                  Task {
                    guard await store.reset(), let engine else { return }
                    try? engine.asset.assetSourceContentsChanged(sourceID: CloudImageAssetSource.sourceID)
                  }
                } label: { _ in
                  Label("Reset", systemImage: "arrow.counterclockwise")
                }
              }
            }
          }
          // highlight-refreshAssets-refresh
          // highlight-refreshAssets-library
          builder.assetLibrary { assetLibrary in
            assetLibrary.categories([
              .init(
                id: AssetLibraryCategory.ID.images,
                title: .imgly.localized("ly_img_editor_asset_library_title_images"),
                icon: Image(systemName: "photo"),
                sections: [
                  .image(id: "cloud-images", title: "Cloud Images", source: .init(id: CloudImageAssetSource.sourceID)),
                ],
              ),
            ])
          }
          // highlight-refreshAssets-library
          // highlight-refreshAssets-dock
          builder.dock { dock in
            dock.items { _ in
              // Open the images library at a medium detent so the navigation
              // bar stays visible and tappable while the library is open.
              Dock.Buttons.imagesLibrary(action: { context in
                context.eventHandler.send(.openSheet(type: .libraryAdd(style: .addAsset(detent: .imgly.medium)) {
                  context.assetLibrary.imagesTab
                }))
              })
            }
          }
          // highlight-refreshAssets-dock
        }
      }
  }

  @State private var isPresented = false

  var body: some View {
    Button("Use the Editor") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        editor
      }
    }
  }
}

#Preview {
  RefreshAssetsSolution()
}
