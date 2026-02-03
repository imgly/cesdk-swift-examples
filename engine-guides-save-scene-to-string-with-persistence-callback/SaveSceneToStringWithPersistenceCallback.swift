import Foundation
import IMGLYEngine

@MainActor
func saveSceneToStringWithPersistenceCallback(engine: Engine) async throws {
  try engine.editor.setSettingString("basePath", value: "https://cdn.img.ly/packages/imgly/cesdk-engine/1.68.0-rc.4/assets")
  try await engine.addDefaultAssetSources()
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneUrl)
  let blob = try await engine.scene.saveToArchive()
  let sceneArchiveUrl = FileManager.default.temporaryDirectory.appendingPathComponent(
    UUID().uuidString,
    conformingTo: .zip,
  )
  try blob.write(to: sceneArchiveUrl)
  try await engine.scene.loadArchive(from: sceneArchiveUrl)

  // highlight-saveToStringWithPersistenceCallback
  var alreadyPersistedURLs: [String: URL] = [:]
  let sceneAsString = try await engine.scene.saveToString(allowedResourceSchemes: ["http", "https"]) { url, hash in
    guard let persistedURL = alreadyPersistedURLs[hash] else {
      do {
        var blob = Data()
        try engine.editor.getResourceData(url: url, chunkSize: 10_000_000) {
          blob.append($0)
          return true
        }
        let persistedURL = URL(string: "https://example.com/" + url.absoluteString.components(separatedBy: "://")[1])!
        var request = URLRequest(url: persistedURL)
        request.httpMethod = "POST"
        let (data, response) = try await URLSession.shared.upload(for: request, from: blob)
        alreadyPersistedURLs[hash] = persistedURL
        return persistedURL
      } catch {
        print("Failed to persist \(url):", error)
        return url
      }
    }
    return persistedURL
  }
  // highlight-saveToStringWithPersistenceCallback

  // highlight-result-callback
  print(sceneAsString)
  // highlight-result-callback
}
