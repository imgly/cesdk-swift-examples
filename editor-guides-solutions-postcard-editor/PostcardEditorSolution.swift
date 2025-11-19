// highlight-import
import IMGLYPostcardEditor

// highlight-import
import SwiftUI

struct PostcardEditorSolution: View {
  // highlight-editor
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    PostcardEditor(settings)
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
  PostcardEditorSolution()
}
