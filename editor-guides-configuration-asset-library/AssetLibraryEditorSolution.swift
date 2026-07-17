import IMGLYEditor
import IMGLYEngine
import SwiftUI

struct AssetLibraryEditorSolution: View {
  // highlight-assetLibrary-configuration
  var settings: EngineSettings {
    EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>",
                   baseURL: secrets.baseURL) // read back below via getSettingString("basePath")
  }

  // highlight-assetLibrary-configuration

  /// The recommended path the guide leads with and the view the showcase presents.
  ///
  /// `assetLibrary.categories([...])` supplies the complete, ordered list of tabs,
  /// mixing a custom category with the editor's predefined categories.
  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await registerSources(engine)
          }
          // highlight-assetLibrary-categories
          builder.assetLibrary { assetLibrary in
            assetLibrary.categories([
              // The Elements meta-category combines every other category below — including
              // the custom one — into a single scrollable tab.
              .defaultElements,
              // highlight-assetLibrary-customCategory
              AssetLibraryCategory(
                id: AssetLibraryCategory.ID.images,
                title: "Images",
                icon: Image(systemName: "photo"),
                sections: [
                  .image(id: "brand-images", title: "Brand Images", source: .init(id: "brand-images")),
                ],
              ),
              // highlight-assetLibrary-customCategory
              .defaultShapes,
              .defaultStickers,
            ])
          }
          // highlight-assetLibrary-categories
          // highlight-assetLibrary-dock
          builder.dock { dock in
            dock.items { _ in
              // The Elements button opens the combined tab, which includes the custom category.
              Dock.Buttons.elementsLibrary()
              // The custom category reuses `AssetLibraryCategory.ID.images`, so the default
              // images button opens it automatically — no custom action needed.
              Dock.Buttons.imagesLibrary()
            }
          }
          // highlight-assetLibrary-dock
        }
      }
  }

  /// The `modify` path: adjust the editor's default categories instead of replacing them.
  ///
  /// Not presented at runtime — it exists so the guide's highlight markers reference
  /// complete, compiled code for the modify section.
  var modifyEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await registerSources(engine)
          }
          // highlight-assetLibrary-modify
          builder.assetLibrary { assetLibrary in
            assetLibrary.modify { categories in
              // Add the custom "Brand Images" section to the top of the images category.
              categories.modifySections(of: AssetLibraryCategory.ID.images) { sections in
                sections.addFirst(.image(
                  id: "brand-images",
                  title: "Brand Images",
                  source: .init(id: "brand-images"),
                ))
              }
              // Drop the device photo roll category.
              categories.remove(id: AssetLibraryCategory.ID.photoRoll)
            }
          }
          // highlight-assetLibrary-modify
        }
      }
  }

  /// The `view` path: replace the library with a fully custom `AssetLibrary` view.
  ///
  /// Not presented at runtime — it exists so the guide's highlight markers reference
  /// complete, compiled code for the custom-view section.
  var viewEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await registerSources(engine)
          }
          // highlight-assetLibrary-view
          builder.assetLibrary { assetLibrary in
            assetLibrary.view { categories in
              // `AssetLibraryView` is the default `AssetLibrary` conformer; return your own
              // type for full control. `categories` carries any `modify` changes already applied.
              AssetLibraryView(categories: categories)
            }
          }
          // highlight-assetLibrary-view
          // highlight-assetLibrary-customButton
          builder.dock { dock in
            dock.items { _ in
              // A custom dock button can open an ad-hoc library sheet whose content is
              // built with the `@AssetLibraryBuilder` DSL — `AssetLibrarySource` rows
              // grouped with `AssetLibraryGroup`. This sheet is independent of the
              // configured `assetLibrary` above.
              Dock.Button(id: "my.app.dock.brandImages") { context in
                context.eventHandler.send(.openSheet(type: .libraryAdd("Brand Images") {
                  AssetLibrarySource.image(.title("Brand Images"), source: .init(id: "brand-images"))
                }))
              } label: { _ in
                Label("Brand Images", systemImage: "photo.stack")
              }
            }
          }
          // highlight-assetLibrary-customButton
        }
      }
  }

  /// Registers the asset sources the categories above reference. The custom "Brand Images"
  /// section is backed by an in-memory source; the predefined categories pull from CE.SDK's
  /// bundled shape and sticker content. See the Asset Library Basics guide for the details
  /// of source registration.
  private func registerSources(_ engine: Engine) async throws {
    let scene = try engine.scene.create()
    let page = try engine.block.create(.page)
    try engine.block.appendChild(to: scene, child: page)
    try engine.block.setWidth(page, value: 1080)
    try engine.block.setHeight(page, value: 1080)

    let basePath = try engine.editor.getSettingString("basePath")

    // The custom category's in-memory source, populated from bundled `ly.img.image` content.
    let sourceID = "brand-images"
    try engine.asset.addLocalSource(sourceID: sourceID)
    let images = [
      (id: "sample-1", label: "Sample 1", fileName: "sample_1.jpg", width: "2500", height: "1667"),
      (id: "sample-2", label: "Sample 2", fileName: "sample_2.jpg", width: "2500", height: "1667"),
      (id: "sample-3", label: "Sample 3", fileName: "sample_3.jpg", width: "1667", height: "2500"),
    ]
    for image in images {
      try engine.asset.addAsset(
        to: sourceID,
        asset: AssetDefinition(
          id: image.id,
          meta: [
            "uri": "\(basePath)/ly.img.image/images/\(image.fileName)",
            "thumbUri": "\(basePath)/ly.img.image/thumbnails/\(image.fileName)",
            "fillType": "//ly.img.ubq/fill/image",
            "width": image.width,
            "height": image.height,
          ],
          label: ["en": image.label],
        ),
      )
    }

    // The predefined `.defaultShapes` / `.defaultStickers` / `.defaultElements` categories
    // reference these bundled sources; register them so their tabs render.
    if let baseURL = URL(string: basePath) {
      for predefinedSource in ["ly.img.vector.shape", "ly.img.sticker"] {
        _ = try await engine.asset.addLocalAssetSourceFromJSON(
          baseURL.appendingPathComponent(predefinedSource).appendingPathComponent("content.json"),
        )
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
  AssetLibraryEditorSolution()
}
