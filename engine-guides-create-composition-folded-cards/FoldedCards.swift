import Foundation
import IMGLYEngine

@MainActor
func foldedCards(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-foldedCards-createScene
  try engine.scene.create(sceneLayout: .verticalStack)
  try engine.scene.setDesignUnit(.mm)
  let stack = try engine.block.find(byType: .stack)[0]
  // highlight-foldedCards-createScene

  // highlight-foldedCards-createBiFold
  // An A5 card folds to A6: two panels of 105 × 148 mm on each side.
  let outside = try createSheet(engine: engine, stack: stack, panels: [
    CardPanel(name: "Back", width: 105, height: 148),
    CardPanel(name: "Front", width: 105, height: 148),
  ])
  let inside = try createSheet(engine: engine, stack: stack, panels: [
    CardPanel(name: "Inside Left", width: 105, height: 148),
    CardPanel(name: "Inside Right", width: 105, height: 148),
  ])
  let outsidePanels = try engine.block.getPageSlices(outside)
  let back = outsidePanels[0]
  let front = outsidePanels[1]
  // highlight-foldedCards-createBiFold

  // highlight-foldedCards-createTriFold
  // The inside flap is 3 mm narrower, so it fits inside without buckling.
  // The inside sheet holds the same widths in the opposite order.
  let leafletOutside = try createSheet(engine: engine, stack: stack, panels: [
    CardPanel(name: "Inside Flap", width: 97, height: 210),
    CardPanel(name: "Back", width: 100, height: 210),
    CardPanel(name: "Cover", width: 100, height: 210),
  ])
  let leafletInside = try createSheet(engine: engine, stack: stack, panels: [
    CardPanel(name: "Inside Left", width: 100, height: 210),
    CardPanel(name: "Inside Middle", width: 100, height: 210),
    CardPanel(name: "Inside Right", width: 97, height: 210),
  ])
  // highlight-foldedCards-createTriFold

  // highlight-foldedCards-addContent
  let frontFill = try engine.block.createFill(.color)
  try engine.block.setColor(frontFill, property: "fill/color/value", color: .rgba(r: 0.55, g: 0.12, b: 0.2, a: 1))
  try engine.block.setFill(front, fill: frontFill)

  // Content is a child of the page, in the coordinates of the sheet.
  let title = try engine.block.create(.text)
  try engine.block.appendChild(to: outside, child: title)
  try engine.block.replaceText(title, text: "Happy Birthday")
  try engine.block.setTextFontSize(title, fontSize: 24)
  try engine.block.setTextColor(title, color: .rgba(r: 1, g: 1, b: 1, a: 1))
  try engine.block.setWidth(title, value: 85)
  try engine.block.setHeightMode(title, mode: .auto)
  try engine.block.setPositionX(title, value: 115)
  try engine.block.setPositionY(title, value: 60)

  // One photo across the inside, bleed included, centered on the fold
  let photo = try engine.block.create(.graphic)
  try engine.block.setShape(photo, shape: engine.block.createShape(.rect))
  let photoFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    photoFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(photo, fill: photoFill)
  try engine.block.appendChild(to: inside, child: photo)
  try engine.block.setPositionX(photo, value: -3)
  try engine.block.setPositionY(photo, value: -3)
  try engine.block.setWidth(photo, value: 216)
  try engine.block.setHeight(photo, value: 154)

  // A band on the leaflet cover that reaches 20 mm onto the back and 3 mm
  // into the bleed
  let band = try engine.block.create(.graphic)
  try engine.block.setShape(band, shape: engine.block.createShape(.rect))
  let bandFill = try engine.block.createFill(.color)
  try engine.block.setColor(bandFill, property: "fill/color/value", color: .rgba(r: 0.13, g: 0.36, b: 0.6, a: 1))
  try engine.block.setFill(band, fill: bandFill)
  try engine.block.appendChild(to: leafletOutside, child: band)
  try engine.block.setPositionX(band, value: 177)
  try engine.block.setPositionY(band, value: 20)
  try engine.block.setWidth(band, value: 123)
  try engine.block.setHeight(band, value: 40)
  // highlight-foldedCards-addContent

  // highlight-foldedCards-clipPanels
  // A clipped panel cuts the blocks that it owns at its folds, so the band
  // stops at the fold between the back and the cover of the leaflet.
  for sheet in [outside, leafletOutside] {
    for panel in try engine.block.getPageSlices(sheet) {
      try engine.block.setClipped(panel, clipped: true)
    }
  }
  // The inside panels stay open, so the photo crosses the fold.
  if let photoOwner = try engine.block.getOwningPageSlice(photo) {
    print("The photo belongs to:", try engine.block.getName(photoOwner))
  }
  // highlight-foldedCards-clipPanels

  // highlight-foldedCards-movementConstraint
  // Users cannot drag the blocks of an outside panel past its edges.
  try engine.editor.setMovementConstraint([
    MovementConstraintRule(overshoot: 0, scope: .block(back)),
    MovementConstraintRule(overshoot: 0, scope: .block(front)),
  ])
  if let titleConstraint = try engine.editor.getMovementConstraint(title) {
    print("Overshoot on the title:", titleConstraint.overshoot)
  }
  // highlight-foldedCards-movementConstraint

  // highlight-foldedCards-resizeFormat
  // Pass the size of the whole sheet: half US Letter, landscape.
  try engine.block.resizeContentAware([outside, inside], width: 215.9, height: 139.7)
  let titleOwner = try engine.block.getOwningPageSlice(title)
  print("The title stays on the front:", titleOwner == front)
  // highlight-foldedCards-resizeFormat

  // highlight-foldedCards-export
  // One flat sheet per printed side, with crop and fold marks
  let printMarks = ExportOptions(
    exportPdfWithCropMarks: true,
    exportPdfWithFoldMarks: true,
    // The marks start at the edge of the 3 mm bleed.
    printMarkOffset: 3,
  )
  var sheetPDFs: [Data] = []
  for sheet in [outside, inside, leafletOutside, leafletInside] {
    let pdf = try await engine.block.export(sheet, mimeType: .pdf, options: printMarks)
    // Save the PDF to a file or share it in your app.
    print(try engine.block.getName(sheet), "PDF bytes:", pdf.count)
    sheetPDFs.append(pdf)
  }
  // highlight-foldedCards-export

  for (index, pdf) in sheetPDFs.enumerated() {
    try await engine.captureGuide(data: pdf, label: "sheet-\(index + 1)", mimeType: .pdf)
  }
}

// highlight-foldedCards-createSheet
private struct CardPanel {
  let name: String
  let width: Float
  let height: Float
}

@MainActor
private func createSheet(engine: Engine, stack: DesignBlockID, panels: [CardPanel]) throws -> DesignBlockID {
  let page = try engine.block.create(.page)
  try engine.block.setName(page, name: panels.map(\.name).joined(separator: " | "))
  try engine.block.appendChild(to: stack, child: page)

  // A 3 mm bleed on every side of the sheet
  try engine.block.setBool(page, property: "page/marginEnabled", value: true)
  for side in ["top", "bottom", "left", "right"] {
    try engine.block.setFloat(page, property: "page/margin/\(side)", value: 3)
  }

  for panel in panels {
    let pageSlice = try engine.block.create(.pageSlice)
    // Size the page slice before it joins the page.
    try engine.block.setWidth(pageSlice, value: panel.width)
    try engine.block.setHeight(pageSlice, value: panel.height)
    try engine.block.setName(pageSlice, name: panel.name)
    try engine.block.appendChild(to: page, child: pageSlice)
  }
  return page
}

// highlight-foldedCards-createSheet
