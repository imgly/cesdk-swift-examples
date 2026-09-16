import Foundation
import IMGLYEngine

@MainActor
func distortion(engine: Engine) async throws {
  // Demo scaffolding: a comparison grid of six copies of the same image. The
  // teaching sections below apply one distortion effect to each cell so the
  // effects can be seen side by side; the top-left cell is left unaltered as a
  // reference.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1180)
  try engine.block.setHeight(page, value: 620)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  func makeImageCell(x: Float, y: Float) throws -> DesignBlockID {
    let cell = try engine.block.create(.graphic)
    try engine.block.setShape(cell, shape: engine.block.createShape(.rect))
    try engine.block.setWidth(cell, value: 360)
    try engine.block.setHeight(cell, value: 270)
    try engine.block.setPositionX(cell, value: x)
    try engine.block.setPositionY(cell, value: y)
    let fill = try engine.block.createFill(.image)
    try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: imageURL)
    try engine.block.setFill(cell, fill: fill)
    try engine.block.setEnum(cell, property: "contentFill/mode", value: "Cover")
    try engine.block.appendChild(to: page, child: cell)
    return cell
  }

  _ = try makeImageCell(x: 30, y: 30) // original, no effect
  let liquidBlock = try makeImageCell(x: 410, y: 30)
  let mirrorBlock = try makeImageCell(x: 790, y: 30)
  let shifterBlock = try makeImageCell(x: 30, y: 320)
  let radialPixelBlock = try makeImageCell(x: 410, y: 320)
  let tvGlitchBlock = try makeImageCell(x: 790, y: 320)

  // highlight-distortion-checkSupport
  let canHaveEffects = try engine.block.supportsEffects(liquidBlock)
  print("Block supports effects: \(canHaveEffects)")
  // highlight-distortion-checkSupport

  // highlight-distortion-liquid
  let liquid = try engine.block.createEffect(.liquid)
  try engine.block.setFloat(liquid, property: "effect/liquid/amount", value: 0.5)
  try engine.block.setFloat(liquid, property: "effect/liquid/scale", value: 1.0)
  try engine.block.appendEffect(liquidBlock, effectID: liquid)
  // highlight-distortion-liquid

  // highlight-distortion-mirror
  let mirror = try engine.block.createEffect(.mirror)
  try engine.block.setInt(mirror, property: "effect/mirror/side", value: 0)
  try engine.block.appendEffect(mirrorBlock, effectID: mirror)
  // highlight-distortion-mirror

  // highlight-distortion-shifter
  let shifter = try engine.block.createEffect(.shifter)
  try engine.block.setFloat(shifter, property: "effect/shifter/amount", value: 0.3)
  try engine.block.setFloat(shifter, property: "effect/shifter/angle", value: 0.785)
  try engine.block.appendEffect(shifterBlock, effectID: shifter)
  // highlight-distortion-shifter

  // highlight-distortion-radialPixel
  let radialPixel = try engine.block.createEffect(.radialPixel)
  try engine.block.setFloat(radialPixel, property: "effect/radial_pixel/radius", value: 0.5)
  try engine.block.setFloat(radialPixel, property: "effect/radial_pixel/segments", value: 0.5)
  try engine.block.appendEffect(radialPixelBlock, effectID: radialPixel)
  // highlight-distortion-radialPixel

  // highlight-distortion-tvGlitch
  let tvGlitch = try engine.block.createEffect(.tvGlitch)
  try engine.block.setFloat(tvGlitch, property: "effect/tv_glitch/distortion", value: 0.4)
  try engine.block.setFloat(tvGlitch, property: "effect/tv_glitch/distortion2", value: 0.2)
  try engine.block.setFloat(tvGlitch, property: "effect/tv_glitch/speed", value: 0.5)
  try engine.block.setFloat(tvGlitch, property: "effect/tv_glitch/rollSpeed", value: 0.5)
  try engine.block.appendEffect(tvGlitchBlock, effectID: tvGlitch)
  // highlight-distortion-tvGlitch

  try await engine.captureGuide(page, label: "hero")

  // highlight-distortion-combine
  let extraShifter = try engine.block.createEffect(.shifter)
  try engine.block.setFloat(extraShifter, property: "effect/shifter/amount", value: 0.2)
  try engine.block.appendEffect(liquidBlock, effectID: extraShifter)
  // highlight-distortion-combine

  try await engine.captureGuide(liquidBlock, label: "after-combine")

  // highlight-distortion-getEffects
  let effects = try engine.block.getEffects(liquidBlock)
  print("Applied effects: \(effects.count)")
  // highlight-distortion-getEffects

  // highlight-distortion-toggle
  try engine.block.setEffectEnabled(effectID: extraShifter, enabled: false)
  let shifterEnabled = try engine.block.isEffectEnabled(effectID: extraShifter)
  print("Shifter enabled: \(shifterEnabled)")
  // highlight-distortion-toggle

  // highlight-distortion-remove
  try engine.block.removeEffect(liquidBlock, index: 1)
  try engine.block.destroy(extraShifter)
  // highlight-distortion-remove

  // highlight-distortion-properties
  let liquidProperties = try engine.block.findAllProperties(liquid)
  print("Liquid effect properties: \(liquidProperties)")
  // highlight-distortion-properties
}
