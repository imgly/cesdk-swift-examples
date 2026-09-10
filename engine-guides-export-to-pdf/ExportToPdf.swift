import Foundation
import IMGLYEngine

@MainActor
func exportToPdf(engine: Engine) async throws {
  // Demo scaffolding: build a small scene with renderable content so every
  // highlighted snippet has something to export. In your app you would start
  // from a scene already loaded into the editor instead.
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let star = try engine.block.create(.graphic)
  try engine.block.setShape(star, shape: engine.block.createShape(.star))
  try engine.block.setPositionX(star, value: 350)
  try engine.block.setPositionY(star, value: 250)
  try engine.block.setWidth(star, value: 100)
  try engine.block.setHeight(star, value: 100)
  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(starFill, property: "fill/color/value", color: .rgba(r: 0, g: 0, b: 1, a: 1))
  try engine.block.setFill(star, fill: starFill)
  try engine.block.appendChild(to: page, child: star)

  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-exportToPdf-export
  let pdfBlob = try await engine.block.export(scene, mimeType: .pdf)
  try pdfBlob.write(to: exportsDirectory.appendingPathComponent("design.pdf"))
  // highlight-exportToPdf-export

  // highlight-exportToPdf-highCompatibility
  let highCompatibilityOptions = ExportOptions(exportPdfWithHighCompatibility: true)
  let highCompatibilityBlob = try await engine.block.export(
    page,
    mimeType: .pdf,
    options: highCompatibilityOptions,
  )
  try highCompatibilityBlob.write(to: exportsDirectory.appendingPathComponent("design-high-compatibility.pdf"))
  // highlight-exportToPdf-highCompatibility

  // highlight-exportToPdf-spotColor
  engine.editor.setSpotColor(name: "RDG_WHITE", r: 0.8, g: 0.8, b: 0.8)
  // highlight-exportToPdf-spotColor

  // highlight-exportToPdf-underlayer
  let underlayerOptions = ExportOptions(
    exportPdfWithHighCompatibility: true,
    exportPdfWithUnderlayer: true,
    underlayerSpotColorName: "RDG_WHITE",
    underlayerOffset: -2.0,
  )
  let underlayerBlob = try await engine.block.export(page, mimeType: .pdf, options: underlayerOptions)
  try underlayerBlob.write(to: exportsDirectory.appendingPathComponent("design-with-underlayer.pdf"))
  // highlight-exportToPdf-underlayer

  // highlight-exportToPdf-targetSize
  let a4Options = ExportOptions(targetWidth: 2480, targetHeight: 3508)
  let a4Blob = try await engine.block.export(page, mimeType: .pdf, options: a4Options)
  try a4Blob.write(to: exportsDirectory.appendingPathComponent("design-a4.pdf"))
  // highlight-exportToPdf-targetSize
}
