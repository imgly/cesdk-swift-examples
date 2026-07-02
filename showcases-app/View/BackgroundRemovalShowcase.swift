import IMGLYEditor
import IMGLYEngine
import IMGLYPluginBackgroundRemoval
import SwiftUI

struct BackgroundRemovalShowcase: View {
  let url: URL

  @State private var errorMessage: String?

  var body: some View {
    Editor(settings)
      .imgly.configuration {
        PhotoEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await PhotoEditorConfiguration.defaultOnCreate(
              createScene: { engine in
                try await engine.scene.create(fromImage: url)
              },
            )(engine)
          }
        }
        BackgroundRemovalPlugin(onError: { error in
          errorMessage = error.localizedDescription
        })
      }
      .alert("Background Removal Error", isPresented: .constant(errorMessage != nil)) {
        Button("OK") {
          errorMessage = nil
        }
      } message: {
        Text(errorMessage ?? "An unexpected error occurred")
      }
  }
}
