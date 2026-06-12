import Foundation
import IMGLYEngine

@MainActor
func loadSceneFromRemote(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-url
  let sceneUrl =
    baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  // highlight-url

  // highlight-load-remote
  let scene = try await engine.scene.load(from: sceneUrl)
  // highlight-load-remote

  // highlight-modify-text-remote
  let text = try engine.block.find(byType: .text).first!
  try engine.block.setDropShadowEnabled(text, enabled: true)
  // highlight-modify-text-remote
}
