import IMGLYCamera
import SwiftUI

struct RecordingsCameraSolution: View {
  // highlight-recordings-present
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  @State private var isPresented = false
  @State private var persistedVideoURLs: [URL] = []

  var body: some View {
    Button("Use the Camera") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      Camera(settings) { result in
        defer { isPresented = false }
        switch result {
        // highlight-recordings-present
        // highlight-recordings-standard
        case let .success(.capture(captures)):
          for recording in captures.videos {
            print(recording.duration)
            for video in recording.videos {
              print(video.url)
              print(video.rect)
            }
          }
          persistedVideoURLs = captures.videos.flatMap(\.videos).compactMap { video in
            try? persistFile(from: video.url, fileName: video.url.lastPathComponent)
          }
          // highlight-recordings-standard

        // highlight-recordings-reaction
        case let .success(.reaction(video: baseVideo, reaction: reactions)):
          print(baseVideo.duration)
          for recording in reactions {
            print(recording.duration)
            for video in recording.videos {
              print(video.url)
              print(video.rect)
            }
          }
          persistedVideoURLs = reactions.flatMap(\.videos).compactMap { video in
            try? persistFile(from: video.url, fileName: video.url.lastPathComponent)
          }
          // highlight-recordings-reaction

        // highlight-recordings-failure
        case let .failure(error):
          switch error {
          case .cancelled:
            break
          case .permissionsMissing, .failedToLoadVideo:
            print(error.localizedDescription) // Surface these in your UI.
          }
          // highlight-recordings-failure
        }
      }
    }
  }

  // highlight-recordings-persist
  /// Copies a captured file from the temporary directory to the app's Documents directory.
  private func persistFile(from sourceURL: URL, fileName: String) throws -> URL {
    let documentsURL = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true,
    )
    let destinationURL = documentsURL.appendingPathComponent(fileName)
    if FileManager.default.fileExists(atPath: destinationURL.path) {
      try FileManager.default.removeItem(at: destinationURL)
    }
    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    return destinationURL
  }
  // highlight-recordings-persist
}
