// highlight-import
import IMGLYCamera
// highlight-import
import SwiftUI

struct CameraSwiftUI: View {
  @State private var isPresented = false

  var body: some View {
    // highlight-modal
    Button("Use the Camera") {
      isPresented = true
    }
    // highlight-modal

    // highlight-fullscreencover
    .fullScreenCover(isPresented: $isPresented) {
      // highlight-fullscreencover
      // highlight-initialization
      Camera(.init(license: secrets.licenseKey,
                   userID: "<your unique user id>")) { result in
        // highlight-initialization
        // highlight-result
        switch result {
        case let .success(recordings):
          let urls = recordings.flatMap { $0.videos.map(\.url) }
          let recordedVideos = urls
          // Do something with the recorded videos
          print(recordedVideos)
        case let .failure(error):
          print(error.localizedDescription)
          isPresented = false
        }
        // highlight-result
      }
    }
  }
}
