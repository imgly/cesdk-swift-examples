import Foundation
import IMGLYEngine

@MainActor
func createSceneFromVideoURL(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )

  // highlight-createSceneFromVideoURL-createFromVideo
  try await engine.scene.create(fromVideo: videoURL)
  // highlight-createSceneFromVideoURL-createFromVideo

  // highlight-createSceneFromVideoURL-workWithBlock
  guard let block = try engine.block.find(byType: .graphic).first else { return }
  try engine.block.setOpacity(block, value: 0.5)
  // highlight-createSceneFromVideoURL-workWithBlock
}
