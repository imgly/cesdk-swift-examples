import IMGLYCamera
import SwiftUI

struct RecordingsCameraSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  @State private var isPresented = false

  var body: some View {
    Button("Use the Camera") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      Camera(settings) { result in
        switch result {
        // highlight-success
        case let .success(recordings):
          for recording in recordings {
            print(recording.duration)
            for video in recording.videos {
              print(video.url)
              print(video.rect)
            }
          }
        // highlight-success
        // highlight-failure
        case let .failure(error):
          print(error.localizedDescription)
          isPresented = false
        }
        // highlight-failure
      }
    }
  }
}
