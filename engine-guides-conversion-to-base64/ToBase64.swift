import Foundation
import IMGLYEngine

@MainActor
func toBase64(engine: Engine) async throws {
  let scene = try await engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)

  let graphic = try engine.block.create(.graphic)
  try engine.block.appendChild(to: page, child: graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(graphic, shape: rectShape)
  let colorFill = try engine.block.createFill(.color)
  try engine.block.setColor(colorFill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1))
  try engine.block.setFill(graphic, fill: colorFill)
  try engine.block.setWidth(graphic, value: 400)
  try engine.block.setHeight(graphic, value: 300)
  try engine.block.setPositionX(graphic, value: 200)
  try engine.block.setPositionY(graphic, value: 150)

  // highlight-toBase64-export
  let blob = try await engine.block.export(page, mimeType: .png)
  let base64String = blob.base64EncodedString()
  // highlight-toBase64-export

  // highlight-toBase64-dataURI
  let mimeType: MIMEType = .png
  let dataURI = "data:\(mimeType.rawValue);base64,\(blob.base64EncodedString())"
  // highlight-toBase64-dataURI

  // highlight-toBase64-mimeTypes
  let pngBlob = try await engine.block.export(page, mimeType: .png)
  let pngBase64 = pngBlob.base64EncodedString()

  let jpegBlob = try await engine.block.export(
    page,
    mimeType: .jpeg,
    options: ExportOptions(jpegQuality: 0.8),
  )
  let jpegBase64 = jpegBlob.base64EncodedString()

  let webpBlob = try await engine.block.export(
    page,
    mimeType: .webp,
    options: ExportOptions(webpQuality: 0.9),
  )
  let webpBase64 = webpBlob.base64EncodedString()
  // highlight-toBase64-mimeTypes

  // highlight-toBase64-batch
  let pages = try engine.scene.getPages()
  var base64Results: [String] = []
  for try await pageBlob in try await engine.block.export(pages, mimeType: .png) {
    base64Results.append(pageBlob.base64EncodedString())
  }
  // highlight-toBase64-batch

  _ = base64String
  _ = dataURI
  _ = pngBase64
  _ = jpegBase64
  _ = webpBase64
  _ = base64Results
}
