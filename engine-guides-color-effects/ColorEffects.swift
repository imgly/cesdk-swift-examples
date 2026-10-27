import Foundation
import IMGLYEngine

struct ColorEffectsGuideResult {
  let stackOrder: [DesignBlockID]
  let levels: DesignBlockID
  let tritone: DesignBlockID
  let tintAmount: Float
  let thresholdLevel: Float
  let takeRedFrom: String
  let takeBlueFrom: String
}

@MainActor
func colorEffects(engine: Engine) async throws -> ColorEffectsGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 620)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  // highlight-colorEffects-createImage
  // Adds a 360 x 270 image block to the page at a position
  func addImageBlock(x: Float, y: Float) throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    let fill = try engine.block.createFill(.image)
    try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: imageURL)
    try engine.block.setFill(block, fill: fill)
    try engine.block.setWidth(block, value: 360)
    try engine.block.setHeight(block, value: 270)
    try engine.block.setPositionX(block, value: x)
    try engine.block.setPositionY(block, value: y)
    try engine.block.appendChild(to: page, child: block)
    return block
  }

  let stackBlock = try addImageBlock(x: 30, y: 30)
  let tintBlock = try addImageBlock(x: 410, y: 30)
  let thresholdBlock = try addImageBlock(x: 30, y: 320)
  let shiftBlock = try addImageBlock(x: 410, y: 320)
  // highlight-colorEffects-createImage

  // highlight-colorEffects-stack
  // Levels runs first and stretches the input range
  let levels = try engine.block.createEffect(.levels)
  try engine.block.setFloat(levels, property: "effect/levels/rgbInBlack", value: 0.1)
  try engine.block.setFloat(levels, property: "effect/levels/rgbInWhite", value: 0.9)
  try engine.block.appendEffect(stackBlock, effectID: levels)

  // Tritone runs second and maps dark, middle and light values to three colors
  let tritone = try engine.block.createEffect(.tritone)
  try engine.block.setColor(tritone, property: "effect/tritone/shadows", color: .rgba(r: 0.1, g: 0.1, b: 0.3, a: 1))
  try engine.block.setColor(tritone, property: "effect/tritone/midtones", color: .rgba(r: 0.8, g: 0.3, b: 0.4, a: 1))
  try engine.block.setColor(tritone, property: "effect/tritone/highlights", color: .rgba(r: 1, g: 0.9, b: 0.7, a: 1))
  try engine.block.appendEffect(stackBlock, effectID: tritone)
  // highlight-colorEffects-stack

  // highlight-colorEffects-tint
  // Black maps to a dark blue and white to a warm yellow
  let tint = try engine.block.createEffect(.tint)
  try engine.block.setColor(tint, property: "effect/tint/mapBlackTo", color: .rgba(r: 0.05, g: 0.1, b: 0.35, a: 1))
  try engine.block.setColor(tint, property: "effect/tint/mapWhiteTo", color: .rgba(r: 1, g: 0.85, b: 0.4, a: 1))
  try engine.block.setFloat(tint, property: "effect/tint/amount", value: 0.8)
  try engine.block.appendEffect(tintBlock, effectID: tint)
  // highlight-colorEffects-tint

  // highlight-colorEffects-threshold
  // Pixels with a luminance of 0.45 or more turn white, all others black
  let threshold = try engine.block.createEffect(.threshold)
  try engine.block.setFloat(threshold, property: "effect/threshold/level", value: 0.45)
  try engine.block.appendEffect(thresholdBlock, effectID: threshold)
  // highlight-colorEffects-threshold

  // highlight-colorEffects-shiftChannels
  // Swap the red and blue channels
  let shiftChannels = try engine.block.createEffect(.shiftChannels)
  try engine.block.setEnum(shiftChannels, property: "effect/shift_channels/takeRedFrom", value: "Blue")
  try engine.block.setEnum(shiftChannels, property: "effect/shift_channels/takeBlueFrom", value: "Red")
  try engine.block.appendEffect(shiftBlock, effectID: shiftChannels)
  // highlight-colorEffects-shiftChannels

  // highlight-colorEffects-order
  // [levels, tritone]: levels runs first
  let stack = try engine.block.getEffects(stackBlock)
  print(stack == [levels, tritone]) // true
  // highlight-colorEffects-order

  try await engine.captureGuide(page, label: "hero")

  return try ColorEffectsGuideResult(
    stackOrder: stack,
    levels: levels,
    tritone: tritone,
    tintAmount: engine.block.getFloat(tint, property: "effect/tint/amount"),
    thresholdLevel: engine.block.getFloat(threshold, property: "effect/threshold/level"),
    takeRedFrom: engine.block.getEnum(shiftChannels, property: "effect/shift_channels/takeRedFrom"),
    takeBlueFrom: engine.block.getEnum(shiftChannels, property: "effect/shift_channels/takeBlueFrom"),
  )
}
