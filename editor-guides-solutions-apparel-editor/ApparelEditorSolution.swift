// highlight-import
import IMGLYApparelEditor

// highlight-import
import SwiftUI

struct ApparelEditorSolution: View {
  // highlight-editor
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    ApparelEditor(settings)
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
  ApparelEditorSolution()
}
