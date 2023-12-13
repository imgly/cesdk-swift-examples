import Foundation
import IMGLYEngine

@MainActor
func createSceneFromImageURL(engine: Engine) async throws {
  // highlight-createFromImage
  let scene = try await engine.scene.create(fromImage: URL(string: "https://img.ly/static/ubq_samples/sample_4.jpg")!)
  // highlight-createFromImage

  // highlight-findByType
  // Find the automatically added graphic block in the scene that contains the image fill.
  let block = try engine.block.find(byType: .graphic).first!
  // highlight-findByType

  // highlight-setOpacity
  // Change its opacity.
  try engine.block.setOpacity(block, value: 0.5)
  // highlight-setOpacity
}
