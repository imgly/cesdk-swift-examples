import IMGLYDesignEditor
import SwiftUI

struct CustomAssetLibraryEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  @MainActor
  var editor: some View {
    // highlight-editor
    DesignEditor(settings)
      // highlight-assetSource
      .imgly.onCreate { engine in
        try await OnCreate.loadScene(from: DesignEditor.defaultScene)(engine)
        try engine.asset.addSource(UnsplashAssetSource(host: secrets.unsplashHost))
      }
      // highlight-assetSource
      // highlight-assetLibrary
      .imgly.assetLibrary {
        CustomAssetLibrary()
      }
    // highlight-assetLibrary
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
