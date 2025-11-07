// highlight-import
import IMGLYVideoEditor

// highlight-import
import SwiftUI

struct VideoEditorSolution: View {
  // highlight-editor
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    VideoEditor(settings)
  }

  // highlight-editor

  // highlight-modal
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
  // highlight-modal
}

#Preview {
  VideoEditorSolution()
}
