// highlight-import
import IMGLYCamera

// highlight-import
import SwiftUI

struct CameraSwiftUI: View {
  // highlight-present
  @State private var isPresented = false

  var body: some View {
    Button("Use the Camera") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      // highlight-initialization
      Camera(.init(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>")) { result in
        // highlight-initialization
        // highlight-present
        // highlight-result
        switch result {
        case let .success(.capture(captures)):
          for capture in captures {
            switch capture {
            case let .photo(photo):
              if let url = photo.images.first?.url {
                print("Captured photo: \(url)")
              }
            case let .video(recording):
              print("Recorded videos: \(recording.videos.map(\.url))")
            }
          }

        case .success(.reaction):
          print("Reaction case not handled here")

        case let .failure(error):
          print(error.localizedDescription)
        }
        isPresented = false
      }
    }
  }
  // highlight-result
}
