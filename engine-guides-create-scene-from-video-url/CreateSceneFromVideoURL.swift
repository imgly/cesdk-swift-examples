import Foundation
import IMGLYEngine

@MainActor
func createSceneFromVideoURL(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )

  // highlight-createFromVideo
  let scene = try await engine.scene.create(fromVideo: videoURL)
  // highlight-createFromVideo

  // highlight-findByType
  // Find the automatically added graphic block in the scene that contains the video fill.
  let block = try engine.block.find(byType: .graphic).first!
  // highlight-findByType

  // highlight-setOpacity
  // Change its opacity.
  try engine.block.setOpacity(block, value: 0.5)
  // highlight-setOpacity
}
