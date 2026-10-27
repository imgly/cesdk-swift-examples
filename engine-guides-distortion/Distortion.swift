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

  // A second page holds the corner pin, bulge, wave warp and displacement map cells
  let distortPage = try engine.block.create(.page)
  try engine.block.setWidth(distortPage, value: 1180)
  try engine.block.setHeight(distortPage, value: 620)
  try engine.block.appendChild(to: scene, child: distortPage)

  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  func makeImageCell(x: Float, y: Float, on parent: DesignBlockID) throws -> DesignBlockID {
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
    try engine.block.appendChild(to: parent, child: cell)
    return cell
  }

  _ = try makeImageCell(x: 30, y: 30, on: page) // original, no effect
  let liquidBlock = try makeImageCell(x: 410, y: 30, on: page)
  let mirrorBlock = try makeImageCell(x: 790, y: 30, on: page)
  let shifterBlock = try makeImageCell(x: 30, y: 320, on: page)
  let radialPixelBlock = try makeImageCell(x: 410, y: 320, on: page)
  let tvGlitchBlock = try makeImageCell(x: 790, y: 320, on: page)
  let cornerPinBlock = try makeImageCell(x: 30, y: 30, on: distortPage)
  let bulgeBlock = try makeImageCell(x: 410, y: 30, on: distortPage)
  let waveWarpBlock = try makeImageCell(x: 790, y: 30, on: distortPage)
  let displacedBlock = try makeImageCell(x: 30, y: 320, on: distortPage)

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

  // highlight-distortion-cornerPin
  // Pull the upper corners inward for a perspective look
  let cornerPin = try engine.block.createEffect(.cornerPin)
  try engine.block.setFloat(cornerPin, property: "effect/corner_pin/upperLeftX", value: 0.15)
  try engine.block.setFloat(cornerPin, property: "effect/corner_pin/upperLeftY", value: 0.1)
  try engine.block.setFloat(cornerPin, property: "effect/corner_pin/upperRightX", value: 0.85)
  try engine.block.setFloat(cornerPin, property: "effect/corner_pin/upperRightY", value: 0.1)
  try engine.block.appendEffect(cornerPinBlock, effectID: cornerPin)
  // highlight-distortion-cornerPin

  // highlight-distortion-bulge
  // Magnify an ellipse with radii of 120 and 100 design units at the center
  let bulge = try engine.block.createEffect(.bulge)
  try engine.block.setFloat(bulge, property: "effect/bulge/centerX", value: 0.5)
  try engine.block.setFloat(bulge, property: "effect/bulge/centerY", value: 0.5)
  try engine.block.setFloat(bulge, property: "effect/bulge/horizontalRadius", value: 120)
  try engine.block.setFloat(bulge, property: "effect/bulge/verticalRadius", value: 100)
  try engine.block.setFloat(bulge, property: "effect/bulge/height", value: 1.5)
  try engine.block.appendEffect(bulgeBlock, effectID: bulge)
  // highlight-distortion-bulge

  // highlight-distortion-waveWarp
  // A wave 15 design units high with crests 90 design units apart
  let waveWarp = try engine.block.createEffect(.waveWarp)
  try engine.block.setFloat(waveWarp, property: "effect/wave_warp/height", value: 15)
  try engine.block.setFloat(waveWarp, property: "effect/wave_warp/width", value: 90)
  try engine.block.setEnum(waveWarp, property: "effect/wave_warp/waveType", value: "Sine")
  try engine.block.appendEffect(waveWarpBlock, effectID: waveWarp)
  // highlight-distortion-waveWarp

  // highlight-distortion-displacementMap
  // The map is a hidden image block. The effect still reads it.
  let map = try makeImageCell(x: 410, y: 320, on: distortPage)
  try engine.block.setVisible(map, visible: false)

  let displacementMap = try engine.block.createEffect(.displacementMap)
  try engine.block.setEnum(displacementMap, property: "effect/displacement_map/horizontalChannel", value: "Luminance")
  try engine.block.setFloat(displacementMap, property: "effect/displacement_map/maxHorizontal", value: 20)
  try engine.block.setEnum(displacementMap, property: "effect/displacement_map/verticalChannel", value: "Luminance")
  try engine.block.setFloat(displacementMap, property: "effect/displacement_map/maxVertical", value: 20)
  try engine.block.setEnum(displacementMap, property: "effect/displacement_map/mapBehavior", value: "Stretch")
  try engine.block.appendEffect(displacedBlock, effectID: displacementMap)

  // Set the map block as the source of the effect
  try engine.block.setEffectSource(effectID: displacementMap, source: map)
  // highlight-distortion-displacementMap

  // highlight-distortion-readSource
  let source = try engine.block.getEffectSource(effectID: displacementMap)
  print(source == map) // true
  // highlight-distortion-readSource

  // highlight-distortion-sourceErrors
  do {
    // Only the displacement map effect reads a source
    try engine.block.setEffectSource(effectID: waveWarp, source: map)
  } catch let error as EngineError {
    print(error.catalogCode == .blockEffectSourceUnsupported) // true
  }
  do {
    // A page cannot be a source
    try engine.block.setEffectSource(effectID: displacementMap, source: distortPage)
  } catch let error as EngineError {
    print(error.catalogCode == .blockEffectSourceInvalid) // true
  }
  // highlight-distortion-sourceErrors

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
