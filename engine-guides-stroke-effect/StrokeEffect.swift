import Foundation
import IMGLYEngine

struct StrokeEffectGuideResult {
  let maskCounts: [Int]
  let maskMode: String
  let ringOnlyPaintStyle: String
  let ringOnlyAllMasks: Bool
  let halfStrokeEnd: Float
}

@MainActor
func strokeEffect(engine: Engine) async throws -> StrokeEffectGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1180)
  try engine.block.setHeight(page, value: 330)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  // Demo scaffolding: three copies of one image in a row
  func addImageBlock(x: Float) throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    let fill = try engine.block.createFill(.image)
    try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: imageURL)
    try engine.block.setFill(block, fill: fill)
    try engine.block.setWidth(block, value: 360)
    try engine.block.setHeight(block, value: 270)
    try engine.block.setPositionX(block, value: x)
    try engine.block.setPositionY(block, value: 30)
    try engine.block.appendChild(to: page, child: block)
    return block
  }

  let imageBlock = try addImageBlock(x: 30)
  let transparentBlock = try addImageBlock(x: 410)
  let halfBlock = try addImageBlock(x: 790)

  // highlight-strokeEffect-mask
  // An ellipse mask in the "None" mode gives the stroke a path without cutting the block
  func addEllipseMask(to block: DesignBlockID) throws {
    let mask = try engine.block.createMask()
    try engine.block.setShape(mask, shape: engine.block.createShape(.ellipse))
    try engine.block.setEnum(mask, property: "mask/mode", value: "None")
    try engine.block.appendMask(block, maskID: mask)
  }

  try addEllipseMask(to: imageBlock)
  try addEllipseMask(to: transparentBlock)
  try addEllipseMask(to: halfBlock)
  // highlight-strokeEffect-mask

  // highlight-strokeEffect-stroke
  // Draw a hard yellow brush stroke along the first mask, over the image
  let stroke = try engine.block.createEffect(.stroke)
  try engine.block.setInt(stroke, property: "effect/stroke/maskIndex", value: 0)
  try engine.block.setFloat(stroke, property: "effect/stroke/brushSize", value: 6)
  try engine.block.setFloat(stroke, property: "effect/stroke/hardness", value: 1)
  try engine.block.setColor(stroke, property: "effect/stroke/color", color: .rgba(r: 1, g: 0.8, b: 0.1, a: 1))
  try engine.block.appendEffect(imageBlock, effectID: stroke)
  // highlight-strokeEffect-stroke

  // highlight-strokeEffect-transparent
  // Stroke every mask and draw only the stroke, without the image
  let ringOnly = try engine.block.createEffect(.stroke)
  try engine.block.setBool(ringOnly, property: "effect/stroke/allMasks", value: true)
  try engine.block.setFloat(ringOnly, property: "effect/stroke/brushSize", value: 6)
  try engine.block.setFloat(ringOnly, property: "effect/stroke/hardness", value: 1)
  try engine.block.setEnum(ringOnly, property: "effect/stroke/paintStyle", value: "OnTransparent")
  try engine.block.setColor(ringOnly, property: "effect/stroke/color", color: .rgba(r: 1, g: 0.8, b: 0.1, a: 1))
  try engine.block.appendEffect(transparentBlock, effectID: ringOnly)
  // highlight-strokeEffect-transparent

  // highlight-strokeEffect-trim
  // Draw only the first half of the mask path
  let halfStroke = try engine.block.createEffect(.stroke)
  try engine.block.setFloat(halfStroke, property: "effect/stroke/brushSize", value: 6)
  try engine.block.setFloat(halfStroke, property: "effect/stroke/hardness", value: 1)
  try engine.block.setFloat(halfStroke, property: "effect/stroke/start", value: 0)
  try engine.block.setFloat(halfStroke, property: "effect/stroke/end", value: 0.5)
  try engine.block.setColor(halfStroke, property: "effect/stroke/color", color: .rgba(r: 1, g: 0.8, b: 0.1, a: 1))
  try engine.block.appendEffect(halfBlock, effectID: halfStroke)
  // highlight-strokeEffect-trim

  try await engine.captureGuide(page, label: "hero")

  let blocks = [imageBlock, transparentBlock, halfBlock]
  return try StrokeEffectGuideResult(
    maskCounts: blocks.map { try engine.block.getMasks($0).count },
    maskMode: engine.block.getEnum(engine.block.getMasks(imageBlock)[0], property: "mask/mode"),
    ringOnlyPaintStyle: engine.block.getEnum(ringOnly, property: "effect/stroke/paintStyle"),
    ringOnlyAllMasks: engine.block.getBool(ringOnly, property: "effect/stroke/allMasks"),
    halfStrokeEnd: engine.block.getFloat(halfStroke, property: "effect/stroke/end"),
  )
}
