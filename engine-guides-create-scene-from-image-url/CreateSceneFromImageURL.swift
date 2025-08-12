import Foundation
import IMGLYEngine

@MainActor
func createSceneFromImageURL(engine: Engine) async throws {
  // highlight-createFromImage
  let scene = try await engine.scene.create(fromImage: URL(string: "https://img.ly/static/ubq_samples/sample_4.jpg")!)
  // highlight-createFromImage

  // highlight-findByType
  // Get the fill from the page and verify it's an image fill
  let page = try engine.block.find(byType: .page).first!
  // highlight-findByType

  // highlight-check-fill
  let pageFill = try engine.block.getFill(page)
  let imageFillType = try engine.block.getType(pageFill)
  // highlight-check-fill
}
