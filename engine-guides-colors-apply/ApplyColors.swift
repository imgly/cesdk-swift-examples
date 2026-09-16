import IMGLYEngine

@MainActor
func applyColors(engine: Engine) async throws {
  // Demo scaffolding: a scene with a page and a single graphic block to recolor.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  try engine.block.setWidth(block, value: 400)
  try engine.block.setHeight(block, value: 300)
  try engine.block.setPositionX(block, value: 200)
  try engine.block.setPositionY(block, value: 150)
  try engine.block.appendChild(to: page, child: block)

  // highlight-applyColors-createColors
  let rgbaBlue = Color.rgba(r: 0.0, g: 0.0, b: 1.0, a: 1.0)
  let cmykRed = Color.cmyk(c: 0.0, m: 1.0, y: 1.0, k: 0.0, tint: 1.0)
  let spotPink = Color.spot(name: "Pink-Flamingo", tint: 1.0, externalReference: "Brand-Colors")
  // highlight-applyColors-createColors

  // highlight-applyColors-defineSpot
  engine.editor.setSpotColor(name: "Pink-Flamingo", r: 1.0, g: 0.41, b: 0.71)
  engine.editor.setSpotColor(name: "Corporate-Blue", c: 1.0, m: 0.5, y: 0.0, k: 0.2)
  // highlight-applyColors-defineSpot

  // highlight-applyColors-applyFill
  let fill = try engine.block.getFill(block)
  try engine.block.setColor(fill, property: "fill/color/value", color: rgbaBlue)
  // highlight-applyColors-applyFill

  try await engine.captureGuide(page, label: "after-fill")

  // highlight-applyColors-readColor
  let currentFillColor: Color = try engine.block.getColor(fill, property: "fill/color/value")
  print("Current fill color: \(currentFillColor)")
  // highlight-applyColors-readColor

  // highlight-applyColors-applyStroke
  try engine.block.setStrokeEnabled(block, enabled: true)
  try engine.block.setStrokeWidth(block, width: 4)
  try engine.block.setColor(block, property: "stroke/color", color: cmykRed)
  // highlight-applyColors-applyStroke

  try await engine.captureGuide(page, label: "after-stroke")

  // highlight-applyColors-applyShadow
  try engine.block.setDropShadowEnabled(block, enabled: true)
  try engine.block.setDropShadowOffsetX(block, offsetX: 5)
  try engine.block.setDropShadowOffsetY(block, offsetY: 5)
  try engine.block.setColor(block, property: "dropShadow/color", color: spotPink)
  // highlight-applyColors-applyShadow

  try await engine.captureGuide(page, label: "hero")

  // highlight-applyColors-convertColor
  let cmykFromRgb = try engine.editor.convertColorToColorSpace(color: rgbaBlue, colorSpace: .cmyk)
  let rgbFromCmyk = try engine.editor.convertColorToColorSpace(color: cmykRed, colorSpace: .sRGB)
  print("CMYK from RGB: \(cmykFromRgb)")
  print("RGB from CMYK: \(rgbFromCmyk)")
  // highlight-applyColors-convertColor

  // highlight-applyColors-listSpot
  let allSpotColors = engine.editor.findAllSpotColors()
  print("Defined spot colors: \(allSpotColors)")
  // highlight-applyColors-listSpot

  // highlight-applyColors-updateSpot
  engine.editor.setSpotColor(name: "Pink-Flamingo", r: 1.0, g: 0.6, b: 0.8)
  // highlight-applyColors-updateSpot

  // highlight-applyColors-removeSpot
  try engine.editor.removeSpotColor(name: "Corporate-Blue")
  // highlight-applyColors-removeSpot
}
