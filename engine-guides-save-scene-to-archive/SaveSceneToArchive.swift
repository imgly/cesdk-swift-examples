import Foundation
import IMGLYEngine

@MainActor
func saveSceneToArchive(engine: Engine) async throws {
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneUrl)

  // highlight-save
  let blob = try await engine.scene.saveToArchive()
  // highlight-save

  // highlight-create-form-data
  var request = URLRequest(url: .init(string: "https://example.com/upload/")!)
  request.httpMethod = "POST"

  let (data, response) = try await URLSession.shared.upload(for: request, from: blob)
  // highlight-create-form-data
}
