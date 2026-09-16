import Foundation
import IMGLYEngine

@MainActor
func languageSupport(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // Scaffolding: create a scene + page so the rest of the example has somewhere
  // to attach blocks. The reader is expected to have their own scene context.
  let scene = try engine.scene.create(designUnit: .px)

  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 800)

  // highlight-langSupport-typeface
  let roboto = Typeface(
    name: "Roboto",
    fonts: [
      Font(
        uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Regular.ttf"),
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
      Font(
        uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Bold.ttf"),
        subFamily: "Bold",
        weight: .bold,
        style: .normal,
      ),
    ],
  )
  // highlight-langSupport-typeface

  // highlight-langSupport-scriptTypefaces
  let notoArabic = Typeface(
    name: "Noto Sans Arabic",
    fonts: [
      Font(
        uri: baseURL.appendingPathComponent("fonts/font-6.ttf"),
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
    ],
  )

  let notoKorean = Typeface(
    name: "Noto Sans KR",
    fonts: [
      Font(
        uri: baseURL.appendingPathComponent("fonts/font-30.ttf"),
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
    ],
  )
  // highlight-langSupport-scriptTypefaces

  // highlight-langSupport-applyTypeface
  let latinText = try engine.block.create(.text)
  try engine.block.replaceText(latinText, text: "Multilingual typography")
  try engine.block.appendChild(to: page, child: latinText)
  try engine.block.setPositionX(latinText, value: 50)
  try engine.block.setPositionY(latinText, value: 30)
  try engine.block.setWidth(latinText, value: 700)
  try engine.block.setHeight(latinText, value: 80)
  try engine.block.setTextFontSize(latinText, fontSize: 26)
  try engine.block.setTypeface(latinText, typeface: roboto)
  // highlight-langSupport-applyTypeface

  // highlight-langSupport-rangeTypeface
  let mixed = "Mix Roboto Bold and Regular"
  let bold = try engine.block.create(.text)
  try engine.block.replaceText(bold, text: mixed)
  try engine.block.appendChild(to: page, child: bold)
  try engine.block.setPositionX(bold, value: 50)
  try engine.block.setPositionY(bold, value: 140)
  try engine.block.setWidth(bold, value: 700)
  try engine.block.setHeight(bold, value: 50)
  try engine.block.setTextFontSize(bold, fontSize: 20)
  try engine.block.setTypeface(bold, typeface: roboto, in: mixed.range(of: "Roboto Bold")!)
  // highlight-langSupport-rangeTypeface

  // highlight-langSupport-wideScript
  let koreanText = try engine.block.create(.text)
  try engine.block.replaceText(koreanText, text: "안녕하세요 세계")
  try engine.block.appendChild(to: page, child: koreanText)
  try engine.block.setPositionX(koreanText, value: 50)
  try engine.block.setPositionY(koreanText, value: 310)
  try engine.block.setWidth(koreanText, value: 700)
  try engine.block.setHeight(koreanText, value: 80)
  try engine.block.setTextFontSize(koreanText, fontSize: 28)
  try engine.block.setTypeface(koreanText, typeface: notoKorean)
  // highlight-langSupport-wideScript

  // highlight-langSupport-autoAlignment
  try engine.block.setTextHorizontalAlignment(latinText, alignment: .auto)
  // highlight-langSupport-autoAlignment

  // highlight-langSupport-effectiveAlignment
  let arabicText = try engine.block.create(.text)
  try engine.block.replaceText(arabicText, text: "مرحبا بالعالم")
  try engine.block.appendChild(to: page, child: arabicText)
  try engine.block.setPositionX(arabicText, value: 50)
  try engine.block.setPositionY(arabicText, value: 210)
  try engine.block.setWidth(arabicText, value: 700)
  try engine.block.setHeight(arabicText, value: 80)
  try engine.block.setTextFontSize(arabicText, fontSize: 28)
  try engine.block.setTypeface(arabicText, typeface: notoArabic)
  try engine.block.setTextHorizontalAlignment(arabicText, alignment: .right)

  let effective = try engine.block.getTextEffectiveHorizontalAlignment(arabicText)
  print("Effective alignment is right:", effective == .right)
  // highlight-langSupport-effectiveAlignment

  // highlight-langSupport-paragraphAlignment
  let mixedText = try engine.block.create(.text)
  try engine.block.replaceText(mixedText, text: "Heading\nSubtitle\nBody copy")
  try engine.block.appendChild(to: page, child: mixedText)
  try engine.block.setPositionX(mixedText, value: 50)
  try engine.block.setPositionY(mixedText, value: 410)
  try engine.block.setWidth(mixedText, value: 700)
  try engine.block.setHeight(mixedText, value: 220)
  try engine.block.setTextFontSize(mixedText, fontSize: 22)

  // Block-level default — every paragraph without an override inherits this.
  try engine.block.setTextHorizontalAlignment(mixedText, alignment: .left)

  // Override the second paragraph (index 1) only.
  try engine.block.setTextHorizontalAlignment(mixedText, alignment: .right, paragraphIndex: 1)
  // highlight-langSupport-paragraphAlignment

  // highlight-langSupport-readbackAlignment
  let para0 = try engine.block.getTextHorizontalAlignment(mixedText, paragraphIndex: 0)
  let para1 = try engine.block.getTextHorizontalAlignment(mixedText, paragraphIndex: 1)
  let blockDefault = try engine.block.getTextHorizontalAlignment(mixedText)
  print("paragraph 0 inherits block-level:", para0 == nil)
  print("paragraph 1 override:", para1 == .right ? "right" : "other")
  print("block-level default:", blockDefault == .left ? "left" : "other")
  // highlight-langSupport-readbackAlignment

  // highlight-langSupport-clearOverride
  try engine.block.setTextHorizontalAlignment(mixedText, alignment: nil, paragraphIndex: 1)
  // highlight-langSupport-clearOverride

  // highlight-langSupport-paragraphIndices
  let allIndices = try engine.block.getTextParagraphIndices(mixedText)
  print("Paragraph indices:", allIndices)
  // highlight-langSupport-paragraphIndices

  // highlight-langSupport-variables
  try engine.variable.set(key: "greeting", value: "Hello world")

  let dynamicText = try engine.block.create(.text)
  try engine.block.replaceText(dynamicText, text: "{{greeting}}")
  try engine.block.appendChild(to: page, child: dynamicText)
  try engine.block.setPositionX(dynamicText, value: 50)
  try engine.block.setPositionY(dynamicText, value: 660)
  try engine.block.setWidth(dynamicText, value: 700)
  try engine.block.setHeight(dynamicText, value: 80)
  try engine.block.setTextFontSize(dynamicText, fontSize: 22)
  try engine.block.setTypeface(dynamicText, typeface: roboto)

  // Update the variable later to swap the rendered content to a different
  // language — the existing block re-renders with the new value.
  try engine.variable.set(key: "greeting", value: "Bonjour le monde")
  // highlight-langSupport-variables

  try await engine.captureGuide(page, label: "hero")
}
