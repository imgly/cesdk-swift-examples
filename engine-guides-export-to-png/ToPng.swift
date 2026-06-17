import Foundation
import IMGLYEngine

@MainActor
func toPng(engine: Engine) async throws {
  let assetsBase = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.1/assets"
  try engine.editor.setSettingString("basePath", value: assetsBase)
  let sceneURL = URL(string: "\(assetsBase)/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneURL)

  let page = try engine.scene.getPages().first!

  // highlight-toPng-exportPng
  let blob: Blob = try await engine.block.export(page, mimeType: .png)
  // highlight-toPng-exportPng

  // highlight-toPng-compressionLevel
  let compressedBlob = try await engine.block.export(
    page,
    mimeType: .png,
    options: ExportOptions(pngCompressionLevel: 9),
  )
  // highlight-toPng-compressionLevel

  // highlight-toPng-targetSize
  let sizedBlob = try await engine.block.export(
    page,
    mimeType: .png,
    options: ExportOptions(targetWidth: 1920, targetHeight: 1080),
  )
  // highlight-toPng-targetSize

  // highlight-toPng-saveFile
  let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("export.png")
  try blob.write(to: outputURL)
  // highlight-toPng-saveFile

  _ = compressedBlob
  _ = sizedBlob
}
