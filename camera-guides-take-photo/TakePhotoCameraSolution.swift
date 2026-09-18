import IMGLYCamera
import SwiftUI

struct TakePhotoCameraSolution: View {
  @State private var isPresented = false
  @State private var capturedPhotoURLs: [URL] = []

  var body: some View {
    // highlight-takePhoto-present
    Button("Take a Photo") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      Camera(
        .init(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
              userID: "<your unique user id>"),
        config: CameraConfiguration(captureType: .photo, captureCount: .single),
      ) { result in
        // highlight-takePhoto-present
        // highlight-takePhoto-result
        switch result {
        case let .success(.capture(captures)):
          // Each photo capture carries one or more still images; hand the URLs off to your app.
          capturedPhotoURLs = captures.compactMap { capture in
            if case let .photo(photo) = capture {
              return photo.images.first?.url
            }
            return nil
          }
        case .success(.reaction):
          break
        case let .failure(error):
          print(error.localizedDescription)
        }
        isPresented = false
        // highlight-takePhoto-result
      }
    }
  }
}
