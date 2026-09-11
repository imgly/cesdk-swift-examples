// highlight-text-adjust-spacing
import Foundation
import IMGLYEngine

@MainActor
func textAdjustSpacing(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: scene, child: text)
  try engine.block.setWidthMode(text, mode: .auto)
  try engine.block.setHeightMode(text, mode: .auto)
  try engine.block.replaceText(text, text: "Hello\nWorld\nCE.SDK")

  // highlight-letter-spacing
  // Set letter spacing — positive values spread characters, negative values tighten them
  try engine.block.setFloat(text, property: "text/letterSpacing", value: Float(0.1))

  // Read the current letter spacing
  _ = try engine.block.getFloat(text, property: "text/letterSpacing")
  // highlight-letter-spacing

  // highlight-line-height
  // Set the block-level line height multiplier — applies to all paragraphs by default
  try engine.block.setFloat(text, property: "text/lineHeight", value: Float(1.5))

  // Read the current block-level line height
  _ = try engine.block.getFloat(text, property: "text/lineHeight")
  // highlight-line-height

  // highlight-paragraph-line-height
  // Set a per-paragraph line height override for paragraph 0 (first paragraph)
  try engine.block.setTextLineHeight(text, lineHeight: 2.0, paragraphIndex: 0)

  // Read the line height for a specific paragraph
  // Returns the override if set, otherwise falls back to the block-level value
  _ = try engine.block.getTextLineHeight(text, paragraphIndex: 0)
  _ = try engine.block.getTextLineHeight(text, paragraphIndex: 1)

  // Clear a paragraph's override by passing nil — it reverts to the block-level value
  try engine.block.setTextLineHeight(text, lineHeight: nil, paragraphIndex: 0)

  // Set the block-level line height and clear all paragraph overrides at once
  try engine.block.setTextLineHeight(text, lineHeight: 1.8)
  // highlight-paragraph-line-height

  // highlight-paragraph-spacing
  // Set paragraph spacing — adds space after each paragraph break
  try engine.block.setFloat(text, property: "text/paragraphSpacing", value: Float(20))

  // Read the current paragraph spacing
  _ = try engine.block.getFloat(text, property: "text/paragraphSpacing")
  // highlight-paragraph-spacing
}

// highlight-text-adjust-spacing
