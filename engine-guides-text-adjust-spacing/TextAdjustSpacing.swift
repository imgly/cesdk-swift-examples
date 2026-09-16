import Foundation
import IMGLYEngine

@MainActor
func textAdjustSpacing(engine: Engine) async throws {
  // Demo scaffolding: a Pixel-unit page with a styled multi-paragraph text block
  // so each spacing change is visibly demonstrable in the captured exports.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 800)
  try engine.block.appendChild(to: scene, child: page)

  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: text)
  try engine.block.setWidthMode(text, mode: .auto)
  try engine.block.setHeightMode(text, mode: .auto)
  try engine.block.replaceText(text, text: "Hello\nWorld\nCE.SDK")
  try engine.block.setFloat(text, property: "text/fontSize", value: 60)
  try engine.block.setPositionX(text, value: 200)
  try engine.block.setPositionY(text, value: 100)

  // highlight-letter-spacing
  try engine.block.setFloat(text, property: "text/letterSpacing", value: 0.1)
  let letterSpacing = try engine.block.getFloat(text, property: "text/letterSpacing")
  print("Letter spacing: \(letterSpacing)")
  // highlight-letter-spacing

  try await engine.captureGuide(page, label: "after-letter-spacing")

  // highlight-line-height
  try engine.block.setFloat(text, property: "text/lineHeight", value: 1.5)
  let lineHeight = try engine.block.getFloat(text, property: "text/lineHeight")
  print("Block-level line height: \(lineHeight)")
  // highlight-line-height

  try await engine.captureGuide(page, label: "after-line-height")

  // highlight-paragraph-line-height
  // Override paragraph 0; paragraph 1 still reads the block-level value.
  try engine.block.setTextLineHeight(text, lineHeight: 2.0, paragraphIndex: 0)
  let paragraph0LineHeight = try engine.block.getTextLineHeight(text, paragraphIndex: 0)
  let paragraph1LineHeight = try engine.block.getTextLineHeight(text, paragraphIndex: 1)
  print("Paragraph 0: \(paragraph0LineHeight)")
  print("Paragraph 1: \(paragraph1LineHeight)")

  // Pass nil for lineHeight to clear the override; paragraph 0 reverts to the block-level value.
  try engine.block.setTextLineHeight(text, lineHeight: nil, paragraphIndex: 0)
  let clearedParagraph0LineHeight = try engine.block.getTextLineHeight(text, paragraphIndex: 0)
  print("Paragraph 0 after clearing: \(clearedParagraph0LineHeight)")

  // Omit paragraphIndex to update the block-level value and clear every paragraph override.
  try engine.block.setTextLineHeight(text, lineHeight: 1.8)
  let resetBlockLineHeight = try engine.block.getTextLineHeight(text, paragraphIndex: 1)
  print("Block-level after reset: \(resetBlockLineHeight)")
  // highlight-paragraph-line-height

  // highlight-paragraph-spacing
  try engine.block.setFloat(text, property: "text/paragraphSpacing", value: 1.2)
  let paragraphSpacing = try engine.block.getFloat(text, property: "text/paragraphSpacing")
  print("Paragraph spacing: \(paragraphSpacing)")
  // highlight-paragraph-spacing

  try await engine.captureGuide(page, label: "hero")
}
