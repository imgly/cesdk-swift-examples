import Foundation
import IMGLYEngine

@MainActor
func loadSceneFromRemote(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  let sceneURL =
    baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")

  // highlight-load-remote
  try await engine.scene.load(from: sceneURL)
  // highlight-load-remote

  // highlight-modify-text-remote
  guard let text = try engine.block.find(byType: .text).first else { return }
  try engine.block.setDropShadowEnabled(text, enabled: true)
  // highlight-modify-text-remote
}
