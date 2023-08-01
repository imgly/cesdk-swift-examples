import Foundation
import IMGLYEngine
import UIKit

@MainActor
func exportingBlocks(engine: Engine) async throws {
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(fromURL: sceneUrl)

  /* Export the scene as PDF. */
  let scene = try engine.scene.get()!
  let mimeTypePdf: MIMEType = .pdf
  let sceneBlob = try await engine.block.export(scene, mimeType: mimeTypePdf)

  /* Export a block as PNG image. */
  let block = try engine.block.find(byType: .image).first!
  let mimeTypePng: MIMEType = .png
  let options = ExportOptions(pngCompressionLevel: 9)
  let blob = try await engine.block.export(block, mimeType: mimeTypePng, options: options)
  /* Convert the blob to UIImage. */
  let exportedBlock = UIImage(data: blob)
}
