import IMGLYEditor
import IMGLYEngine
import SwiftUI

struct UserUploadSolution: View {
  var settings: EngineSettings {
    EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>",
                   baseURL: secrets.baseURL) // read back below via getSettingString("basePath")
  }

  /// The ID of the local source that accepts image uploads.
  static let uploadSourceID = "my-image-uploads"

  /// The lesson shown in the guide and the view the showcase presents.
  ///
  /// The upload source is registered on the engine in `onCreate`, surfaced in the
  /// asset library with an `.imageUpload` section, reached through an images dock
  /// button, and post-processed in `onUpload` — all on the same
  /// `GuideEditorConfiguration` builder.
  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            // GuideEditorConfiguration ships no scene, so build the page the
            // editor renders on. The default OnCreate would do this, but the
            // source registration below needs to run in the same callback.
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            // highlight-userUpload-registerSource
            // Register a local source for image uploads. These are the image
            // formats CE.SDK renders on iOS, matching the SDK's built-in image
            // upload source. (The photo picker delivers HEIC/HEIF photos as
            // JPEG, so they need no entry here.)
            try engine.asset.addLocalSource(
              sourceID: Self.uploadSourceID,
              supportedMimeTypes: [
                "image/jpeg", "image/png", "image/svg+xml",
                "image/gif", "image/apng", "image/bmp",
              ],
            )
            // highlight-userUpload-registerSource

            // Seed a couple of assets so the library shows content alongside the
            // "+ Add" button. In a real app you populate this from your own
            // storage on launch (see "Persist Uploaded Assets").
            let basePath = try engine.editor.getSettingString("basePath")
            for (index, fileName) in ["sample_1.jpg", "sample_2.jpg"].enumerated() {
              try engine.asset.addAsset(
                to: Self.uploadSourceID,
                asset: AssetDefinition(
                  id: "seed-\(index)",
                  meta: [
                    "uri": "\(basePath)/ly.img.image/images/\(fileName)",
                    "thumbUri": "\(basePath)/ly.img.image/thumbnails/\(fileName)",
                    "fillType": "//ly.img.ubq/fill/image",
                    "width": "2500",
                    "height": "1667",
                  ],
                  label: ["en": "Upload \(index + 1)"],
                ),
              )
            }
          }
          // highlight-userUpload-library
          // Surface the upload source in the Images tab. `.imageUpload` renders
          // the "+ Add" button that opens the system picker, camera, or Files.
          builder.assetLibrary { assetLibrary in
            assetLibrary.categories([
              .init(
                id: AssetLibraryCategory.ID.images,
                title: .imgly.localized("ly_img_editor_asset_library_title_images"),
                icon: Image(systemName: "photo"),
                sections: [
                  .imageUpload(
                    id: "my-uploads-section",
                    title: "My Uploads",
                    source: .init(id: Self.uploadSourceID),
                  ),
                ],
              ),
            ])
          }
          // highlight-userUpload-library
          // highlight-userUpload-dock
          // Add the images dock button so users can open the library.
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.imagesLibrary()
            }
          }
          // highlight-userUpload-dock
          // highlight-userUpload-onUpload
          builder.onUpload { _, sourceID, asset, existing in
            var meta = asset.meta ?? [:]
            if let persistedURI = try persistUpload(asset.meta?["uri"], sourceID: sourceID) {
              meta["uri"] = persistedURI
              // Persist the thumbnail too. Reuse the copy when it points at the same
              // file as the media; otherwise copy it separately so the library keeps a
              // light preview instead of decoding the full-size image.
              if asset.meta?["thumbUri"] == asset.meta?["uri"] {
                meta["thumbUri"] = persistedURI
              } else if let persistedThumb = try persistUpload(asset.meta?["thumbUri"], sourceID: sourceID) {
                meta["thumbUri"] = persistedThumb
              }
            }
            let updated = AssetDefinition(
              id: asset.id,
              groups: asset.groups,
              meta: meta,
              payload: asset.payload,
              label: asset.label,
              tags: ["en": ["upload"]],
            )
            return try await existing(updated)
          }
          // highlight-userUpload-onUpload
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

// highlight-userUpload-persist
/// Copies a local file out of temporary storage into the app's Documents directory
/// so it survives across launches, returning the new file URL string. Returns `nil`
/// for anything that isn't a local file — an already-remote asset needs no copy.
private func persistUpload(_ uri: String?, sourceID: String) throws -> String? {
  guard let uri, let sourceURL = URL(string: uri), sourceURL.isFileURL else { return nil }

  let uploadsDirectory = try FileManager.default
    .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    .appendingPathComponent("cesdk-uploads/\(sourceID)", isDirectory: true)
  try FileManager.default.createDirectory(at: uploadsDirectory, withIntermediateDirectories: true)

  let fileExtension = sourceURL.pathExtension.isEmpty ? "jpg" : sourceURL.pathExtension
  let destination = uploadsDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension(fileExtension)
  try FileManager.default.copyItem(at: sourceURL, to: destination)
  return destination.absoluteString
}

// highlight-userUpload-persist

#Preview {
  UserUploadSolution()
}
