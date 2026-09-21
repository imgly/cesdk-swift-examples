import Foundation
import IMGLYEngine

@MainActor
func fontSizeUnit(engine: Engine) async throws {
  // highlight-fontSizeUnit-setup
  // Create a default Pixel-based design scene. With designUnit `.px` and no
  // explicit fontSizeUnit, the engine pairs them and uses `.px` for fonts too.
  let scene = try engine.scene.create(designUnit: .px)

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1080)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-fontSizeUnit-setup

  // highlight-fontSizeUnit-getUnit
  // Read the scene's current font-size unit.
  // For a Pixel-based scene this defaults to `.px`.
  let initialUnit = try engine.scene.getFontSizeUnit()
  print("Initial font-size unit:", initialUnit) // .px
  // highlight-fontSizeUnit-getUnit

  // highlight-fontSizeUnit-setUnit
  // Switch the scene-wide default to Point. Existing text keeps its visual
  // size; only the unit used by `setTextFontSize` and `getTextFontSizes`
  // changes.
  try engine.scene.setFontSizeUnit(.pt)
  print("After switch:", try engine.scene.getFontSizeUnit()) // .pt
  // highlight-fontSizeUnit-setUnit

  // Add a text block to demonstrate how the unit flows through the text APIs.
  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: text)
  try engine.block.setString(text, property: "text/text", value: "Font Size Unit")
  try engine.block.setPositionX(text, value: 80)
  try engine.block.setPositionY(text, value: 480)
  try engine.block.setWidth(text, value: 920)
  try engine.block.setHeight(text, value: 120)

  // highlight-fontSizeUnit-implicitSet
  // The value is interpreted in the scene's `fontSizeUnit`, which is now
  // Point. The engine reads this as 18 pt.
  try engine.block.setTextFontSize(text, fontSize: 18)

  // The float properties `text/fontSize`, `caption/fontSize`, and the
  // matching auto-min/max companions use the same `fontSizeUnit`.
  try engine.block.setFloat(text, property: "text/fontSize", value: 18)
  // highlight-fontSizeUnit-implicitSet

  // highlight-fontSizeUnit-overridePerCall
  // The Swift binding does not expose a per-call unit option. To set a font
  // size in a different unit, switch the scene unit, perform the call, then
  // restore it. The engine converts using the scene's DPI so visual sizes
  // stay consistent.
  let savedUnit = try engine.scene.getFontSizeUnit()
  try engine.scene.setFontSizeUnit(.px)
  try engine.block.setTextFontSize(text, fontSize: 24) // interpreted as 24 px
  try engine.scene.setFontSizeUnit(savedUnit)
  // highlight-fontSizeUnit-overridePerCall

  // highlight-fontSizeUnit-readSizes
  // `getTextFontSizes` returns values in the scene's unit (currently Point).
  let sizesInSceneUnit = try engine.block.getTextFontSizes(text)
  print("Sizes (scene unit, pt):", sizesInSceneUnit)

  // `getFloat` reads `text/fontSize` in the same unit as `getTextFontSizes`.
  let propertySize = try engine.block.getFloat(text, property: "text/fontSize")
  print("text/fontSize (scene unit, pt):", propertySize)

  // To read in a different unit, switch the scene unit, read, then restore.
  try engine.scene.setFontSizeUnit(.px)
  let sizesInPixels = try engine.block.getTextFontSizes(text)
  try engine.scene.setFontSizeUnit(savedUnit)
  print("Sizes (px):", sizesInPixels)
  // highlight-fontSizeUnit-readSizes

  // highlight-fontSizeUnit-createWithUnits
  // When you create a scene yourself, you can pair both units explicitly.
  // If `fontSizeUnit` is omitted, the engine pairs it with `designUnit`:
  // `.px` design ⇒ `.px` font, `.mm` and `.in` ⇒ `.pt` font.
  _ = try engine.scene.create(designUnit: .px, fontSizeUnit: .pt)
  // highlight-fontSizeUnit-createWithUnits
}
