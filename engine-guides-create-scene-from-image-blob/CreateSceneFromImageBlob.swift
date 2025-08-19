import Foundation
import IMGLYEngine

@MainActor
func createSceneFromImageBlob(engine: Engine) async throws {
  // highlight-blob
  let blob = try await URLSession.shared.data(from: .init(string: "https://img.ly/static/ubq_samples/sample_4.jpg")!).0
  // highlight-blob

  // highlight-objectURL
  let url = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("jpg")
  try blob.write(to: url, options: .atomic)
  // highlight-objectURL

  // highlight-initialImageURL
  let scene = try await engine.scene.create(fromImage: url)
  // highlight-initialImageURL

  // highlight-findByType
  let page = try engine.block.find(byType: .page).first!
  // highlight-findByType

  // highlight-check-fill
  let pageFill = try engine.block.getFill(page)
  let imageFillType = try engine.block.getType(pageFill)
  // highlight-check-fill
}
