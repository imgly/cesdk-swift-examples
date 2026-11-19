import Foundation
import IMGLYEngine

@MainActor
func photobookSpreads(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-photobookSpreads-createScene
  let scene = try engine.scene.create(sceneLayout: .verticalStack)
  try engine.scene.setDesignUnit(.mm)
  let stack = try engine.block.find(byType: .stack)[0]
  // highlight-photobookSpreads-createScene

  // highlight-photobookSpreads-createCover
  // The print shop gives the spine width for a page count and a paper.
  let spineWidth: Float = 12
  let cover = try createSpread(engine: engine, stack: stack, pages: [
    SpreadPage(name: "Back Cover", width: 210),
    SpreadPage(name: "Spine", width: spineWidth),
    SpreadPage(name: "Front Cover", width: 210),
  ])
  let spine = try engine.block.getPageSlices(cover)[1]
  // A title longer or wider than the spine stops at its folds.
  try engine.block.setClipped(spine, clipped: true)

  let spineTitle = try engine.block.create(.text)
  try engine.block.appendChild(to: cover, child: spineTitle)
  try engine.block.replaceText(spineTitle, text: "Summer 2026")
  try engine.block.setTextFontSize(spineTitle, fontSize: 14)
  let titleWidth: Float = 120
  let titleHeight: Float = 8
  try engine.block.setWidth(spineTitle, value: titleWidth)
  try engine.block.setHeight(spineTitle, value: titleHeight)
  try engine.block.setEnum(spineTitle, property: "text/horizontalAlignment", value: "Center")
  try engine.block.setEnum(spineTitle, property: "text/verticalAlignment", value: "Center")
  // setRotation keeps the center and moves the position. After the turn,
  // the position is the top-right corner of the turned frame.
  try engine.block.setRotation(spineTitle, radians: .pi / 2)
  try engine.block.setPositionX(spineTitle, value: 210 + spineWidth / 2 + titleHeight / 2)
  try engine.block.setPositionY(spineTitle, value: (210 - titleWidth) / 2)
  // highlight-photobookSpreads-createCover

  // highlight-photobookSpreads-createInside
  let firstSpread = try createSpread(engine: engine, stack: stack, pages: [
    SpreadPage(name: "Lake Left", width: 210),
    SpreadPage(name: "Lake Right", width: 210),
  ])
  // The second spread gets its right page from a copy, the third from a
  // duplicate.
  let secondSpread = try createSpread(engine: engine, stack: stack, pages: [
    SpreadPage(name: "Trip Left", width: 210),
  ])
  let thirdSpread = try createSpread(engine: engine, stack: stack, pages: [
    SpreadPage(name: "Notes Left", width: 210),
  ])
  let lakePages = try engine.block.getPageSlices(firstSpread)
  let lakeLeft = lakePages[0]
  let lakeRight = lakePages[1]
  // highlight-photobookSpreads-createInside

  // highlight-photobookSpreads-photoAcrossFold
  // One photo over both pages, bleed included, centered on the fold
  let photo = try engine.block.create(.graphic)
  try engine.block.setShape(photo, shape: engine.block.createShape(.rect))
  let photoFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    photoFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(photo, fill: photoFill)
  try engine.block.appendChild(to: firstSpread, child: photo)
  try engine.block.setPositionX(photo, value: -3)
  try engine.block.setPositionY(photo, value: -3)
  try engine.block.setWidth(photo, value: 426)
  try engine.block.setHeight(photo, value: 216)

  // On the fold, the earlier page slice owns the photo.
  let photoOwner = try engine.block.getOwningPageSlice(photo)
  print("The photo belongs to the left page:", photoOwner == lakeLeft)
  // highlight-photobookSpreads-photoAcrossFold

  // highlight-photobookSpreads-copyPage
  // A page slice fill and the blocks that a page slice owns go with a copy.
  let pageFill = try engine.block.createFill(.color)
  try engine.block.setColor(pageFill, property: "fill/color/value", color: .rgba(r: 0.1, g: 0.2, b: 0.3, a: 1))
  try engine.block.setFill(lakeRight, fill: pageFill)
  let caption = try engine.block.create(.text)
  try engine.block.appendChild(to: firstSpread, child: caption)
  try engine.block.replaceText(caption, text: "At the lake")
  try engine.block.setTextFontSize(caption, fontSize: 12)
  try engine.block.setTextColor(caption, color: .rgba(r: 1, g: 1, b: 1, a: 1))
  try engine.block.setWidth(caption, value: 190)
  try engine.block.setHeight(caption, value: 10)
  try engine.block.setPositionX(caption, value: 220)
  try engine.block.setPositionY(caption, value: 180)

  let saved = try await engine.block.saveToString(blocks: [lakeRight])
  let copy = try await engine.block.load(from: saved)[0]
  try engine.block.setName(copy, name: "Trip Right")
  // The copy becomes the right page. The next update puts the caption on it.
  try engine.block.insertChild(into: secondSpread, child: copy, at: 1)
  // highlight-photobookSpreads-copyPage

  // highlight-photobookSpreads-duplicatePage
  let note = try engine.block.create(.text)
  try engine.block.appendChild(to: thirdSpread, child: note)
  try engine.block.replaceText(note, text: "Notes")
  try engine.block.setTextFontSize(note, fontSize: 18)
  try engine.block.setWidth(note, value: 190)
  try engine.block.setHeight(note, value: 12)
  try engine.block.setPositionX(note, value: 10)
  try engine.block.setPositionY(note, value: 20)

  // The duplicate goes right after the left page, with a copy of the note.
  let leftPage = try engine.block.getPageSlices(thirdSpread)[0]
  let rightPage = try engine.block.duplicate(leftPage)
  try engine.block.setName(rightPage, name: "Notes Right")
  print("Pages in the third spread:", try engine.block.getPageSlices(thirdSpread).count)
  // highlight-photobookSpreads-duplicatePage

  // highlight-photobookSpreads-export
  // The cover as one sheet, with crop marks and the two spine folds
  let coverPDF = try await engine.block.export(cover, mimeType: .pdf, options: ExportOptions(
    exportPdfWithCropMarks: true,
    exportPdfWithFoldMarks: true,
    printMarkOffset: 3,
    pdfImageQuality: 0.9,
  ))
  // The inside pages: one PDF page per page slice, without the cover
  // A hidden page is left out of a scene export.
  try engine.block.setVisible(cover, visible: false)
  let insidePDF: Data
  do {
    defer { try? engine.block.setVisible(cover, visible: true) }
    insidePDF = try await engine.block.export(scene, mimeType: .pdf, options: ExportOptions(
      exportPdfPageSlices: true,
      pdfImageQuality: 0.9,
    ))
  }
  // Save the PDFs to files or share them in your app.
  print("Cover PDF bytes:", coverPDF.count)
  print("Inside PDF bytes:", insidePDF.count)
  // highlight-photobookSpreads-export

  try await engine.captureGuide(data: coverPDF, label: "cover-pdf", mimeType: .pdf)
  try await engine.captureGuide(data: insidePDF, label: "inside-pdf", mimeType: .pdf)

  // highlight-photobookSpreads-singlePageMode
  try engine.editor.setSettingBool("features/singlePageModeEnabled", value: true)
  // Two page slices of one spread form a facing pair.
  try engine.scene.setCurrentPages([lakeLeft, lakeRight])
  print("Shown pages:", try engine.scene.getCurrentPages().count)
  // The camera does not move by itself.
  try await engine.scene.zoom(to: firstSpread, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)
  // highlight-photobookSpreads-singlePageMode
}

// highlight-photobookSpreads-createSpread
private struct SpreadPage {
  let name: String
  let width: Float
}

@MainActor
private func createSpread(engine: Engine, stack: DesignBlockID, pages: [SpreadPage]) throws -> DesignBlockID {
  let spread = try engine.block.create(.page)
  try engine.block.appendChild(to: stack, child: spread)

  // A 3 mm bleed on every side of the spread
  try engine.block.setBool(spread, property: "page/marginEnabled", value: true)
  for side in ["top", "bottom", "left", "right"] {
    try engine.block.setFloat(spread, property: "page/margin/\(side)", value: 3)
  }

  for page in pages {
    let pageSlice = try engine.block.create(.pageSlice)
    // Size the page slice before it joins the spread.
    try engine.block.setWidth(pageSlice, value: page.width)
    try engine.block.setHeight(pageSlice, value: 210)
    try engine.block.setName(pageSlice, name: page.name)
    try engine.block.appendChild(to: spread, child: pageSlice)
  }
  return spread
}

// highlight-photobookSpreads-createSpread
