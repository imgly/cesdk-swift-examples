import Foundation
import IMGLYEngine

@MainActor
func createSceneFromImageURL(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_4.jpg")

  // highlight-createFromImage-url
  let scene = try await engine.scene.create(fromImage: imageURL)
  // highlight-createFromImage-url

  // highlight-findByType-url
  // Get the fill from the page and verify it's an image fill
  let page = try engine.block.find(byType: .page).first!
  // highlight-findByType-url

  // highlight-check-fill-url
  let pageFill = try engine.block.getFill(page)
  let imageFillType = try engine.block.getType(pageFill)
  // highlight-check-fill-url
}
