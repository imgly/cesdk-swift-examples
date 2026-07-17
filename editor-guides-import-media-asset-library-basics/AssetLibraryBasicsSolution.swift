import IMGLYEditor
import IMGLYEngine
import SwiftUI

struct AssetLibraryBasicsSolution: View {
  var settings: EngineSettings {
    EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>",
                   baseURL: secrets.baseURL) // pass nil for evaluation with the IMG.LY CDN
  }

  /// The lesson shown in the guide and the view the showcase presents.
  ///
  /// All three asset-library layers are configured on the same
  /// `GuideEditorConfiguration` builder: the engine source in `onCreate`, the
  /// asset library definition in `assetLibrary`, and the dock entry in `dock`.
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

            // highlight-assetLibraryBasics-source
            let sourceID = "brand-images"
            try engine.asset.addLocalSource(sourceID: sourceID)

            // Borrow a few images from CE.SDK's bundled `ly.img.image` content,
            // resolving them against the engine's `basePath` setting (initialized
            // from `EngineSettings.baseURL`) so they follow your asset host. You
            // could register a whole source from a manifest with
            // `addLocalAssetSourceFromJSON`; the assets are added one by one here
            // to keep the mechanics explicit.
            let basePath = try engine.editor.getSettingString("basePath")
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
                    // `fillType` makes the inserted block an image fill (the engine
                    // would otherwise default to a solid color); `width`/`height`
                    // set the aspect ratio before the image finishes loading.
                    "fillType": "//ly.img.ubq/fill/image",
                    "width": image.width,
                    "height": image.height,
                  ],
                  label: ["en": image.label],
                ),
              )
            }
            // highlight-assetLibraryBasics-source

            // highlight-assetLibraryBasics-manage
            let registeredSources = engine.asset.findAllSources()
            print("Registered asset sources:", registeredSources)
            // highlight-assetLibraryBasics-manage
          }
          // highlight-assetLibraryBasics-library
          builder.assetLibrary { assetLibrary in
            assetLibrary.categories([
              .init(
                id: AssetLibraryCategory.ID.images,
                title: .imgly.localized("ly_img_editor_asset_library_title_images"),
                icon: Image(systemName: "photo"),
                sections: [
                  .image(id: "brand-images", title: "Brand Images", source: .init(id: "brand-images")),
                ],
              ),
            ])
          }
          // highlight-assetLibraryBasics-library
          // highlight-assetLibraryBasics-dock
          builder.dock { dock in
            dock.items { _ in
              // `imagesLibrary()` needs no arguments; its default action is written
              // out here to show how the dock reaches the UI. Tapping it sends an
              // `openSheet` event whose content is `context.assetLibrary.imagesTab` —
              // the images tab of the library from Layer 2 — surfacing "Brand Images".
              Dock.Buttons.imagesLibrary(action: { context in
                context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.imagesTab }))
              })
            }
          }
          // highlight-assetLibraryBasics-dock
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
  AssetLibraryBasicsSolution()
}
