import Foundation
import IMGLYEngine

@MainActor
func loadSceneFromRemote(engine: Engine) async throws {
  // highlight-url
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  // highlight-url

  // highlight-load
  let scene = try await engine.scene.load(fromURL: sceneUrl)
  // highlight-load

  // highlight-set-text-dropshadow
  let text = try engine.block.find(byType: .text).first!
  try engine.block.setDropShadowEnabled(text, enabled: true)
  // highlight-set-text-dropshadow
}
