import Foundation
import IMGLYEngine

@MainActor
func conversionToPdf(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-conversionToPdf-singleImage
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  try await engine.scene.create(fromImage: imageURL)

  guard let page = try engine.scene.getCurrentPage() else { return }
  let singleImagePdf = try await engine.block.export(page, mimeType: .pdf)
  try singleImagePdf.write(to: exportsDirectory.appendingPathComponent("single-image.pdf"))
  // highlight-conversionToPdf-singleImage

  // highlight-conversionToPdf-multiImage
  let imageURLs = [
    baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
    baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg"),
    baseURL.appendingPathComponent("ly.img.image/images/sample_3.jpg"),
  ]
  let stackedScene = try engine.scene.create(sceneLayout: .verticalStack)
  let stack = try engine.block.find(byType: .stack)[0]

  for url in imageURLs {
    let stackedPage = try engine.block.create(.page)
    try engine.block.appendChild(to: stack, child: stackedPage)

    let imageFill = try engine.block.createFill(.image)
    try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: url)
    try engine.block.setFill(stackedPage, fill: imageFill)
  }

  let multiPagePdf = try await engine.block.export(stackedScene, mimeType: .pdf)
  try multiPagePdf.write(to: exportsDirectory.appendingPathComponent("multi-page.pdf"))
  // highlight-conversionToPdf-multiImage

  // highlight-conversionToPdf-dpi
  try engine.block.setFloat(stackedScene, property: "scene/dpi", value: 150)
  // highlight-conversionToPdf-dpi

  // highlight-conversionToPdf-highCompatibility
  let compatOptions = ExportOptions(exportPdfWithHighCompatibility: true)
  let compatPdf = try await engine.block.export(stackedScene, mimeType: .pdf, options: compatOptions)
  try compatPdf.write(to: exportsDirectory.appendingPathComponent("high-compatibility.pdf"))
  // highlight-conversionToPdf-highCompatibility

  // highlight-conversionToPdf-spotColor
  engine.editor.setSpotColor(name: "BrandUnderlay", r: 0.8, g: 0.8, b: 0.8)
  // highlight-conversionToPdf-spotColor

  // highlight-conversionToPdf-underlayer
  let underlayerOptions = ExportOptions(
    exportPdfWithHighCompatibility: true,
    exportPdfWithUnderlayer: true,
    underlayerSpotColorName: "BrandUnderlay",
    underlayerOffset: -2.0,
  )
  let underlayerPdf = try await engine.block.export(stackedScene, mimeType: .pdf, options: underlayerOptions)
  try underlayerPdf.write(to: exportsDirectory.appendingPathComponent("with-underlayer.pdf"))
  // highlight-conversionToPdf-underlayer

  // highlight-conversionToPdf-combined
  try engine.block.setFloat(stackedScene, property: "scene/dpi", value: 300)
  let combinedOptions = ExportOptions(
    targetWidth: 2480,
    targetHeight: 3508,
    exportPdfWithHighCompatibility: true,
    exportPdfWithUnderlayer: true,
    underlayerSpotColorName: "BrandUnderlay",
    underlayerOffset: -2.0,
  )
  let combinedPdf = try await engine.block.export(stackedScene, mimeType: .pdf, options: combinedOptions)
  try combinedPdf.write(to: exportsDirectory.appendingPathComponent("configured.pdf"))
  // highlight-conversionToPdf-combined
}
