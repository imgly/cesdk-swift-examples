import Foundation
import IMGLYEngine

@MainActor
func saveSceneToBlob(engine: Engine) async throws {
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneUrl)

  // highlight-saveToBlob
  let savedSceneString = try await engine.scene.saveToString()
  // highlight-saveToBlob

  // highlight-create-blob
  let blob = savedSceneString.data(using: .utf8)!
  // highlight-create-blob

  // highlight-create-form-data-blob
  var request = URLRequest(url: .init(string: "https://example.com/upload/")!)
  request.httpMethod = "POST"

  let (data, response) = try await URLSession.shared.upload(for: request, from: blob)
  // highlight-create-form-data-blob
}
