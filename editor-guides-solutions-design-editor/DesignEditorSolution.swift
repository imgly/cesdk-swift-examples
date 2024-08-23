// highlight-import
import IMGLYDesignEditor

// highlight-import
import SwiftUI

struct DesignEditorSolution: View {
  // highlight-editor
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    DesignEditor(settings)
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
