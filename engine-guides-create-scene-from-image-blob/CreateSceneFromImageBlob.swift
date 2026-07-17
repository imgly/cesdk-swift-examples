import Foundation
import IMGLYEngine

@MainActor
func createSceneFromImageBlob(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-blob-swift
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_4.jpg")
  let blob = try await URLSession.shared.data(from: imageURL).0
  // highlight-blob-swift

  // highlight-objectURL-swift
  let url = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("jpg")
  try blob.write(to: url, options: .atomic)
  // highlight-objectURL-swift

  // highlight-initialImageURL-swift
  try await engine.scene.create(fromImage: url)
  // highlight-initialImageURL-swift
}
