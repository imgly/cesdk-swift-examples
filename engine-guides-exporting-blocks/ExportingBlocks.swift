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
  try engine.editor.setSettingString("basePath", value: "https://cdn.img.ly/packages/imgly/cesdk-engine/1.18.1-rc.0/assets")
  try await engine.addDefaultAssetSources()
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneUrl)

  /* Export the scene as PDF. */
  let scene = try engine.scene.get()!
  let mimeTypePdf: MIMEType = .pdf
  let sceneBlob = try await engine.block.export(scene, mimeType: mimeTypePdf)

  /* Export a block as PNG image. */
  let block = try engine.block.find(byType: .image).first!
  let mimeTypePng: MIMEType = .png
  let options = ExportOptions(pngCompressionLevel: 9)
  let blob = try await engine.block.export(block, mimeType: mimeTypePng, options: options)
  /* Convert the blob to UIImage or NSImage. */
  #if os(iOS)
    let exportedBlock = UIImage(data: blob)
  #endif
  #if os(macOS)
    let exportedBlock = NSImage(data: blob)
  #endif
}
