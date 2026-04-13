import IMGLYEditor
import SwiftUI

struct CustomAssetLibraryEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor-custom
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          // highlight-assetSource-custom
          builder.onCreate { engine, _ in
            try await DesignEditorConfiguration.defaultOnCreate(createScene: { engine in
              let sceneURL = Bundle.main.url(forResource: "design-ui-empty", withExtension: "scene")!
              try await engine.scene.load(from: sceneURL)
              try engine.asset.addSource(UnsplashAssetSource(host: secrets.unsplashHost))
            })(engine)
          }
          // highlight-assetSource-custom
          // highlight-assetLibrary-custom
          builder.assetLibrary { assetLibrary in
            assetLibrary.view { _ in
              CustomAssetLibrary()
            }
          }
          // highlight-assetLibrary-custom
        }
      }
    // highlight-editor-custom
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
  CustomAssetLibraryEditorSolution()
}
