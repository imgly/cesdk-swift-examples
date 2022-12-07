import Foundation
import IMGLYEngine

@MainActor
func createSceneFromImageURL(engine: Engine) async throws {
  // highlight-initialImageURL
  let scene = try await engine.scene.create(from: URL(string: "https://img.ly/static/ubq_samples/sample_4.jpg")!)
  // highlight-initialImageURL

  // highlight-find-image
  // Find the automatically added image element in the scene.
  let image = try engine.block.find(byType: .image).first!
  // highlight-find-image

  // highlight-set-opacity
  // Change its opacity.
  try engine.block.setOpacity(image, value: 0.5)
  // highlight-set-opacity
}
