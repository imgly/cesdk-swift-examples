import Foundation
import IMGLYEngine

@MainActor
func toBlob(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  try engine.editor.setSettingString("basePath", value: baseURL.absoluteString)
  let sceneURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: sceneURL)

  let scene = try engine.scene.get()!
  let page = try engine.scene.getPages().first!

  // highlight-toBlob-exportPng
  let pngBlob: Blob = try await engine.block.export(page, mimeType: .png)
  // highlight-toBlob-exportPng

  // highlight-toBlob-exportOptions
  let options = ExportOptions(
    jpegQuality: 0.8,
    targetWidth: 1920,
    targetHeight: 1080,
  )
  let jpegBlob = try await engine.block.export(page, mimeType: .jpeg, options: options)
  // highlight-toBlob-exportOptions

  // highlight-toBlob-exportStream
  let pages = try engine.scene.getPages()
  let stream = try await engine.block.export(pages, mimeType: .png)
  var blobs: [Blob] = []
  for try await blob in stream {
    blobs.append(blob)
  }
  // highlight-toBlob-exportStream

  // highlight-toBlob-saveToFile
  let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("export.png")
  try pngBlob.write(to: tempURL)
  // highlight-toBlob-saveToFile
}
