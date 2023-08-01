import Foundation
import IMGLYEngine

@MainActor
func saveSceneToBlob(engine: Engine) async throws {
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(fromURL: sceneUrl)

  // highlight-save
  let savedSceneString = try await engine.scene.saveToString()
  // highlight-save

  // highlight-create-blob
  let blob = savedSceneString.data(using: .utf8)!
  // highlight-create-blob

  // highlight-create-form-data
  var request = URLRequest(url: .init(string: "https://upload.com")!)
  request.httpMethod = "POST"

  let (data, response) = try await URLSession.shared.upload(for: request, from: blob)
  // highlight-create-form-data
}
