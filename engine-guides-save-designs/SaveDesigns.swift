import Foundation
import IMGLYEngine

@MainActor
func saveDesigns(engine: Engine) async throws {
  // Demo scaffolding: load a template so every snippet has a scene to operate on.
  // In your app you would start from a scene already loaded into the editor.
  let baseURL = try engine.guidesBaseURL
  try engine.editor.setSettingString("basePath", value: baseURL.absoluteString)
  let templateURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: templateURL)

  let outputDir = FileManager.default.temporaryDirectory

  // highlight-saveDesigns-saveToString
  let sceneString = try await engine.scene.saveToString()
  // highlight-saveDesigns-saveToString

  // highlight-saveDesigns-saveToArchive
  let archiveBlob = try await engine.scene.saveToArchive()
  // highlight-saveDesigns-saveToArchive

  // highlight-saveDesigns-compression
  let compressed = try await engine.scene.saveToString(
    options: SaveToStringOptions(
      compression: CompressionOptions(format: .zstd, level: .default),
    ),
  )
  // highlight-saveDesigns-compression
  _ = compressed

  // highlight-saveDesigns-writeScene
  let sceneURL = outputDir.appendingPathComponent("scene.scene")
  try sceneString.write(to: sceneURL, atomically: true, encoding: .utf8)
  // highlight-saveDesigns-writeScene

  // highlight-saveDesigns-writeArchive
  let archiveURL = outputDir.appendingPathComponent("scene.zip")
  try archiveBlob.write(to: archiveURL)
  // highlight-saveDesigns-writeArchive

  // highlight-saveDesigns-loadScene
  let restoredString = try String(contentsOf: sceneURL, encoding: .utf8)
  try await engine.scene.load(from: restoredString)
  // highlight-saveDesigns-loadScene

  // highlight-saveDesigns-loadArchive
  try await engine.scene.loadArchive(from: archiveURL)
  // highlight-saveDesigns-loadArchive
}
