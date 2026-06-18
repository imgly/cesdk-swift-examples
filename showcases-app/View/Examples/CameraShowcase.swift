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
          case let .failure(error) where error == .cancelled:
            isCameraSheetShown = false

          case let .failure(error):
            print(error.localizedDescription)
            isCameraSheetShown = false

          case let .success(.capture(captures)):
            let urls = captures.videos.flatMap { $0.videos.map(\.url) }
            shareItem = .url(urls)

          case .success(.reaction):
            print("Reaction case not handled here")
          }
        }
        .imgly.shareSheet(item: $shareItem) {
          isCameraSheetShown = false
        }
      }
  }
}
