import IMGLYEngine

@MainActor
func textEffects(engine: Engine) async throws {
  // Demo scaffolding: an 800×500 page with a light off-white background so the
  // dark shadow and the blue outline both stay readable. Creating the scene
  // with `designUnit: .px` pairs the font-size unit to Pixel, so the literal
  // `setTextFontSize` values below render at the dimensions the layout
  // positions assume.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 500)
  try engine.block.appendChild(to: scene, child: page)

  let background = try engine.block.create(.graphic)
  try engine.block.setShape(background, shape: engine.block.createShape(.rect))
  try engine.block.setFill(background, fill: engine.block.createFill(.color))
  let backgroundFill = try engine.block.getFill(background)
  try engine.block.setColor(
    backgroundFill,
    property: "fill/color/value",
    color: .rgba(r: 0.969, g: 0.973, b: 0.984, a: 1.0),
  )
  try engine.block.setWidth(background, value: 800)
  try engine.block.setHeight(background, value: 500)
  try engine.block.appendChild(to: page, child: background)

  let shadowText = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: shadowText)
  try engine.block.replaceText(shadowText, text: "Drop Shadow")
  try engine.block.setTextFontSize(shadowText, fontSize: 90)
  try engine.block.setWidthMode(shadowText, mode: .auto)
  try engine.block.setHeightMode(shadowText, mode: .auto)
  try engine.block.setPositionX(shadowText, value: 50)
  try engine.block.setPositionY(shadowText, value: 50)

  // highlight-textEffects-dropShadow
  guard try engine.block.supportsDropShadow(shadowText) else { return }
  try engine.block.setDropShadowEnabled(shadowText, enabled: true)
  try engine.block.setDropShadowColor(shadowText, color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 0.6))
  try engine.block.setDropShadowOffsetX(shadowText, offsetX: 5)
  try engine.block.setDropShadowOffsetY(shadowText, offsetY: 5)
  try engine.block.setDropShadowBlurRadiusX(shadowText, blurRadiusX: 10)
  try engine.block.setDropShadowBlurRadiusY(shadowText, blurRadiusY: 10)
  // highlight-textEffects-dropShadow

  try await engine.captureGuide(page, label: "after-drop-shadow")

  // highlight-textEffects-readDropShadow
  let isDropShadowEnabled = try engine.block.isDropShadowEnabled(shadowText)
  let dropShadowColor: Color = try engine.block.getDropShadowColor(shadowText)
  let dropShadowOffsetX = try engine.block.getDropShadowOffsetX(shadowText)
  let dropShadowOffsetY = try engine.block.getDropShadowOffsetY(shadowText)
  print("Drop shadow enabled:", isDropShadowEnabled)
  print("Drop shadow color:", dropShadowColor)
  print("Drop shadow offset:", dropShadowOffsetX, dropShadowOffsetY)
  // highlight-textEffects-readDropShadow

  let outlineText = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: outlineText)
  try engine.block.replaceText(outlineText, text: "Outline")
  try engine.block.setTextFontSize(outlineText, fontSize: 90)
  try engine.block.setWidthMode(outlineText, mode: .auto)
  try engine.block.setHeightMode(outlineText, mode: .auto)
  try engine.block.setPositionX(outlineText, value: 50)
  try engine.block.setPositionY(outlineText, value: 250)

  // highlight-textEffects-stroke
  guard try engine.block.supportsStroke(outlineText) else { return }
  try engine.block.setStrokeEnabled(outlineText, enabled: true)
  try engine.block.setStrokeWidth(outlineText, width: 2)
  try engine.block.setStrokeColor(outlineText, color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1.0))
  try engine.block.setStrokeStyle(outlineText, style: .solid)
  try engine.block.setStrokePosition(outlineText, position: .center)
  // highlight-textEffects-stroke

  // highlight-textEffects-readStroke
  let isStrokeEnabled = try engine.block.isStrokeEnabled(outlineText)
  let strokeWidth = try engine.block.getStrokeWidth(outlineText)
  let strokeColor: Color = try engine.block.getStrokeColor(outlineText)
  let strokeStyle = try engine.block.getStrokeStyle(outlineText)
  let strokePosition = try engine.block.getStrokePosition(outlineText)
  print("Stroke enabled:", isStrokeEnabled)
  print("Stroke width:", strokeWidth)
  print("Stroke color:", strokeColor)
  print("Stroke style is solid:", strokeStyle == .solid)
  print("Stroke position is center:", strokePosition == .center)
  // highlight-textEffects-readStroke

  try await engine.captureGuide(page, label: "hero")
}
