// highlight-text-script-style
import Foundation
import IMGLYEngine

@MainActor
func scriptStyle(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: scene, child: text)
  try engine.block.setWidthMode(text, mode: .auto)
  try engine.block.setHeightMode(text, mode: .auto)
  let content = "$1999 H2O E=mc2"
  try engine.block.replaceText(text, text: content)

  // highlight-superscript
  // Raise the cents of the price above the baseline.
  // Superscript text is scaled down and raised automatically.
  let cents = content.index(content.startIndex, offsetBy: 3) ..< content.index(content.startIndex, offsetBy: 5)
  try engine.block.setTextScriptStyle(text, scriptStyle: .superscript, in: cents)

  // Raise the exponent of the formula
  let exponent = content.index(content.startIndex, offsetBy: 14) ..< content.endIndex
  try engine.block.setTextScriptStyle(text, scriptStyle: .superscript, in: exponent)
  // highlight-superscript

  // highlight-subscript
  // Lower the "2" of the water formula below the baseline
  let waterDigit = content.index(content.startIndex, offsetBy: 7) ..< content.index(content.startIndex, offsetBy: 8)
  try engine.block.setTextScriptStyle(text, scriptStyle: .subscript, in: waterDigit)
  // highlight-subscript

  // highlight-query-scriptStyles
  // Query the unique script styles in a range, in document order
  let scriptStyles = try engine.block.getTextScriptStyles(text)
  // e.g. [.normal, .superscript, .subscript]

  // Query a specific range
  let centsScriptStyle = try engine.block.getTextScriptStyles(text, in: cents)
  // [.superscript]
  // highlight-query-scriptStyles

  // highlight-text-runs
  // Each text run reports its script style
  let runs = try engine.block.getTextRuns(text)
  // e.g. runs[1].scriptStyle == .superscript
  // highlight-text-runs

  // highlight-adjust
  // Adjust the size and position of shifted text for the whole block.
  // The scale is a factor of the font size. The shift is a fraction of
  // the unscaled font size.
  try engine.block.setFloat(text, property: "text/superscriptFontScale", value: 0.65)
  try engine.block.setFloat(text, property: "text/superscriptVerticalShift", value: 0.4)
  try engine.block.setFloat(text, property: "text/subscriptFontScale", value: 0.65)
  try engine.block.setFloat(text, property: "text/subscriptVerticalShift", value: 0.25)
  // highlight-adjust

  // highlight-reset
  // Reset a range back to the normal baseline
  try engine.block.setTextScriptStyle(text, scriptStyle: .normal, in: exponent)
  // highlight-reset

  _ = scriptStyles
  _ = centsScriptStyle
  _ = runs
}

// highlight-text-script-style
