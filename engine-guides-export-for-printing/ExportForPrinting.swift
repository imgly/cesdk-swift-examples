import Foundation
import IMGLYEngine

@MainActor
func exportForPrinting(engine: Engine) async throws {
  // Demo scaffolding: build a small scene with one renderable graphic so the
  // PDF exports below produce a non-empty page. In your app you would start
  // from a scene that the editor has already loaded.
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let star = try engine.block.create(.graphic)
  try engine.block.setShape(star, shape: engine.block.createShape(.star))
  try engine.block.setPositionX(star, value: 250)
  try engine.block.setPositionY(star, value: 150)
  try engine.block.setWidth(star, value: 300)
  try engine.block.setHeight(star, value: 300)
  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(starFill, property: "fill/color/value", color: .rgba(r: 0, g: 0, b: 1, a: 1))
  try engine.block.setFill(star, fill: starFill)

  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-exportForPrinting-dpi
  // 300 DPI is standard for high-quality print output.
  try engine.block.setFloat(scene, property: "scene/dpi", value: 300)
  // highlight-exportForPrinting-dpi

  // highlight-exportForPrinting-highCompatibility
  // High compatibility mode rasterizes complex elements like gradients with
  // transparency at the scene's DPI so they render consistently across PDF
  // viewers and print RIPs.
  let highCompatibilityOptions = ExportOptions(exportPdfWithHighCompatibility: true)
  let highCompatibilityPdf = try await engine.block.export(
    page,
    mimeType: .pdf,
    options: highCompatibilityOptions,
  )
  try highCompatibilityPdf.write(to: exportsDirectory.appendingPathComponent("design.high-compat.pdf"))
  // highlight-exportForPrinting-highCompatibility

  // highlight-exportForPrinting-standard
  // Disabling high compatibility keeps complex elements as vectors. The export
  // is faster and the PDF is smaller, but rendering may differ across viewers.
  let standardOptions = ExportOptions(exportPdfWithHighCompatibility: false)
  let standardPdf = try await engine.block.export(page, mimeType: .pdf, options: standardOptions)
  try standardPdf.write(to: exportsDirectory.appendingPathComponent("design.standard.pdf"))
  // highlight-exportForPrinting-standard

  // highlight-exportForPrinting-defineSpotColor
  // Define the spot color that represents the underlayer ink before exporting.
  // The RGB values are a preview; the underlayer is rendered as a separation
  // referencing the spot color name in print software.
  engine.editor.setSpotColor(name: "RDG_WHITE", r: 0.8, g: 0.8, b: 0.8)
  // highlight-exportForPrinting-defineSpotColor

  // highlight-exportForPrinting-exportWithUnderlayer
  // Generate an underlayer from the design contours filled with the spot color.
  // A negative `underlayerOffset` shrinks the underlayer inward so misaligned
  // print layers do not show visible white edges around design elements.
  let underlayerOptions = ExportOptions(
    exportPdfWithHighCompatibility: true,
    exportPdfWithUnderlayer: true,
    underlayerSpotColorName: "RDG_WHITE",
    underlayerOffset: -2.0,
  )
  let underlayerPdf = try await engine.block.export(page, mimeType: .pdf, options: underlayerOptions)
  try underlayerPdf.write(to: exportsDirectory.appendingPathComponent("design.underlayer.pdf"))
  // highlight-exportForPrinting-exportWithUnderlayer

  // highlight-exportForPrinting-targetSize
  // `targetWidth` / `targetHeight` are pixel dimensions. Combined with the
  // scene DPI set above, they determine the physical print size — 2480×3508
  // pixels at 300 DPI is A4 (210×297 mm).
  let sizedOptions = ExportOptions(
    targetWidth: 2480,
    targetHeight: 3508,
    exportPdfWithHighCompatibility: true,
  )
  let sizedPdf = try await engine.block.export(page, mimeType: .pdf, options: sizedOptions)
  try sizedPdf.write(to: exportsDirectory.appendingPathComponent("design.a4.pdf"))
  // highlight-exportForPrinting-targetSize
}
