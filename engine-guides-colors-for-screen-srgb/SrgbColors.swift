import IMGLYEngine

@MainActor
func srgbColors(engine: Engine) async throws {
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

  // highlight-srgbColors-createRgba
  let rgbaBlue = Color.rgba(r: 0.2, g: 0.4, b: 0.9)
  let rgbaRed = Color.rgba(r: 0.85, g: 0.1, b: 0.1, a: 1.0)
  // highlight-srgbColors-createRgba

  // highlight-srgbColors-createTransparent
  let semiTransparentBlack = Color.rgba(r: 0.0, g: 0.0, b: 0.0, a: 0.5)
  // highlight-srgbColors-createTransparent

  // highlight-srgbColors-applyFill
  let fill = try engine.block.getFill(block)
  try engine.block.setColor(fill, property: "fill/color/value", color: rgbaBlue)
  // highlight-srgbColors-applyFill

  try await engine.captureGuide(page, label: "after-fill")

  // highlight-srgbColors-applyStroke
  try engine.block.setStrokeEnabled(block, enabled: true)
  try engine.block.setStrokeWidth(block, width: 8)
  try engine.block.setColor(block, property: "stroke/color", color: rgbaRed)
  // highlight-srgbColors-applyStroke

  try await engine.captureGuide(page, label: "after-stroke")

  // highlight-srgbColors-applyShadow
  try engine.block.setDropShadowEnabled(block, enabled: true)
  try engine.block.setDropShadowOffsetX(block, offsetX: 15)
  try engine.block.setDropShadowOffsetY(block, offsetY: 15)
  try engine.block.setColor(block, property: "dropShadow/color", color: semiTransparentBlack)
  // highlight-srgbColors-applyShadow

  try await engine.captureGuide(page, label: "hero")

  // highlight-srgbColors-getColor
  let currentColor: Color = try engine.block.getColor(fill, property: "fill/color/value")
  print("Current fill color: \(currentColor)")
  // highlight-srgbColors-getColor

  // highlight-srgbColors-identifyRgba
  if case let .rgba(r, g, b, a) = currentColor {
    print("sRGB color - r: \(r), g: \(g), b: \(b), a: \(a)")
  }
  // highlight-srgbColors-identifyRgba

  // highlight-srgbColors-convertToSrgb
  let cmykOrange = Color.cmyk(c: 0.0, m: 0.5, y: 1.0, k: 0.0, tint: 1.0)
  let convertedToSrgb = try engine.editor.convertColorToColorSpace(color: cmykOrange, colorSpace: .sRGB)
  print("CMYK converted to sRGB: \(convertedToSrgb)")
  // highlight-srgbColors-convertToSrgb
}
