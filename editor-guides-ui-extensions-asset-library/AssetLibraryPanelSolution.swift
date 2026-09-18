import IMGLYEditor
import IMGLYEngine
import SwiftUI

struct AssetLibraryPanelSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  private static let brandSourceID = "my-brand-assets"
  private static let uploadSourceID = "my-uploads"

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            let basePath = try engine.editor.getSettingString("basePath")

            // highlight-assetPanel-registerSource
            try engine.asset.addLocalSource(sourceID: Self.brandSourceID)
            for index in 1 ... 6 {
              try engine.asset.addAsset(
                to: Self.brandSourceID,
                asset: AssetDefinition(
                  id: "sample-\(index)",
                  meta: [
                    "uri": "\(basePath)/ly.img.image/images/sample_\(index).jpg",
                    "thumbUri": "\(basePath)/ly.img.image/thumbnails/sample_\(index).jpg",
                    "fillType": "//ly.img.ubq/fill/image",
                  ],
                  label: ["en": "Sample \(index)"],
                ),
              )
            }
            // highlight-assetPanel-registerSource

            // highlight-assetPanel-uploadSource
            try engine.asset.addLocalSource(
              sourceID: Self.uploadSourceID,
              supportedMimeTypes: ["image/png", "image/jpeg"],
            )
            // highlight-assetPanel-uploadSource
          }

          // highlight-assetPanel-addToLibrary
          builder.assetLibrary { assetLibrary in
            assetLibrary.modify { categories in
              // Recompose just the Images tab to show your source. Every other
              // tab the editor provides stays untouched.
              categories.replace(id: AssetLibraryCategory.ID.images, AssetLibraryCategory(
                id: AssetLibraryCategory.ID.images,
                title: "Images",
                icon: Image(systemName: "photo"),
                sections: [
                  .image(id: Self.brandSourceID, title: "Brand Assets", source: .init(id: Self.brandSourceID)),
                ],
              ))
            }
          }

          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.imagesLibrary()
            }
          }
          // highlight-assetPanel-addToLibrary
        }
      }
  }

  // highlight-assetPanel-category
  // A dedicated tab is an alternative to extending the Images tab: build a
  // category and add it in a `modify` block with
  // `categories.addLast(Self.brandLibraryTab())`, leaving the default tabs intact.
  private static func brandLibraryTab() -> AssetLibraryCategory {
    AssetLibraryCategory(
      id: "my-brand-library",
      title: "My Library",
      icon: Image(systemName: "square.grid.2x2"),
      sections: [
        .image(id: brandSourceID, title: "Brand Assets", source: .init(id: brandSourceID)),
        .imageUpload(id: uploadSourceID, title: "Uploads", source: .init(id: uploadSourceID)),
      ],
    )
  }

  // highlight-assetPanel-category

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
  AssetLibraryPanelSolution()
}
