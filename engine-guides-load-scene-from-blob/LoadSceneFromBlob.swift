import Foundation
import IMGLYEngine

@MainActor
func loadSceneFromBlob(engine: Engine) async throws {
  // highlight-fetch-blob
  let sceneURL =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  let sceneBlob = try await URLSession.shared.data(from: sceneURL).0
  // highlight-fetch-blob

  // highlight-read-blob
  let blobString = String(data: sceneBlob, encoding: .utf8)!
  // highlight-read-blob

  // highlight-load
  let scene = try await engine.scene.load(fromString: blobString)
  // highlight-load

  // highlight-set-text-dropshadow
  let text = try engine.block.find(byType: .text).first!
  try engine.block.setDropShadowEnabled(text, enabled: true)
  // highlight-set-text-dropshadow
}
