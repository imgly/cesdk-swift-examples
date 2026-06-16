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
      Camera(.init(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>")) { result in
        // highlight-initialization
        // highlight-result
        switch result {
        case let .success(.capture(captures)):
          // Do something with the captured photos and videos
          let recordedVideos = captures.videos.flatMap { $0.videos.map(\.url) }
          print(recordedVideos)
          print(captures)

        case .success(.reaction):
          print("Reaction case not handled here")

        case let .failure(error):
          print(error.localizedDescription)
          isPresented = false
        }
        // highlight-result
      }
    }
  }
}
