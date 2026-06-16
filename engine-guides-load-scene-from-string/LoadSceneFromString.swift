import Foundation
import IMGLYEngine

@MainActor
func loadSceneFromString(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-fetch-string
  let sceneURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  let sceneBlob = try await URLSession.shared.data(from: sceneURL).0
  let blobString = String(data: sceneBlob, encoding: .utf8)!
  // highlight-fetch-string

  // highlight-load-string
  let scene = try await engine.scene.load(from: blobString)
  // highlight-load-string

  // highlight-modify-text-string
  let text = try engine.block.find(byType: .text).first!
  try engine.block.setDropShadowEnabled(text, enabled: true)
  // highlight-modify-text-string
}
