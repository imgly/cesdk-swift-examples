import IMGLYEngine

@MainActor
func spotColors(engine: Engine) async throws {
  // Demo scaffolding: a scene with a page and three graphic blocks that we
  // will recolor with spot colors below. A fourth block is added later in the
  // function to demonstrate the magenta fallback after a spot color is
  // removed.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let primaryPositions: [(x: Float, y: Float)] = [(40, 180), (285, 180), (530, 180)]
  var blocks: [DesignBlockID] = []
  for position in primaryPositions {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setFill(block, fill: engine.block.createFill(.color))
    try engine.block.setWidth(block, value: 230)
    try engine.block.setHeight(block, value: 240)
    try engine.block.setPositionX(block, value: position.x)
    try engine.block.setPositionY(block, value: position.y)
    try engine.block.appendChild(to: page, child: block)
    blocks.append(block)
  }
  let primaryBlock = blocks[0]
  let tintBlock = blocks[1]
  let accentBlock = blocks[2]

  // highlight-spotColors-defineRGB
  engine.editor.setSpotColor(name: "Brand-Primary", r: 0.8, g: 0.1, b: 0.2)
  // highlight-spotColors-defineRGB

  // highlight-spotColors-defineCMYK
  engine.editor.setSpotColor(name: "Brand-Primary", c: 0.05, m: 0.95, y: 0.85, k: 0.0)
  engine.editor.setSpotColor(name: "Brand-Accent", r: 0.2, g: 0.4, b: 0.8)
  engine.editor.setSpotColor(name: "Brand-Accent", c: 0.75, m: 0.5, y: 0.0, k: 0.0)
  // highlight-spotColors-defineCMYK

  // highlight-spotColors-applyFill
  let primaryFill = try engine.block.getFill(primaryBlock)
  try engine.block.setColor(
    primaryFill,
    property: "fill/color/value",
    color: .spot(name: "Brand-Primary", externalReference: "Brand-Colors"),
  )
  // highlight-spotColors-applyFill

  // highlight-spotColors-tint
  let tintFill = try engine.block.getFill(tintBlock)
  try engine.block.setColor(tintFill, property: "fill/color/value", color: .spot(name: "Brand-Primary", tint: 0.5))
  // highlight-spotColors-tint

  try await engine.captureGuide(page, label: "after-fills")

  // highlight-spotColors-strokeShadow
  let accentFill = try engine.block.getFill(accentBlock)
  try engine.block.setColor(accentFill, property: "fill/color/value", color: .spot(name: "Brand-Accent", tint: 0.3))

  try engine.block.setStrokeEnabled(accentBlock, enabled: true)
  try engine.block.setStrokeWidth(accentBlock, width: 6)
  try engine.block.setColor(accentBlock, property: "stroke/color", color: .spot(name: "Brand-Accent"))

  try engine.block.setDropShadowEnabled(accentBlock, enabled: true)
  try engine.block.setDropShadowOffsetX(accentBlock, offsetX: 6)
  try engine.block.setDropShadowOffsetY(accentBlock, offsetY: 6)
  try engine.block.setColor(accentBlock, property: "dropShadow/color", color: .spot(name: "Brand-Primary", tint: 0.6))
  // highlight-spotColors-strokeShadow

  try await engine.captureGuide(page, label: "hero")

  // highlight-spotColors-query
  let definedNames = engine.editor.findAllSpotColors()
  print("Defined spot colors: \(definedNames)")

  let primaryRGB: RGBA = engine.editor.getSpotColor(name: "Brand-Primary")
  let primaryCMYK: CMYK = engine.editor.getSpotColor(name: "Brand-Primary")
  print("Brand-Primary RGB: \(primaryRGB)")
  print("Brand-Primary CMYK: \(primaryCMYK)")
  // highlight-spotColors-query

  // highlight-spotColors-read
  let storedColor: Color = try engine.block.getColor(primaryFill, property: "fill/color/value")
  if case let .spot(name, tint, _) = storedColor {
    print("Block is using spot color \(name) at tint \(tint)")
  }
  // highlight-spotColors-read

  // highlight-spotColors-update
  engine.editor.setSpotColor(name: "Brand-Primary", r: 0.85, g: 0.15, b: 0.25)
  // highlight-spotColors-update

  // Add a fourth block colored with a temporary spot color so we can
  // demonstrate the magenta fallback after the color is removed.
  let temporaryBlock = try engine.block.create(.graphic)
  try engine.block.setShape(temporaryBlock, shape: engine.block.createShape(.rect))
  try engine.block.setFill(temporaryBlock, fill: engine.block.createFill(.color))
  try engine.block.setWidth(temporaryBlock, value: 230)
  try engine.block.setHeight(temporaryBlock, value: 120)
  try engine.block.setPositionX(temporaryBlock, value: 285)
  try engine.block.setPositionY(temporaryBlock, value: 450)
  try engine.block.appendChild(to: page, child: temporaryBlock)

  engine.editor.setSpotColor(name: "Temporary-Color", r: 0.3, g: 0.7, b: 0.4)
  let temporaryFill = try engine.block.getFill(temporaryBlock)
  try engine.block.setColor(temporaryFill, property: "fill/color/value", color: .spot(name: "Temporary-Color"))

  // highlight-spotColors-remove
  try engine.editor.removeSpotColor(name: "Temporary-Color")
  // highlight-spotColors-remove

  try await engine.captureGuide(page, label: "after-remove")

  // highlight-spotColors-cutout
  engine.editor.setSpotColor(name: "DieLine", c: 0.0, m: 1.0, y: 0.0, k: 0.0)
  try engine.editor.setSpotColorForCutoutType(cutoutType: .solid, name: "DieLine")
  let assignedName = try engine.editor.getSpotColorForCutoutType(cutoutType: .solid)
  print("Cutout type .solid uses spot color: \(assignedName)")
  // highlight-spotColors-cutout
}
