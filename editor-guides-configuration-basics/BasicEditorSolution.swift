import IMGLYEditor
import SwiftUI

struct BasicEditorSolution: View {
  let settings = EngineSettings(
    // highlight-configurationBasics-license
    license: secrets.licenseKey,
    // highlight-configurationBasics-license
    // highlight-configurationBasics-userID
    userID: "<your unique user id>",
    // highlight-configurationBasics-userID
    // highlight-configurationBasics-baseURL
    baseURL: URL(string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.77.0-rc.1/assets")!,
    // highlight-configurationBasics-baseURL
  )

  var editor: some View {
    // highlight-configurationBasics-editor
    Editor(settings)
      .imgly.configuration { GuideEditorConfiguration() }
    // highlight-configurationBasics-editor
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
