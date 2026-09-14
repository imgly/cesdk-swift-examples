import IMGLYCamera
import SwiftUI

struct ConfiguredCameraSolution: View {
  // highlight-editor
  // highlight-license
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                // highlight-userID
                                userID: "<your unique user id>")
  // highlight-editor

  @State private var isPresented = false

  var body: some View {
    Button("Open the Camera") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      // highlight-config
      let config = CameraConfiguration(
        // highlight-recordingcolor
        recordingColor: .blue,
        // highlight-highlightcolor
        highlightColor: .yellow,
        // highlight-maxtotalduration
        maxTotalDuration: 30,
        // highlight-allowmodeswitching
        allowModeSwitching: true,
      )
      // highlight-config

      Camera(
        settings,
        config: config,
        // highlight-mode
        mode: .standard,
      ) { result in
        switch result {
        case let .success(cameraResult):
          print(cameraResult)
        case let .failure(error):
          print(error.localizedDescription)
          isPresented = false
        }
      }
    }
  }
}
