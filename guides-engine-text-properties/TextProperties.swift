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

  // highlight-getTextFontWeights
  let fontWeights = try engine.block.getTextFontWeights(text)
  // highlight-getTextFontWeights

  // highlight-getTextFontStyles
  let fontStyles = try engine.block.getTextFontStyles(text)
  // highlight-getTextFontStyles

  // highlight-setTextCase
  try engine.block.setTextCase(text, textCase: .titlecase)
  // highlight-setTextCase

  // highlight-getTextCases
  let textCases = try engine.block.getTextCases(text)
  // highlight-getTextCases
}
