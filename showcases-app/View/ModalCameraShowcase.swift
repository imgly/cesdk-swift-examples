import IMGLYCamera
import IMGLYEditor
import SwiftUI

struct ModalCameraShowcase: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey?
  let mode: CameraMode

  struct CameraResultWrapper: Identifiable {
    let id = UUID()
    let result: CameraResult
  }

  @ViewBuilder private var label: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
      if let subtitle {
        Text(subtitle).font(.footnote)
      }
    }
  }

  @State private var isCameraPresented = false
  @State var result: CameraResultWrapper?

  var body: some View {
    Button {
      isCameraPresented = true
    } label: {
      label
    }
    .fullScreenCover(isPresented: $isCameraPresented) {
      Camera(
        settings,
        config: CameraConfiguration(allowModeSwitching: false),
        mode: mode,
      ) { result in
        switch result {
        case let .failure(error) where error == .cancelled:
          isCameraPresented = false

        case let .failure(error):
          print(error.localizedDescription)
          isCameraPresented = false

        case let .success(result):
          self.result = CameraResultWrapper(result: result)
          isCameraPresented = false
        }
      }
    }
    .fullScreenCover(item: $result) { result in
      ModalEditor {
        Editor(settings)
          .imgly.configuration {
            VideoEditorConfiguration { builder in
              builder.onCreate { engine, _ in
                try await engine.createScene(from: result.result)
                try await VideoEditorConfiguration.defaultLoadAssetSources(engine)
              }
            }
            ShowcasesEditorConfiguration()
          }
      }
    }
  }
}
