import Foundation
import IMGLYEngine
#if canImport(UIKit)
  import UIKit
#endif
#if canImport(AppKit)
  import AppKit
#endif

@MainActor
func exportingBlocks(engine: Engine) async throws {
  try engine.editor.setSettingString("basePath", value: "https://cdn.img.ly/packages/imgly/cesdk-engine/1.60.0-rc.2/assets")
  try await engine.addDefaultAssetSources()
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneUrl)

  /* Export the scene as PDF. */
  let scene = try engine.scene.get()!
  let mimeTypePdf: MIMEType = .pdf
  let sceneBlob = try await engine.block.export(scene, mimeType: mimeTypePdf)

  /* Export a block as PNG image. */
  let block = try engine.block.find(byType: .graphic).first!
  let mimeTypePng: MIMEType = .png
  /* Optionally, the maximum supported export size can be checked before exporting */
  let maxExportSizeInPixels = try engine.editor.getMaxExportSize()
  /* Optionally, the compression level and the target size can be specified. */
  let options = ExportOptions(pngCompressionLevel: 9, targetWidth: 0, targetHeight: 0)
  let blob = try await engine.block.export(block, mimeType: mimeTypePng, options: options)
  /* Convert the blob to UIImage or NSImage. */
  #if os(iOS)
    let exportedBlock = UIImage(data: blob)
  #endif
  #if os(macOS)
    let exportedBlock = NSImage(data: blob)
  #endif
}
