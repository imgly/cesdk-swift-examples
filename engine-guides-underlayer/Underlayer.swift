import Foundation
import IMGLYEngine

@MainActor
func underlayer(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.star))
  try engine.block.setPositionX(block, value: 350)
  try engine.block.setPositionY(block, value: 400)
  try engine.block.setWidth(block, value: 100)
  try engine.block.setHeight(block, value: 100)

  let fill = try engine.block.createFill(.color)
  try engine.block.setFill(block, fill: fill)
  let rgbaBlue = Color.rgba(r: 0, g: 0, b: 1, a: 1)
  try engine.block.setColor(fill, property: "fill/color/value", color: rgbaBlue)
  // highlight-setup

  // highlight-create-underlayer-spot-color
  engine.editor.setSpotColor(name: "RDG_WHITE", r: 0.8, g: 0.8, b: 0.8)
  // highlight-create-underlayer-spot-color

  // highlight-export-pdf-underlayer
  let mimeTypePdf: MIMEType = .pdf
  let options = ExportOptions(exportPdfWithUnderlayer: true, underlayerSpotColorName: "RDG_WHITE",
                              underlayerOffset: -2.0)
  let blob = try await engine.block.export(page, mimeType: mimeTypePdf, options: options)
  // highlight-export-pdf-underlayer
}
