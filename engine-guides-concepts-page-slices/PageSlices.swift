import Foundation
import IMGLYEngine

@MainActor
func pageSlices(engine: Engine) async throws {
  // highlight-pageSlices-createPage
  try engine.scene.create(sceneLayout: .verticalStack)
  try engine.scene.setDesignUnit(.mm)
  let stack = try engine.block.find(byType: .stack)[0]

  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: stack, child: page)

  // A 3 mm bleed on every side of the sheet
  try engine.block.setBool(page, property: "page/marginEnabled", value: true)
  for side in ["top", "bottom", "left", "right"] {
    try engine.block.setFloat(page, property: "page/margin/\(side)", value: 3)
  }
  // highlight-pageSlices-createPage

  // highlight-pageSlices-createPanels
  // The outside of a tri-fold: the inside flap, the back and the cover
  var panels: [DesignBlockID] = []
  for panelName in ["Inside Flap", "Back", "Cover"] {
    let panel = try engine.block.create(.pageSlice)
    // Size the page slice before it joins the page.
    try engine.block.setWidth(panel, value: 99)
    try engine.block.setHeight(panel, value: 210)
    try engine.block.setName(panel, name: panelName)
    try engine.block.appendChild(to: page, child: panel)
    panels.append(panel)
  }
  let flap = panels[0]
  let cover = panels[2]
  // highlight-pageSlices-createPanels

  // highlight-pageSlices-panelFill
  let coverFill = try engine.block.createFill(.color)
  try engine.block.setColor(coverFill, property: "fill/color/value", color: .rgba(r: 0.13, g: 0.36, b: 0.6, a: 1))
  // setFill on a page slice also turns its fill on.
  try engine.block.setFill(cover, fill: coverFill)
  // highlight-pageSlices-panelFill

  // highlight-pageSlices-addContent
  // Content is a child of the page, in the coordinates of the page.
  let title = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: title)
  try engine.block.replaceText(title, text: "Summer Workshops")
  try engine.block.setTextFontSize(title, fontSize: 28)
  try engine.block.setTextColor(title, color: .rgba(r: 1, g: 1, b: 1, a: 1))
  try engine.block.setWidth(title, value: 79)
  try engine.block.setHeightMode(title, mode: .auto)
  try engine.block.setPositionX(title, value: 208)
  try engine.block.setPositionY(title, value: 30)

  let flapNote = try engine.block.create(.graphic)
  try engine.block.setShape(flapNote, shape: engine.block.createShape(.rect))
  let noteFill = try engine.block.createFill(.color)
  try engine.block.setColor(noteFill, property: "fill/color/value", color: .rgba(r: 0.95, g: 0.75, b: 0.2, a: 1))
  try engine.block.setFill(flapNote, fill: noteFill)
  try engine.block.appendChild(to: page, child: flapNote)
  try engine.block.setWidth(flapNote, value: 79)
  try engine.block.setHeight(flapNote, value: 60)
  try engine.block.setPositionX(flapNote, value: 10)
  try engine.block.setPositionY(flapNote, value: 140)
  // highlight-pageSlices-addContent

  // highlight-pageSlices-owningPageSlice
  // The page slice under the center of a block owns it.
  if let titleOwner = try engine.block.getOwningPageSlice(title) {
    print("The title is on:", try engine.block.getName(titleOwner))
  }

  // The blocks of one panel: filter the children of the page.
  let coverBlocks = try engine.block.getChildren(page).filter { child in
    try engine.block.getOwningPageSlice(child) == cover
  }
  print("Blocks on the cover:", coverBlocks.count)
  // highlight-pageSlices-owningPageSlice

  // highlight-pageSlices-getPageSlices
  // Reading order, hidden page slices too
  let readingOrder = try engine.block.getPageSlices(page).map { try engine.block.getName($0) }
  print("Panels in reading order:", readingOrder.joined(separator: ", "))
  // highlight-pageSlices-getPageSlices

  // highlight-pageSlices-moveOutAndIn
  // Take the flap out as its own page, after the leaflet.
  let flapPage = try engine.block.movePageSliceOutOfPage(flap, index: 1)
  try engine.editor.addUndoStep()

  // Put it back as the first panel. The id changes on each move.
  let flapAgain = try engine.block.movePageSliceIntoPage(flapPage, page: page, index: 0)
  try engine.editor.addUndoStep()
  print("The note is on the flap again:", try engine.block.getOwningPageSlice(flapNote) == flapAgain)
  // highlight-pageSlices-moveOutAndIn

  // highlight-pageSlices-moveError
  // The scene has one page, so index 9 is a bug in the calling code.
  do {
    _ = try engine.block.movePageSliceOutOfPage(flapAgain, index: 9)
  } catch let error as EngineError where error.catalogCode == .blockPageSliceMoveIndexInvalid {
    print("Refused move:", error.code)
  }
  // highlight-pageSlices-moveError

  // highlight-pageSlices-export
  let exportsDirectory = FileManager.default.temporaryDirectory

  // One panel, with the bleed of the page on all four sides
  let coverImage = try await engine.block.export(cover, mimeType: .png)
  try coverImage.write(to: exportsDirectory.appendingPathComponent("cover.png"))

  // The whole sheet, as a printer wants a folded leaflet
  let printMarks = ExportOptions(exportPdfWithCropMarks: true, exportPdfWithFoldMarks: true)
  let sheet = try await engine.block.export(page, mimeType: .pdf, options: printMarks)
  try sheet.write(to: exportsDirectory.appendingPathComponent("tri-fold-outside.pdf"))
  // highlight-pageSlices-export
}
