import Foundation
import IMGLYEngine

@MainActor
func toJpeg(engine: Engine) async throws {
  let assetsBase = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.1-rc.0/assets"
  try engine.editor.setSettingString("basePath", value: assetsBase)
  let sceneURL = URL(string: "\(assetsBase)/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneURL)

  let page = try engine.scene.getPages().first!

  // highlight-toJpeg-exportJpeg
  let blob: Blob = try await engine.block.export(
    page,
    mimeType: .jpeg,
    options: ExportOptions(jpegQuality: 0.9),
  )
  // highlight-toJpeg-exportJpeg

  // highlight-toJpeg-exportQuality
  let highQualityBlob = try await engine.block.export(
    page,
    mimeType: .jpeg,
    options: ExportOptions(jpegQuality: 1.0),
  )
  // highlight-toJpeg-exportQuality

  // highlight-toJpeg-exportSize
  let sizedBlob = try await engine.block.export(
    page,
    mimeType: .jpeg,
    options: ExportOptions(
      jpegQuality: 0.85,
      targetWidth: 1920,
      targetHeight: 1080,
    ),
  )
  // highlight-toJpeg-exportSize

  // highlight-toJpeg-saveFile
  let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("export.jpg")
  try blob.write(to: outputURL)
  // highlight-toJpeg-saveFile

  _ = highQualityBlob
  _ = sizedBlob
}
