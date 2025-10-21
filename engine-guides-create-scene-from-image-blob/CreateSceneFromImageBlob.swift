import Foundation
import IMGLYEngine

@MainActor
func createSceneFromImageBlob(engine: Engine) async throws {
  // highlight-blob-swift
  let blob = try await URLSession.shared.data(from: .init(string: "https://img.ly/static/ubq_samples/sample_4.jpg")!).0
  // highlight-blob-swift

  // highlight-objectURL-swift
  let url = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("jpg")
  try blob.write(to: url, options: .atomic)
  // highlight-objectURL-swift

  // highlight-initialImageURL-swift
  let scene = try await engine.scene.create(fromImage: url)
  // highlight-initialImageURL-swift

  // highlight-findByType-blob
  let page = try engine.block.find(byType: .page).first!
  // highlight-findByType-blob

  // highlight-check-fill-blob
  let pageFill = try engine.block.getFill(page)
  let imageFillType = try engine.block.getType(pageFill)
  // highlight-check-fill-blob
}
