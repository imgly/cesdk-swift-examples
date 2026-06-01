import Foundation
import IMGLYEngine

@MainActor
func toWebp(engine: Engine) async throws {
  let assetsBase = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.0-rc.1/assets"
  try engine.editor.setSettingString("basePath", value: assetsBase)
  let sceneURL = URL(string: "\(assetsBase)/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneURL)

  let page = try engine.scene.getPages().first!

  // highlight-toWebp-exportWebp
  let blob: Blob = try await engine.block.export(
    page,
    mimeType: .webp,
    options: ExportOptions(webpQuality: 0.8),
  )
  // highlight-toWebp-exportWebp

  // highlight-toWebp-lossless
  let losslessBlob = try await engine.block.export(
    page,
    mimeType: .webp,
    options: ExportOptions(webpQuality: 1.0),
  )
  // highlight-toWebp-lossless

  // highlight-toWebp-targetSize
  let sizedBlob = try await engine.block.export(
    page,
    mimeType: .webp,
    options: ExportOptions(
      webpQuality: 0.85,
      targetWidth: 1920,
      targetHeight: 1080,
    ),
  )
  // highlight-toWebp-targetSize

  // highlight-toWebp-saveFile
  let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("export.webp")
  try blob.write(to: outputURL)
  // highlight-toWebp-saveFile

  _ = losslessBlob
  _ = sizedBlob
}
