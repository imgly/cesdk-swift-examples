import Foundation
import IMGLYEngine

@MainActor
func loadSceneFromRemote(engine: Engine) async throws {
  // highlight-url
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  // highlight-url

  // highlight-load-remote
  let scene = try await engine.scene.load(from: sceneUrl)
  // highlight-load-remote

  // highlight-modify-text-remote
  let text = try engine.block.find(byType: .text).first!
  try engine.block.setDropShadowEnabled(text, enabled: true)
  // highlight-modify-text-remote
}
