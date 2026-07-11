import IMGLYCamera
import SwiftUI

struct ReactionCameraSolution: View {
  // The video the user reacts to. In a real app your content supplies this URL.
  private let baseVideoURL = URL(string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.77.0" +
    "/assets/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4")!

  @State private var isPresented = false
  @State private var baseVideo: Recording?
  @State private var reactionClips: [Recording] = []
  @State private var reactionClipURLs: [URL] = []

  var body: some View {
    // highlight-recordReaction-launch
    Button("Record a Reaction") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      Camera(
        .init(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
              userID: "<your unique user id>"),
        mode: .reaction(.vertical, video: baseVideoURL, positionsSwapped: false),
      ) { result in
        // highlight-recordReaction-launch
        // highlight-recordReaction-result
        switch result {
        case let .success(.reaction(video: base, reaction: clips)):
          baseVideo = base
          reactionClips = clips
          reactionClipURLs = clips.compactMap { $0.videos.first?.url }
        case .success(.capture):
          break
        case .failure(.cancelled):
          break // The user closed the camera without recording.
        case .failure(.failedToLoadVideo):
          print("The base video could not be loaded.")
        case let .failure(error):
          print(error.localizedDescription)
        }
        isPresented = false
        // highlight-recordReaction-result
      }
    }
  }
}
