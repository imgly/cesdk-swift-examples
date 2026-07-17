import Foundation
import IMGLYEngine

@MainActor
func textAutoSize(engine: Engine) async throws {
  // Demo scaffolding: a page with a cream background frames the text blocks below.
  // The Pixel design unit pairs the font-size unit to Pixel, so `setTextFontSize`
  // values are interpreted as pixels — matching the dimensions and positions below.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let background = try engine.block.create(.graphic)
  try engine.block.setShape(background, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(background, value: 800)
  try engine.block.setHeight(background, value: 600)
  try engine.block.setFill(background, fill: engine.block.createFill(.color))
  let backgroundFill = try engine.block.getFill(background)
  try engine.block.setColor(
    backgroundFill,
    property: "fill/color/value",
    color: .rgba(r: 0.969, g: 0.957, b: 0.937, a: 1.0),
  )
  try engine.block.appendChild(to: page, child: background)

  // highlight-auto-width-height
  let autoText = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: autoText)
  try engine.block.setWidthMode(autoText, mode: .auto)
  try engine.block.setHeightMode(autoText, mode: .auto)
  try engine.block.replaceText(autoText, text: "Auto-sized text")
  try engine.block.setTextFontSize(autoText, fontSize: 36)
  try engine.block.setTextColor(autoText, color: .rgba(r: 0.122, g: 0.161, b: 0.216, a: 1.0))
  try engine.block.setPositionX(autoText, value: 40)
  try engine.block.setPositionY(autoText, value: 30)
  // highlight-auto-width-height

  // highlight-fixed-width-auto-height
  let wrappedText = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: wrappedText)
  try engine.block.setWidthMode(wrappedText, mode: .absolute)
  try engine.block.setWidth(wrappedText, value: 320)
  try engine.block.setHeightMode(wrappedText, mode: .auto)
  try engine.block.replaceText(
    wrappedText,
    text: "Fixed width and auto height, so this text wraps to multiple lines.",
  )
  try engine.block.setTextFontSize(wrappedText, fontSize: 28)
  try engine.block.setTextColor(wrappedText, color: .rgba(r: 0.200, g: 0.255, b: 0.333, a: 1.0))
  try engine.block.setPositionX(wrappedText, value: 40)
  try engine.block.setPositionY(wrappedText, value: 110)
  // highlight-fixed-width-auto-height

  // highlight-query-size-modes
  let widthMode = try engine.block.getWidthMode(autoText)
  let heightMode = try engine.block.getHeightMode(autoText)
  print("Auto text size modes — width is .auto:", widthMode == .auto)
  print("Auto text size modes — height is .auto:", heightMode == .auto)
  // highlight-query-size-modes

  // highlight-automatic-font-sizing
  let scaledText = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: scaledText)
  try engine.block.setWidthMode(scaledText, mode: .absolute)
  try engine.block.setHeightMode(scaledText, mode: .absolute)
  try engine.block.setWidth(scaledText, value: 320)
  try engine.block.setHeight(scaledText, value: 70)
  try engine.block.setBool(scaledText, property: "text/automaticFontSizeEnabled", value: true)
  try engine.block.replaceText(scaledText, text: "Auto-scaled font")
  try engine.block.setTextColor(scaledText, color: .rgba(r: 0.114, g: 0.306, b: 0.847, a: 1.0))
  try engine.block.setPositionX(scaledText, value: 40)
  try engine.block.setPositionY(scaledText, value: 340)
  // highlight-automatic-font-sizing

  // highlight-font-size-constraints
  let constrainedText = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: constrainedText)
  try engine.block.setWidthMode(constrainedText, mode: .absolute)
  try engine.block.setHeightMode(constrainedText, mode: .absolute)
  try engine.block.setWidth(constrainedText, value: 320)
  try engine.block.setHeight(constrainedText, value: 70)
  try engine.block.setBool(constrainedText, property: "text/automaticFontSizeEnabled", value: true)
  try engine.block.setFloat(constrainedText, property: "text/minAutomaticFontSize", value: 12)
  try engine.block.setFloat(constrainedText, property: "text/maxAutomaticFontSize", value: 48)
  try engine.block.replaceText(
    constrainedText,
    text: "Edit this text to see automatic font scaling in a 12-48 pt range",
  )
  try engine.block.setTextColor(constrainedText, color: .rgba(r: 0.486, g: 0.176, b: 0.071, a: 1.0))
  try engine.block.setPositionX(constrainedText, value: 40)
  try engine.block.setPositionY(constrainedText, value: 440)
  // highlight-font-size-constraints

  // highlight-query-automatic-font-size
  let isAutomaticFontSizeEnabled = try engine.block.getBool(
    scaledText,
    property: "text/automaticFontSizeEnabled",
  )
  let minAutomaticFontSize = try engine.block.getFloat(
    constrainedText,
    property: "text/minAutomaticFontSize",
  )
  let maxAutomaticFontSize = try engine.block.getFloat(
    constrainedText,
    property: "text/maxAutomaticFontSize",
  )
  print("Automatic font size enabled:", isAutomaticFontSizeEnabled)
  print("Automatic font size range:", minAutomaticFontSize, "-", maxAutomaticFontSize)
  // highlight-query-automatic-font-size

  // highlight-text-clipping
  let clippedText = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: clippedText)
  try engine.block.setWidthMode(clippedText, mode: .absolute)
  try engine.block.setHeightMode(clippedText, mode: .absolute)
  try engine.block.setWidth(clippedText, value: 320)
  try engine.block.setHeight(clippedText, value: 60)
  try engine.block.replaceText(
    clippedText,
    text: "This line fits.\nThis line overflows.\nThis line is clipped.",
  )
  try engine.block.setTextFontSize(clippedText, fontSize: 32)
  try engine.block.setBool(clippedText, property: "text/clipLinesOutsideOfFrame", value: true)
  try engine.block.setTextColor(clippedText, color: .rgba(r: 0.6, g: 0.106, b: 0.106, a: 1.0))
  try engine.block.setPositionX(clippedText, value: 440)
  try engine.block.setPositionY(clippedText, value: 110)
  // highlight-text-clipping

  try await engine.captureGuide(page, label: "hero")

  // highlight-text-clipping-query
  try await Task.sleep(nanoseconds: 16_000_000)
  let hasClippedLines = try engine.block.getBool(
    clippedText,
    property: "text/hasClippedLines",
  )
  print("Clipped lines detected:", hasClippedLines)
  // highlight-text-clipping-query
}
