import Foundation
import IMGLYEngine

@MainActor
func loadSceneFromBlob(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-fetch-blob
  let sceneURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  let sceneBlob = try await URLSession.shared.data(from: sceneURL).0
  // highlight-fetch-blob

  // highlight-read-blob
  guard let blobString = String(data: sceneBlob, encoding: .utf8) else { return }
  // highlight-read-blob

  // highlight-load-blob
  try await engine.scene.load(from: blobString)
  // highlight-load-blob

  let text = try engine.block.find(byType: .text).first!
  try engine.block.setDropShadowEnabled(text, enabled: true)
}
