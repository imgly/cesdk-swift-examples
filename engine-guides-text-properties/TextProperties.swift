import Foundation
import IMGLYEngine

@MainActor
func textProperties(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: scene, child: text)
  try engine.block.setWidthMode(text, mode: .auto)
  try engine.block.setHeightMode(text, mode: .auto)

  // highlight-replaceText
  try engine.block.replaceText(text, text: "Hello World")
  // highlight-replaceText
  // highlight-replaceText-single-index
  // Add a "!" at the end of the text
  try engine.block.replaceText(text, text: "!", in: "Hello World".endIndex ..< "Hello World".endIndex)
  // highlight-replaceText-single-index
  // highlight-replaceText-range
  // Replace "World" with "Alex"
  try engine.block.replaceText(text, text: "Alex", in: "Hello World".range(of: "World")!)
  // highlight-replaceText-range

  try await engine.scene.zoom(to: text, paddingLeft: 100, paddingTop: 100, paddingRight: 100, paddingBottom: 100)

  // highlight-removeText
  // Remove the "Hello "
  try engine.block.removeText(text, from: "Hello Alex".range(of: "Hello ")!)
  // highlight-removeText

  // highlight-setTextColor
  try engine.block.setTextColor(text, color: .rgba(r: 1, g: 1, b: 0))
  // highlight-setTextColor
  // highlight-setTextColor-range
  try engine.block.setTextColor(text, color: .rgba(r: 0, g: 0, b: 0), in: "Alex".range(of: "lex")!)
  // highlight-setTextColor-range
  // highlight-getTextColors
  let allColors = try engine.block.getTextColors(text)
  // highlight-getTextColors
  // highlight-getTextColors-range
  let colorsInRange = try engine.block.getTextColors(text, in: "Alex".range(of: "lex")!)
  // highlight-getTextColors-range

  // highlight-backgroundColor-enabled
  try engine.block.setBool(text, property: "backgroundColor/enabled", value: true)

  // highlight-backgroundColor-get-set
  try engine.block.getColor(text, property: "backgroundColor/color") as Color
  try engine.block.setColor(text, property: "backgroundColor/color", color: .rgba(r: 0.0, g: 0.0, b: 1.0, a: 1.0))

  // highlight-backgroundColor-padding
  try engine.block.setFloat(text, property: "backgroundColor/paddingLeft", value: 1)
  try engine.block.setFloat(text, property: "backgroundColor/paddingTop", value: 2)
  try engine.block.setFloat(text, property: "backgroundColor/paddingRight", value: 3)
  try engine.block.setFloat(text, property: "backgroundColor/paddingBottom", value: 4)

  // highlight-backgroundColor-cornerRadius
  try engine.block.setFloat(text, property: "backgroundColor/cornerRadius", value: 4)

  // highlight-backgroundColor-animation
  let animation = try engine.block.createAnimation(AnimationType.slide)
  try engine.block.setEnum(animation, property: "textAnimationWritingStyle", value: "Block")

  try engine.block.setInAnimation(text, animation: animation)
  try engine.block.setOutAnimation(text, animation: animation)

  // highlight-setTextCase
  try engine.block.setTextCase(text, textCase: .titlecase)
  // highlight-setTextCase

  // highlight-getTextCases
  let textCases = try engine.block.getTextCases(text)
  // highlight-getTextCases

  // highlight-setFont
  let typeface = Typeface(
    name: "Roboto",
    fonts: [
      Font(
        uri: URL(string: "https://cdn.img.ly/assets/v3/ly.img.typeface/fonts/Roboto/Roboto-Bold.ttf")!,
        subFamily: "Bold",
        weight: .bold,
        style: .normal
      ),
      Font(
        uri: URL(string: "https://cdn.img.ly/assets/v3/ly.img.typeface/fonts/Roboto/Roboto-BoldItalic.ttf")!,
        subFamily: "Bold Italic",
        weight: .bold,
        style: .italic
      ),
      Font(
        uri: URL(string: "https://cdn.img.ly/assets/v3/ly.img.typeface/fonts/Roboto/Roboto-Italic.ttf")!,
        subFamily: "Italic",
        weight: .normal,
        style: .italic
      ),
      Font(
        uri: URL(string: "https://cdn.img.ly/assets/v3/ly.img.typeface/fonts/Roboto/Roboto-Regular.ttf")!,
        subFamily: "Regular",
        weight: .normal,
        style: .normal
      ),
    ]
  )
  try engine.block.setFont(text, fontFileURL: typeface.fonts[3].uri, typeface: typeface)
  // highlight-setFont

  // highlight-setTypeface
  try engine.block.setTypeface(text, typeface: typeface, in: "Alex".range(of: "lex")!)
  try engine.block.setTypeface(text, typeface: typeface)
  // highlight-setTypeface

  // highlight-getTypeface
  let currentDefaultTypeface = try engine.block.getTypeface(text)
  // highlight-getTypeface

  // highlight-getTypefaces
  let currentTypefaces = try engine.block.getTypefaces(text)
  let currentTypefacesOfRange = try engine.block.getTypefaces(text, in: "Alex".range(of: "lex")!)
  // highlight-getTypefaces

  // highlight-toggleBold
  if try engine.block.canToggleBoldFont(text) {
    try engine.block.toggleBoldFont(text)
  }
  if try engine.block.canToggleBoldFont(text, in: "Alex".range(of: "lex")!) {
    try engine.block.toggleBoldFont(text, in: "Alex".range(of: "lex")!)
  }
  // highlight-toggleBold

  // highlight-toggleItalic
  if try engine.block.canToggleItalicFont(text) {
    try engine.block.toggleItalicFont(text)
  }
  if try engine.block.canToggleItalicFont(text, in: "Alex".range(of: "lex")!) {
    try engine.block.toggleItalicFont(text, in: "Alex".range(of: "lex")!)
  }
  // highlight-toggleItalic

  // highlight-getTextFontWeights
  let fontWeights = try engine.block.getTextFontWeights(text)
  // highlight-getTextFontWeights

  // highlight-getTextFontStyles
  let fontStyles = try engine.block.getTextFontStyles(text)
  // highlight-getTextFontStyles
}
