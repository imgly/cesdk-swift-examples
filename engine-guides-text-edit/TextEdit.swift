import Foundation
import IMGLYEngine

@MainActor
func textEdit(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // Demo scaffolding: a Pixel-unit page sized for a single styled headline so
  // the formatting changes are visible in the captured hero export.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 400)

  // highlight-textEdit-createText
  // Create a text block and position it on the page.
  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: text)
  try engine.block.setPositionX(text, value: 100)
  try engine.block.setPositionY(text, value: 150)
  try engine.block.setWidthMode(text, mode: .auto)
  try engine.block.setHeightMode(text, mode: .auto)
  // highlight-textEdit-createText

  // highlight-textEdit-setTypeface
  // Define a Roboto typeface with regular, bold, italic, and bold-italic variants.
  // Each variant the example formats with later (bold / italic / etc.) needs a matching font in the typeface.
  let robotoBase = baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto")
  let typeface = Typeface(
    name: "Roboto",
    fonts: [
      Font(
        uri: robotoBase.appendingPathComponent("Roboto-Regular.ttf"),
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
      Font(
        uri: robotoBase.appendingPathComponent("Roboto-Bold.ttf"),
        subFamily: "Bold",
        weight: .bold,
        style: .normal,
      ),
      Font(
        uri: robotoBase.appendingPathComponent("Roboto-Italic.ttf"),
        subFamily: "Italic",
        weight: .normal,
        style: .italic,
      ),
      Font(
        uri: robotoBase.appendingPathComponent("Roboto-BoldItalic.ttf"),
        subFamily: "Bold Italic",
        weight: .bold,
        style: .italic,
      ),
    ],
  )
  try engine.block.setFont(text, fontFileURL: typeface.fonts[0].uri, typeface: typeface)
  try engine.block.setTextFontSize(text, fontSize: 80)
  // highlight-textEdit-setTypeface

  // highlight-textEdit-replaceText
  // Replace the entire text content.
  try engine.block.replaceText(text, text: "Hello World!")
  // Replace "World" with "CE.SDK".
  try engine.block.replaceText(text, text: "CE.SDK", in: "Hello World!".range(of: "World")!)
  // Insert " Guide" before the exclamation mark.
  let insertion = "Hello CE.SDK!".range(of: "!")!.lowerBound
  try engine.block.replaceText(text, text: " Guide", in: insertion ..< insertion)
  // highlight-textEdit-replaceText

  // highlight-textEdit-removeText
  // Remove "Hello " to leave "CE.SDK Guide!".
  try engine.block.removeText(text, from: "Hello CE.SDK Guide!".range(of: "Hello ")!)
  // highlight-textEdit-removeText

  // highlight-textEdit-setFormatting
  // Apply bold weight to "CE.SDK".
  try engine.block.setTextFontWeight(
    text,
    fontWeight: .bold,
    in: "CE.SDK Guide!".range(of: "CE.SDK")!,
  )
  // Apply a blue color to "Guide".
  try engine.block.setTextColor(
    text,
    color: .rgba(r: 0.2, g: 0.6, b: 1.0, a: 1.0),
    in: "CE.SDK Guide!".range(of: "Guide")!,
  )
  // Apply italic style to "Guide".
  try engine.block.setTextFontStyle(
    text,
    fontStyle: .italic,
    in: "CE.SDK Guide!".range(of: "Guide")!,
  )
  // Uppercase the "Guide" range.
  try engine.block.setTextCase(
    text,
    textCase: .uppercase,
    in: "CE.SDK Guide!".range(of: "Guide")!,
  )
  // highlight-textEdit-setFormatting

  try await engine.captureGuide(page, label: "hero")

  // highlight-textEdit-toggleFormatting
  if try engine.block.canToggleBoldFont(text, in: "CE.SDK Guide!".range(of: "Guide")!) {
    try engine.block.toggleBoldFont(text, in: "CE.SDK Guide!".range(of: "Guide")!)
  }
  if try engine.block.canToggleItalicFont(text, in: "CE.SDK Guide!".range(of: "CE.SDK")!) {
    try engine.block.toggleItalicFont(text, in: "CE.SDK Guide!".range(of: "CE.SDK")!)
  }
  // highlight-textEdit-toggleFormatting

  // highlight-textEdit-queryFormatting
  let colors = try engine.block.getTextColors(text)
  let weights = try engine.block.getTextFontWeights(text)
  let styles = try engine.block.getTextFontStyles(text)
  let sizes = try engine.block.getTextFontSizes(text)
  let cases = try engine.block.getTextCases(text)
  print("Colors: \(colors)")
  print("Weights: \(weights), styles: \(styles)")
  print("Sizes: \(sizes), cases: \(cases)")
  // highlight-textEdit-queryFormatting

  // highlight-textEdit-typefaceManagement
  // Apply a different typeface to a range, preserving formatting where possible.
  try engine.block.setTypeface(text, typeface: typeface, in: "CE.SDK Guide!".range(of: "Guide")!)
  // Read back the block's base typeface and the unique typefaces in the block.
  let baseTypeface = try engine.block.getTypeface(text)
  let typefacesInBlock = try engine.block.getTypefaces(text)
  print("Base typeface: \(baseTypeface.name), unique typefaces in block: \(typefacesInBlock.count)")
  // highlight-textEdit-typefaceManagement

  // highlight-textEdit-lineInfo
  let lineCount = try engine.block.getTextVisibleLineCount(text)
  for index in 0 ..< lineCount {
    let content = try engine.block.getTextVisibleLineContent(text, lineIndex: index)
    let bounds = try engine.block.getTextLineBoundingBoxRect(text, index: index)
    print("Line \(index): \"\(content)\" at \(bounds)")
  }
  // highlight-textEdit-lineInfo

  // highlight-textEdit-fontMetrics
  let metrics = try await engine.editor.getFontMetrics(fontFileURI: typeface.fonts[0].uri.absoluteString)
  print(
    "Ascender: \(metrics.ascender), descender: \(metrics.descender), unitsPerEm: \(metrics.unitsPerEm)",
  )
  print(
    "Cap height: \(metrics.capHeight), x-height: \(metrics.xHeight), line gap: \(metrics.lineGap)",
  )
  // highlight-textEdit-fontMetrics
}
