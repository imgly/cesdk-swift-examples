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
  let scene = try await engine.scene.create(from: url)
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
