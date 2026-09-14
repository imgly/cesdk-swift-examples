import Foundation
import IMGLYEngine

@MainActor
func createSceneFromVideoURL(engine: Engine) async throws {
  // highlight-createFromVideo
  let scene = try await engine.scene.create(fromVideo: URL(string: "https://img.ly/static/ubq_video_samples/bbb.mp4")!)
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
