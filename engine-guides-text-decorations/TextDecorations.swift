// highlight-text-decorations
import Foundation
import IMGLYEngine

@MainActor
func textDecorations(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: scene, child: text)
  try engine.block.setWidthMode(text, mode: .auto)
  try engine.block.setHeightMode(text, mode: .auto)
  try engine.block.replaceText(text, text: "Hello CE.SDK")

  // highlight-toggle-decorations
  // Toggle underline on the entire text
  try engine.block.toggleTextDecorationUnderline(text)

  // Toggle strikethrough on the entire text
  try engine.block.toggleTextDecorationStrikethrough(text)

  // Toggle overline on the entire text
  try engine.block.toggleTextDecorationOverline(text)

  // Calling toggle again removes the decoration
  try engine.block.toggleTextDecorationOverline(text)
  // highlight-toggle-decorations

  // highlight-query-decorations
  // Query the current decoration configurations
  // Returns a list of unique TextDecorationConfig values in the range
  let decorations = try engine.block.getTextDecorations(text)
  // Each config contains: line, style, underlineColor, underlineThickness, underlineOffset, skipInk
  // highlight-query-decorations

  // highlight-custom-style
  // Set a specific decoration style
  // Available styles: .solid, .double, .dotted, .dashed, .wavy
  try engine.block.setTextDecoration(text, config: TextDecorationConfig(
    line: .underline,
    style: .dashed,
  ))
  // highlight-custom-style

  // highlight-underline-color
  // Set a custom underline color (only applies to underlines)
  // Strikethrough and overline always use the text color
  try engine.block.setTextDecoration(text, config: TextDecorationConfig(
    line: .underline,
    underlineColor: .rgba(r: 1, g: 0, b: 0, a: 1),
  ))
  // highlight-underline-color

  // highlight-thickness
  // Adjust the underline thickness
  // Default is 1.0, values above 1.0 make the line thicker
  try engine.block.setTextDecoration(text, config: TextDecorationConfig(
    line: .underline,
    underlineThickness: 2.0,
  ))
  // highlight-thickness

  // highlight-offset
  // Adjust the underline position relative to the font default
  // 0 = font default, positive values move further from baseline, negative values move closer
  try engine.block.setTextDecoration(text, config: TextDecorationConfig(
    line: .underline,
    underlineOffset: 0.1,
  ))
  // highlight-offset

  // highlight-subrange
  // Apply decorations to a specific character range using Range<String.Index>
  let currentText = try engine.block.getString(text, property: "text/text")
  let helloRange = currentText.startIndex ..< currentText.index(currentText.startIndex, offsetBy: 5)

  // Toggle underline on "Hello"
  try engine.block.toggleTextDecorationUnderline(text, in: helloRange)

  // Query decorations in a specific range
  let subrangeDecorations = try engine.block.getTextDecorations(text, in: helloRange)
  // highlight-subrange

  // highlight-combine
  // Combine multiple decoration lines on the same text
  // All active lines share the same style and thickness
  try engine.block.setTextDecoration(text, config: TextDecorationConfig(
    line: [.underline, .strikethrough],
  ))
  // highlight-combine

  // highlight-remove
  // Remove all decorations
  try engine.block.setTextDecoration(text, config: TextDecorationConfig())
  // highlight-remove

  _ = decorations
  _ = subrangeDecorations
}

// highlight-text-decorations
