import Foundation
import IMGLYEngine

@MainActor
func partialExport(engine: Engine) async throws {
  // Demo scaffolding: a two-page scene with three colored graphics on page 1
  // and one graphic on page 2, so each highlighted snippet has real exportable
  // content. The rendered guide does not show this setup; readers start from a
  // scene already loaded into their app.
  let scene = try engine.scene.create()

  let page1 = try engine.block.create(.page)
  try engine.block.setWidth(page1, value: 800)
  try engine.block.setHeight(page1, value: 600)
  try engine.block.appendChild(to: scene, child: page1)

  let rectangle = try engine.block.create(.graphic)
  try engine.block.setShape(rectangle, shape: engine.block.createShape(.rect))
  let rectangleFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    rectangleFill,
    property: "fill/color/value",
    color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1.0),
  )
  try engine.block.setFill(rectangle, fill: rectangleFill)
  try engine.block.setPositionX(rectangle, value: 80)
  try engine.block.setPositionY(rectangle, value: 100)
  try engine.block.setWidth(rectangle, value: 220)
  try engine.block.setHeight(rectangle, value: 220)
  try engine.block.setName(rectangle, name: "background-rect")
  try engine.block.appendChild(to: page1, child: rectangle)

  let ellipse = try engine.block.create(.graphic)
  try engine.block.setShape(ellipse, shape: engine.block.createShape(.ellipse))
  let ellipseFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    ellipseFill,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.85, b: 0.2, a: 1.0),
  )
  try engine.block.setFill(ellipse, fill: ellipseFill)
  try engine.block.setPositionX(ellipse, value: 340)
  try engine.block.setPositionY(ellipse, value: 100)
  try engine.block.setWidth(ellipse, value: 220)
  try engine.block.setHeight(ellipse, value: 220)
  try engine.block.appendChild(to: page1, child: ellipse)

  let star = try engine.block.create(.graphic)
  try engine.block.setShape(star, shape: engine.block.createShape(.star))
  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    starFill,
    property: "fill/color/value",
    color: .rgba(r: 0.9, g: 0.2, b: 0.2, a: 1.0),
  )
  try engine.block.setFill(star, fill: starFill)
  try engine.block.setPositionX(star, value: 210)
  try engine.block.setPositionY(star, value: 350)
  try engine.block.setWidth(star, value: 220)
  try engine.block.setHeight(star, value: 220)
  try engine.block.appendChild(to: page1, child: star)

  let page2 = try engine.block.create(.page)
  try engine.block.setWidth(page2, value: 800)
  try engine.block.setHeight(page2, value: 600)
  try engine.block.appendChild(to: scene, child: page2)
  let page2Graphic = try engine.block.create(.graphic)
  try engine.block.setShape(page2Graphic, shape: engine.block.createShape(.rect))
  let page2Fill = try engine.block.createFill(.color)
  try engine.block.setColor(
    page2Fill,
    property: "fill/color/value",
    color: .rgba(r: 0.2, g: 0.7, b: 0.4, a: 1.0),
  )
  try engine.block.setFill(page2Graphic, fill: page2Fill)
  try engine.block.setPositionX(page2Graphic, value: 200)
  try engine.block.setPositionY(page2Graphic, value: 150)
  try engine.block.setWidth(page2Graphic, value: 400)
  try engine.block.setHeight(page2Graphic, value: 300)
  try engine.block.appendChild(to: page2, child: page2Graphic)

  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-partialExport-findBlocks
  let graphicBlocks = try engine.block.find(byType: .graphic)
  let namedBlocks = engine.block.find(byName: "background-rect")
  // highlight-partialExport-findBlocks
  _ = namedBlocks

  guard let firstGraphic = graphicBlocks.first else { return }
  // highlight-partialExport-exportIndividualBlock
  let pngOptions = ExportOptions(pngCompressionLevel: 5)
  let blockData = try await engine.block.export(firstGraphic, mimeType: .png, options: pngOptions)
  try blockData.write(to: exportsDirectory.appendingPathComponent("graphic.png"))
  // highlight-partialExport-exportIndividualBlock

  // highlight-partialExport-createAndExportGroup
  let group = try engine.block.group([rectangle, ellipse])
  let groupData = try await engine.block.export(group, mimeType: .png)
  try groupData.write(to: exportsDirectory.appendingPathComponent("group.png"))
  // highlight-partialExport-createAndExportGroup

  // In a real app the user makes the selection in the editor UI; here we set
  // it programmatically so findAllSelected returns a deterministic value.
  try engine.block.setSelected(star, selected: true)

  // highlight-partialExport-exportSelected
  let selectedBlocks = engine.block.findAllSelected()
  if selectedBlocks.count == 1 {
    let selectionData = try await engine.block.export(selectedBlocks[0], mimeType: .png)
    try selectionData.write(to: exportsDirectory.appendingPathComponent("selection.png"))
  } else if selectedBlocks.count > 1 {
    let selectionGroup = try engine.block.group(selectedBlocks)
    let selectionData = try await engine.block.export(selectionGroup, mimeType: .png)
    try selectionData.write(to: exportsDirectory.appendingPathComponent("selection.png"))
  }
  // highlight-partialExport-exportSelected

  // highlight-partialExport-exportCurrentPage
  if let currentPage = try engine.scene.getCurrentPage() {
    let pageData = try await engine.block.export(currentPage, mimeType: .png)
    try pageData.write(to: exportsDirectory.appendingPathComponent("current-page.png"))
  }
  // highlight-partialExport-exportCurrentPage

  // highlight-partialExport-exportAllPages
  let pages = try engine.scene.getPages()
  let pageStream = try await engine.block.export(pages, mimeType: .png)
  var pageIndex = 1
  for try await data in pageStream {
    try data.write(to: exportsDirectory.appendingPathComponent("page-\(pageIndex).png"))
    pageIndex += 1
  }
  // highlight-partialExport-exportAllPages

  // highlight-partialExport-targetSize
  let resizedOptions = ExportOptions(targetWidth: 1080, targetHeight: 1080)
  let resizedData = try await engine.block.export(page1, mimeType: .png, options: resizedOptions)
  try resizedData.write(to: exportsDirectory.appendingPathComponent("page-1080.png"))
  // highlight-partialExport-targetSize

  // highlight-partialExport-qualityOptions
  let jpegOptions = ExportOptions(jpegQuality: 0.8)
  let jpegData = try await engine.block.export(page1, mimeType: .jpeg, options: jpegOptions)
  try jpegData.write(to: exportsDirectory.appendingPathComponent("page.jpg"))

  let webpOptions = ExportOptions(webpQuality: 0.85)
  let webpData = try await engine.block.export(page1, mimeType: .webp, options: webpOptions)
  try webpData.write(to: exportsDirectory.appendingPathComponent("page.webp"))
  // highlight-partialExport-qualityOptions

  // highlight-partialExport-checkLimits
  let maxExportSize = try engine.editor.getMaxExportSize()
  let availableMemory = try? engine.editor.getAvailableMemory()
  // highlight-partialExport-checkLimits
  _ = maxExportSize
  _ = availableMemory

  // highlight-partialExport-exportPDF
  let pdfOptions = ExportOptions(exportPdfWithHighCompatibility: true)
  let pdfData = try await engine.block.export(page1, mimeType: .pdf, options: pdfOptions)
  try pdfData.write(to: exportsDirectory.appendingPathComponent("page.pdf"))
  // highlight-partialExport-exportPDF
}
