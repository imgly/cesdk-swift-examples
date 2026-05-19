import IMGLYEngine

@MainActor
func blendModes(engine: Engine) async throws {
  // Set up a scene with a page and two overlapping graphic blocks
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // Create a background graphic block (base layer)
  let background = try engine.block.create(.graphic)
  try engine.block.setShape(background, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(background, value: 400)
  try engine.block.setHeight(background, value: 400)
  try engine.block.setPositionX(background, value: 200)
  try engine.block.setPositionY(background, value: 100)
  let backgroundFill = try engine.block.createFill(.color)
  try engine.block.setColor(backgroundFill, property: "fill/color/value", color: .rgba(r: 1.0, g: 0.5, b: 0.0, a: 1.0))
  try engine.block.setFill(background, fill: backgroundFill)
  try engine.block.appendChild(to: page, child: background)

  // Create a top graphic block to blend with the background
  let overlay = try engine.block.create(.graphic)
  try engine.block.setShape(overlay, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(overlay, value: 400)
  try engine.block.setHeight(overlay, value: 400)
  try engine.block.setPositionX(overlay, value: 200)
  try engine.block.setPositionY(overlay, value: 100)
  let overlayFill = try engine.block.createFill(.color)
  try engine.block.setColor(overlayFill, property: "fill/color/value", color: .rgba(r: 0.0, g: 0.5, b: 1.0, a: 1.0))
  try engine.block.setFill(overlay, fill: overlayFill)
  try engine.block.appendChild(to: page, child: overlay)

  // highlight-blendModes-checkSupport
  // Verify the block supports blend modes before applying one
  let supportsBlend = try engine.block.supportsBlendMode(overlay)
  print("Supports blend mode:", supportsBlend) // true
  // highlight-blendModes-checkSupport

  // highlight-blendModes-setBlendMode
  // Apply the Multiply blend mode to the top block
  if supportsBlend {
    try engine.block.setBlendMode(overlay, mode: .multiply)
  }
  // highlight-blendModes-setBlendMode

  // highlight-blendModes-getBlendMode
  // Retrieve the current blend mode to confirm the change
  let currentMode = try engine.block.getBlendMode(overlay)
  print("Current blend mode:", currentMode) // BlendMode.multiply
  // highlight-blendModes-getBlendMode

  // highlight-blendModes-setOpacity
  // Combine the blend mode with reduced opacity for a softer effect
  if try engine.block.supportsOpacity(overlay) {
    try engine.block.setOpacity(overlay, value: 0.7)
  }
  // highlight-blendModes-setOpacity

  // highlight-blendModes-getOpacity
  // Read back the current opacity value
  let currentOpacity = try engine.block.getOpacity(overlay)
  print("Current opacity:", currentOpacity) // 0.7
  // highlight-blendModes-getOpacity
}
