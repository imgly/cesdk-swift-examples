import IMGLYCamera
@_spi(Internal) import IMGLYEditor
import SwiftUI

struct CameraShowcase: ViewModifier {
  @Binding var isCameraSheetShown: Bool
  @State private var shareItem: ShareItem?

  func body(content: Content) -> some View {
    content
      .fullScreenCover(isPresented: $isCameraSheetShown) {
        Camera(settings) { result in
          switch result {
          case let .success(recordings):
            let urls = recordings.flatMap { $0.videos.map(\.url) }
            let recordedVideos = urls
            shareItem = .url(recordedVideos)
          case let .failure(error):
            print(error.localizedDescription)
            isCameraSheetShown = false
          }
        }
        .imgly.shareSheet(item: $shareItem) {
          isCameraSheetShown = false
        }
      }
  }
}
