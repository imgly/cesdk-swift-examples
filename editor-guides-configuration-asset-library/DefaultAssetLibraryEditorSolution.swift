import IMGLYDesignEditor
import SwiftUI

struct DefaultAssetLibraryEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  @MainActor
  var editor: some View {
    // highlight-editor-default
    DesignEditor(settings)
      // highlight-assetSource-default
      .imgly.onCreate { engine in
        try await OnCreate.loadScene(from: DesignEditor.defaultScene)(engine)
        try engine.asset.addSource(UnsplashAssetSource(host: secrets.unsplashHost))
      }
      // highlight-assetSource-default
      // highlight-assetLibrary-default
      .imgly.assetLibrary {
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
    // highlight-assetLibrary-default
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
