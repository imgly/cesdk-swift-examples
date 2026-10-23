import Foundation
import IMGLYEngine

struct WipeEffectsGuideResult {
  let linearCompletion: Float
  let radialDirection: String
  let blindsWidth: Float
  let revealKeyframeTimes: [Float]
  let earlyPngData: Data
  let latePngData: Data
}

@MainActor
func wipeEffects(engine: Engine) async throws -> WipeEffectsGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 620)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  // highlight-wipeEffects-createImage
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

  let linearBlock = try addImageBlock(x: 30, y: 30)
  let radialBlock = try addImageBlock(x: 410, y: 30)
  let blindsBlock = try addImageBlock(x: 30, y: 320)
  let revealBlock = try addImageBlock(x: 410, y: 320)
  // highlight-wipeEffects-createImage

  // highlight-wipeEffects-linear
  // Hide the left half of the block with a soft edge
  let linearWipe = try engine.block.createEffect(.linearWipe)
  try engine.block.setFloat(linearWipe, property: "effect/linear_wipe/angle", value: 90)
  try engine.block.setFloat(linearWipe, property: "effect/linear_wipe/completion", value: 0.5)
  try engine.block.setFloat(linearWipe, property: "effect/linear_wipe/feather", value: 40)
  try engine.block.appendEffect(linearBlock, effectID: linearWipe)
  // highlight-wipeEffects-linear

  // highlight-wipeEffects-radial
  // Hide 60% of the circle around the center, sweeping clockwise from 12 o'clock
  let radialWipe = try engine.block.createEffect(.radialWipe)
  try engine.block.setFloat(radialWipe, property: "effect/radial_wipe/completion", value: 0.6)
  try engine.block.setFloat(radialWipe, property: "effect/radial_wipe/startAngle", value: 0)
  try engine.block.setFloat(radialWipe, property: "effect/radial_wipe/centerX", value: 0.5)
  try engine.block.setFloat(radialWipe, property: "effect/radial_wipe/centerY", value: 0.5)
  try engine.block.setEnum(radialWipe, property: "effect/radial_wipe/direction", value: "Clockwise")
  try engine.block.setFloat(radialWipe, property: "effect/radial_wipe/feather", value: 20)
  try engine.block.appendEffect(radialBlock, effectID: radialWipe)
  // highlight-wipeEffects-radial

  // highlight-wipeEffects-blinds
  // Diagonal stripes, 60 design units wide, each half hidden
  let blinds = try engine.block.createEffect(.venetianBlinds)
  try engine.block.setFloat(blinds, property: "effect/venetian_blinds/completion", value: 0.5)
  try engine.block.setFloat(blinds, property: "effect/venetian_blinds/direction", value: 45)
  try engine.block.setFloat(blinds, property: "effect/venetian_blinds/width", value: 60)
  try engine.block.setFloat(blinds, property: "effect/venetian_blinds/feather", value: 2)
  try engine.block.appendEffect(blindsBlock, effectID: blinds)
  // highlight-wipeEffects-blinds

  // highlight-wipeEffects-reveal
  // Reveal the block from the right over its 2 second duration
  try engine.block.setDuration(revealBlock, duration: 2)
  let reveal = try engine.block.createEffect(.linearWipe)
  try engine.block.setFloat(reveal, property: "effect/linear_wipe/angle", value: 90)
  try engine.block.appendEffect(revealBlock, effectID: reveal)
  try engine.block.setKeyframes(reveal, property: "effect/linear_wipe/completion", keyframes: [
    Keyframe(time: 0, value: .float(1), easing: .preset(.easeOut)),
    Keyframe(time: 1, value: .float(0)),
  ])
  // highlight-wipeEffects-reveal

  // highlight-wipeEffects-readReveal
  // `getFloat` returns the static value, so read the track and export two frames of the reveal
  let revealKeyframes = try engine.block.getKeyframes(reveal, property: "effect/linear_wipe/completion")
  print(revealKeyframes.count) // 2
  try engine.block.setPlaybackTime(page, time: 0.5)
  let early = try await engine.block.export(page, mimeType: .png)
  try engine.block.setPlaybackTime(page, time: 1.5)
  let late = try await engine.block.export(page, mimeType: .png)
  // highlight-wipeEffects-readReveal

  try await engine.captureGuide(data: late, label: "hero", mimeType: .png)

  return try WipeEffectsGuideResult(
    linearCompletion: engine.block.getFloat(linearWipe, property: "effect/linear_wipe/completion"),
    radialDirection: engine.block.getEnum(radialWipe, property: "effect/radial_wipe/direction"),
    blindsWidth: engine.block.getFloat(blinds, property: "effect/venetian_blinds/width"),
    revealKeyframeTimes: revealKeyframes.map(\.time),
    earlyPngData: early,
    latePngData: late,
  )
}
