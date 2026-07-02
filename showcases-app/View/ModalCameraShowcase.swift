import IMGLYCamera
import IMGLYEditor
import SwiftUI

struct ModalCameraShowcase: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey?
  let mode: CameraMode
  let config: CameraConfiguration

  init(
    title: LocalizedStringKey,
    subtitle: LocalizedStringKey?,
    mode: CameraMode,
    config: CameraConfiguration = CameraConfiguration(allowModeSwitching: false),
  ) {
    self.title = title
    self.subtitle = subtitle
    self.mode = mode
    self.config = config
  }

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
        config: config,
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
        editor(for: result.result)
      }
    }
  }

  @ViewBuilder
  private func editor(for cameraResult: CameraResult) -> some View {
    if cameraResult.isPhotoOnlyCapture {
      Editor(settings)
        .imgly.configuration {
          PhotoEditorConfiguration { builder in
            builder.onCreate { engine, _ in
              try await engine.createScene(from: cameraResult)
              try await PhotoEditorConfiguration.defaultLoadAssetSources(engine)
            }
          }
          ShowcasesEditorConfiguration()
        }
    } else {
      Editor(settings)
        .imgly.configuration {
          VideoEditorConfiguration { builder in
            builder.onCreate { engine, _ in
              try await engine.createScene(from: cameraResult)
              try await VideoEditorConfiguration.defaultLoadAssetSources(engine)
            }
          }
          ShowcasesEditorConfiguration()
        }
    }
  }
}

private extension CameraResult {
  var isPhotoOnlyCapture: Bool {
    guard case let .capture(captures) = self, !captures.isEmpty else { return false }
    return captures.allSatisfy {
      if case .photo = $0 { return true }
      return false
    }
  }
}
