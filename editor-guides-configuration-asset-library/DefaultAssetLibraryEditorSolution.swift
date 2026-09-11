import IMGLYEditor
import SwiftUI

struct DefaultAssetLibraryEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor-default
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          // highlight-assetSource-default
          builder.onCreate { engine, _ in
            try await DesignEditorConfiguration.defaultOnCreate(createScene: { engine in
              let sceneURL = Bundle.main.url(forResource: "design-ui-empty", withExtension: "scene")!
              try await engine.scene.load(from: sceneURL)
              try engine.asset.addSource(UnsplashAssetSource(host: secrets.unsplashHost))
            })(engine)
          }
          // highlight-assetSource-default
          // highlight-assetLibrary-default
          builder.assetLibrary { assetLibrary in
            assetLibrary.view { _ in
              // highlight-defaultAssetLibrary
              DefaultAssetLibrary(
                tabs: DefaultAssetLibrary.Tab.allCases.reversed().filter { tab in
                  tab != .elements && tab != .photoRoll
                },
              )
              // highlight-defaultAssetLibrary
              // highlight-defaultAssetLibraryImages
              .images {
                AssetLibrarySource.image(.title("Unsplash"), source: .init(id: UnsplashAssetSource.id))
                DefaultAssetLibrary.images
              }
              // highlight-defaultAssetLibraryImages
            }
          }
          // highlight-assetLibrary-default
        }
      }
    // highlight-editor-default
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
  DefaultAssetLibraryEditorSolution()
}
