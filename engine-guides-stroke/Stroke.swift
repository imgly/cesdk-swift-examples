import IMGLYEngine

@MainActor
func stroke(engine: Engine) async throws {
  // Demo scaffolding: a scene with a page and a single rectangle graphic block
  // to outline. A light fill keeps the rectangle visible so the blue stroke
  // stands out against it.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  let fill = try engine.block.getFill(block)
  try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.9, g: 0.9, b: 0.9, a: 1.0))
  try engine.block.setWidth(block, value: 400)
  try engine.block.setHeight(block, value: 300)
  try engine.block.setPositionX(block, value: 200)
  try engine.block.setPositionY(block, value: 150)
  try engine.block.appendChild(to: page, child: block)

  // highlight-stroke-checkSupport
  guard try engine.block.supportsStroke(block) else { return }
  // highlight-stroke-checkSupport

  // highlight-stroke-enable
  try engine.block.setStrokeEnabled(block, enabled: true)
  let strokeEnabled = try engine.block.isStrokeEnabled(block)
  print("Stroke enabled: \(strokeEnabled)")
  // highlight-stroke-enable

  // highlight-stroke-color
  try engine.block.setStrokeColor(block, color: .rgba(r: 0.0, g: 0.0, b: 1.0, a: 1.0))
  let strokeColor: Color = try engine.block.getStrokeColor(block)
  print("Stroke color: \(strokeColor)")
  // highlight-stroke-color

  // highlight-stroke-width
  try engine.block.setStrokeWidth(block, width: 10)
  let strokeWidth = try engine.block.getStrokeWidth(block)
  print("Stroke width: \(strokeWidth)")
  // highlight-stroke-width

  try await engine.captureGuide(page, label: "after-basic-stroke")

  // highlight-stroke-style
  try engine.block.setStrokeStyle(block, style: .dashed)
  let strokeStyle = try engine.block.getStrokeStyle(block)
  print("Stroke style is dashed: \(strokeStyle == .dashed)")
  // highlight-stroke-style

  // highlight-stroke-position
  try engine.block.setStrokePosition(block, position: .outer)
  let strokePosition = try engine.block.getStrokePosition(block)
  print("Stroke position is outer: \(strokePosition == .outer)")
  // highlight-stroke-position

  // highlight-stroke-corner
  try engine.block.setStrokeCornerGeometry(block, cornerGeometry: .round)
  let strokeCornerGeometry = try engine.block.getStrokeCornerGeometry(block)
  print("Stroke corner geometry is round: \(strokeCornerGeometry == .round)")
  // highlight-stroke-corner

  try await engine.captureGuide(page, label: "hero")
}
