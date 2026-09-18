import Foundation
import IMGLYEngine

@MainActor
func addText(engine: Engine) async throws {
  // Demo scaffolding: a Pixel-unit page so `text/fontSize` literals interpret
  // as pixels and the captured exports show the rendered output at its
  // intended scale.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 960)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-addText-create
  let titleBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: titleBlock)
  try engine.block.replaceText(titleBlock, text: "Welcome to CE.SDK")

  try engine.block.setWidthMode(titleBlock, mode: .auto)
  try engine.block.setHeightMode(titleBlock, mode: .auto)
  try engine.block.setPositionX(titleBlock, value: 40)
  try engine.block.setPositionY(titleBlock, value: 40)
  // highlight-addText-create

  // The example builds font file URLs from a base URL that points at the
  // CE.SDK asset location. Replace it with wherever your app bundles or hosts
  // the CE.SDK font assets.
  let baseURL = try engine.guidesBaseURL

  // highlight-addText-set-font
  let caveatRegular = Font(
    uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Caveat/Caveat-Regular.ttf"),
    subFamily: "Regular",
    weight: .normal,
    style: .normal,
  )
  let caveatBold = Font(
    uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Caveat/Caveat-Bold.ttf"),
    subFamily: "Bold",
    weight: .bold,
    style: .normal,
  )
  let caveatTypeface = Typeface(name: "Caveat", fonts: [caveatRegular, caveatBold])

  try engine.block.setFont(titleBlock, fontFileURL: caveatBold.uri, typeface: caveatTypeface)
  try engine.block.setTextFontSize(titleBlock, fontSize: 48)
  // highlight-addText-set-font

  // highlight-addText-font-variants
  let robotoRegular = Font(
    uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Regular.ttf"),
    subFamily: "Regular",
    weight: .normal,
    style: .normal,
  )
  let robotoTypeface = Typeface(
    name: "Roboto",
    fonts: [
      robotoRegular,
      Font(
        uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Bold.ttf"),
        subFamily: "Bold",
        weight: .bold,
        style: .normal,
      ),
      Font(
        uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Italic.ttf"),
        subFamily: "Italic",
        weight: .normal,
        style: .italic,
      ),
      Font(
        uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-BoldItalic.ttf"),
        subFamily: "Bold Italic",
        weight: .bold,
        style: .italic,
      ),
    ],
  )
  // highlight-addText-font-variants

  // Scaffolding: a second text block, fixed to the page width so the range
  // styling below wraps within the page. The styling snippet operates on it.
  let richText = "Rich text with colors and styles"
  let richTextBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: richTextBlock)
  try engine.block.replaceText(richTextBlock, text: richText)
  try engine.block.setPositionX(richTextBlock, value: 40)
  try engine.block.setPositionY(richTextBlock, value: 140)
  try engine.block.setWidth(richTextBlock, value: 720)
  try engine.block.setWidthMode(richTextBlock, mode: .absolute)
  try engine.block.setHeightMode(richTextBlock, mode: .auto)
  try engine.block.setTextFontSize(richTextBlock, fontSize: 48)
  try engine.block.setFont(richTextBlock, fontFileURL: robotoRegular.uri, typeface: robotoTypeface)

  // highlight-addText-rich-text-styling
  // "Rich" in blue.
  try engine.block.setTextColor(richTextBlock, color: .rgba(r: 0.2, g: 0.4, b: 0.8), in: richText.range(of: "Rich")!)
  // "text" in bold.
  try engine.block.setTextFontWeight(richTextBlock, fontWeight: .bold, in: richText.range(of: "text")!)
  // "with" in italic.
  try engine.block.setTextFontStyle(richTextBlock, fontStyle: .italic, in: richText.range(of: "with")!)
  // "colors" in orange and larger type.
  try engine.block.setTextColor(richTextBlock, color: .rgba(r: 0.9, g: 0.5, b: 0.1), in: richText.range(of: "colors")!)
  try engine.block.setTextFontSize(richTextBlock, fontSize: 56, in: richText.range(of: "colors")!)
  // "and" uses a different typeface.
  try engine.block.setTypeface(richTextBlock, typeface: caveatTypeface, in: richText.range(of: "and")!)
  // "styles" in green uppercase.
  try engine.block.setTextColor(richTextBlock, color: .rgba(r: 0.2, g: 0.7, b: 0.3), in: richText.range(of: "styles")!)
  try engine.block.setTextCase(richTextBlock, textCase: .uppercase, in: richText.range(of: "styles")!)
  // highlight-addText-rich-text-styling

  try await engine.captureGuide(page, label: "after-rich-text")

  // highlight-addText-auto-sizing
  let autoSizeBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: autoSizeBlock)
  try engine.block.replaceText(autoSizeBlock, text: "Auto-sizing text block")
  try engine.block.setPositionX(autoSizeBlock, value: 40)
  try engine.block.setPositionY(autoSizeBlock, value: 300)

  try engine.block.setWidth(autoSizeBlock, value: 720)
  try engine.block.setWidthMode(autoSizeBlock, mode: .absolute)
  try engine.block.setHeightMode(autoSizeBlock, mode: .auto)
  try engine.block.setTextFontSize(autoSizeBlock, fontSize: 48)
  // highlight-addText-auto-sizing

  // highlight-addText-text-case
  let caseBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: caseBlock)
  try engine.block.replaceText(caseBlock, text: "uppercase text")
  try engine.block.setPositionX(caseBlock, value: 40)
  try engine.block.setPositionY(caseBlock, value: 420)
  try engine.block.setWidthMode(caseBlock, mode: .auto)
  try engine.block.setHeightMode(caseBlock, mode: .auto)
  try engine.block.setTextFontSize(caseBlock, fontSize: 48)

  try engine.block.setTextCase(caseBlock, textCase: .uppercase)
  // highlight-addText-text-case

  // highlight-addText-text-alignment
  let alignedBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: alignedBlock)
  try engine.block.replaceText(alignedBlock, text: "Centered Text\nWith Line Spacing")
  try engine.block.setPositionX(alignedBlock, value: 40)
  try engine.block.setPositionY(alignedBlock, value: 540)
  try engine.block.setWidth(alignedBlock, value: 720)
  try engine.block.setWidthMode(alignedBlock, mode: .absolute)
  try engine.block.setHeightMode(alignedBlock, mode: .auto)
  try engine.block.setTextFontSize(alignedBlock, fontSize: 48)

  try engine.block.setTextHorizontalAlignment(alignedBlock, alignment: .center)
  try engine.block.setTextLineHeight(alignedBlock, lineHeight: 1.5)
  try engine.block.setFloat(alignedBlock, property: "text/letterSpacing", value: 0.05)
  // highlight-addText-text-alignment

  // Scaffolding: a block styled with all four Roboto variants so both toggles
  // have a matching counterpart variant to switch to.
  let toggleText = "Toggle Bold and Italic"
  let toggleBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: toggleBlock)
  try engine.block.replaceText(toggleBlock, text: toggleText)
  try engine.block.setPositionX(toggleBlock, value: 40)
  try engine.block.setPositionY(toggleBlock, value: 740)
  try engine.block.setWidthMode(toggleBlock, mode: .auto)
  try engine.block.setHeightMode(toggleBlock, mode: .auto)
  try engine.block.setTextFontSize(toggleBlock, fontSize: 48)
  try engine.block.setFont(toggleBlock, fontFileURL: robotoRegular.uri, typeface: robotoTypeface)

  // highlight-addText-toggle-bold-italic
  let boldRange = toggleText.range(of: "Bold")!
  if try engine.block.canToggleBoldFont(toggleBlock, in: boldRange) {
    try engine.block.toggleBoldFont(toggleBlock, in: boldRange)
  }

  let italicRange = toggleText.range(of: "Italic")!
  if try engine.block.canToggleItalicFont(toggleBlock, in: italicRange) {
    try engine.block.toggleItalicFont(toggleBlock, in: italicRange)
  }
  // highlight-addText-toggle-bold-italic

  // highlight-addText-modify-text
  let helloWorld = "Hello World"
  let modifyBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: modifyBlock)
  try engine.block.replaceText(modifyBlock, text: helloWorld)
  try engine.block.setPositionX(modifyBlock, value: 40)
  try engine.block.setPositionY(modifyBlock, value: 840)
  try engine.block.setWidthMode(modifyBlock, mode: .auto)
  try engine.block.setHeightMode(modifyBlock, mode: .auto)
  try engine.block.setTextFontSize(modifyBlock, fontSize: 48)

  // Replace "World" while keeping the surrounding text.
  try engine.block.replaceText(modifyBlock, text: "CE.SDK", in: helloWorld.range(of: "World")!)
  // Remove the leading "Hello " to leave just "CE.SDK".
  try engine.block.removeText(modifyBlock, from: "Hello CE.SDK".range(of: "Hello ")!)
  // highlight-addText-modify-text

  try await engine.captureGuide(page, label: "hero")
}
