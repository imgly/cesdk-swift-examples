import IMGLYDesignEditor
import SwiftUI

private enum CallbackError: Error {
  case noScene
}

struct ColorPaletteEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  @Environment(\.colorScheme) private var colorScheme

  var editor: some View {
    // highlight-editor
    DesignEditor(settings)
      // highlight-colorPalette
      .imgly.colorPalette([
        .init("Blue", .imgly.blue),
        .init("Green", .imgly.green),
        .init("Yellow", .imgly.yellow),
        .init("Red", .imgly.red),
        .init("Black", .imgly.black),
        .init("White", .imgly.white),
        .init("Gray", .imgly.gray)
      ])
    // highlight-colorPalette
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
