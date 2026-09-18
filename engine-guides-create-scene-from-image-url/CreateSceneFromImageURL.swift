import Foundation
import IMGLYEngine

@MainActor
func createSceneFromImageURL(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_4.jpg")

  // highlight-createFromImage-url
  try await engine.scene.create(fromImage: imageURL)
  // highlight-createFromImage-url

  // highlight-findByType-url
  guard let page = try engine.block.find(byType: .page).first else { return }
  // highlight-findByType-url

  // highlight-check-fill-url
  let pageFill = try engine.block.getFill(page)
  let isImageFill = try engine.block.getType(pageFill) == FillType.image.rawValue
  print("Page is filled with an image: \(isImageFill)")
  // highlight-check-fill-url

  // The image loaded as the page's content — captured as the guide's hero.
  try await engine.captureGuide(page, label: "hero")
}
