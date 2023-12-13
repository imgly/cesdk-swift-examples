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
  // Find the automatically added graphic block in the scene that contains the image fill.
  let block = try engine.block.find(byType: .graphic).first!
  // highlight-findByType

  // highlight-set-opacity
  // Change its opacity.
  try engine.block.setOpacity(block, value: 0.5)
  // highlight-set-opacity
}
