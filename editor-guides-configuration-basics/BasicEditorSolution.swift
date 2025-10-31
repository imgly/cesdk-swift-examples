import IMGLYDesignEditor
import SwiftUI

struct BasicEditorSolution: View {
  let settings = EngineSettings(
    // highlight-license
    license: secrets.licenseKey,
    // highlight-userID
    userID: "<your unique user id>",
    // highlight-baseURL
    baseURL: URL(string: "https://cdn.img.ly/packages/imgly/cesdk-engine/1.63.0-rc.3/assets")!,
  )

  var editor: some View {
    // highlight-editor
    DesignEditor(settings)
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
  BasicEditorSolution()
}
