// highlight-import
import IMGLYDesignEditor

// highlight-import
import SwiftUI

struct EditorSwiftUI: View {
  @State private var isPresented = false

  var body: some View {
    // highlight-modal
    Button("Use the Editor") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      // highlight-environment
      ModalEditor {
        // highlight-editor
        DesignEditor(.init(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                           userID: "<your unique user id>"))
        // highlight-editor
      }
      // highlight-environment
    }
    // highlight-modal
  }
}

#Preview {
  EditorSwiftUI()
}
