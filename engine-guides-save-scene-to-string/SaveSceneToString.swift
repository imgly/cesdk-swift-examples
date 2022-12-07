import Foundation
import IMGLYEngine

@MainActor
func saveSceneToString(engine: Engine) async throws {
  let sceneUrl =
    URL(string: "https://cdn.img.ly/packages/imgly/cesdk-js/latest/assets/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(fromURL: sceneUrl)

  // highlight-save
  let sceneAsString = try await engine.scene.saveToString()
  // highlight-save

  // highlight-result
  print(sceneAsString)
  // highlight-result
}
