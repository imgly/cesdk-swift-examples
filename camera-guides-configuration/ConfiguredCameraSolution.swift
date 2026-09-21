import IMGLYCamera
import SwiftUI

struct ConfiguredCameraSolution: View {
  // highlight-cameraConfiguration-engineSettings
  let settings = EngineSettings(
    // highlight-cameraConfiguration-license
    license: secrets.licenseKey,
    // highlight-cameraConfiguration-license
    // highlight-cameraConfiguration-userID
    userID: "<your unique user id>",
    // highlight-cameraConfiguration-userID
  )
  // highlight-cameraConfiguration-engineSettings

  @State private var isRecordingVideo = false
  @State private var isTakingPhotos = false

  var body: some View {
    VStack(spacing: 16) {
      Button("Record Video") {
        isRecordingVideo = true
      }
      .fullScreenCover(isPresented: $isRecordingVideo) {
        // highlight-cameraConfiguration-config
        let config = CameraConfiguration(
          // highlight-cameraConfiguration-recordingColor
          recordingColor: .green,
          // highlight-cameraConfiguration-recordingColor
          // highlight-cameraConfiguration-highlightColor
          highlightColor: .purple,
          // highlight-cameraConfiguration-highlightColor
          // highlight-cameraConfiguration-maxTotalDuration
          maxTotalDuration: 10,
          // highlight-cameraConfiguration-maxTotalDuration
          // highlight-cameraConfiguration-allowExceedingMaxDuration
          allowExceedingMaxDuration: false,
          // highlight-cameraConfiguration-allowExceedingMaxDuration
          // highlight-cameraConfiguration-allowModeSwitching
          allowModeSwitching: false,
          // highlight-cameraConfiguration-allowModeSwitching
        )
        // highlight-cameraConfiguration-config

        Camera(
          settings,
          config: config,
          // highlight-cameraConfiguration-mode
          mode: .standard,
          // highlight-cameraConfiguration-mode
        ) { result in
          handle(result) { isRecordingVideo = false }
        }
      }

      Button("Take Photos") {
        isTakingPhotos = true
      }
      .fullScreenCover(isPresented: $isTakingPhotos) {
        // highlight-cameraConfiguration-captureType
        let photoConfig = CameraConfiguration(
          captureType: .photo,
          captureCount: .single,
          photoClipDuration: 5,
          showsPhotoPreview: true,
        )
        // highlight-cameraConfiguration-captureType

        Camera(settings, config: photoConfig) { result in
          handle(result) { isTakingPhotos = false }
        }
      }
    }
  }

  // highlight-cameraConfiguration-result
  private func handle(
    _ result: Result<CameraResult, CameraError>,
    onDismiss: () -> Void,
  ) {
    switch result {
    case let .success(.capture(captures)):
      print(captures)
    case let .success(.reaction(video, reaction)):
      print(video, reaction)
    case let .failure(error):
      print(error.localizedDescription)
    }
    // The camera doesn't dismiss itself, so close the cover for every outcome.
    onDismiss()
  }
  // highlight-cameraConfiguration-result
}
