import IMGLYDesignEditor
import SwiftUI

struct ThemingEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  @Environment(\.colorScheme) private var colorScheme

  var editor: some View {
    // highlight-editor
    DesignEditor(settings)
      // highlight-theme
      .preferredColorScheme(colorScheme == .dark ? .light : .dark)
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
  ThemingEditorSolution()
}
