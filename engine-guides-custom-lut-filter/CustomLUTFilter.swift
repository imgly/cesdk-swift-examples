import Foundation
import IMGLYEngine

@MainActor
func customLutFilter(engine: Engine) async throws {
  // Demo scaffolding: a scene, a page, and an image block to grade. In your
  // app this is whatever image block the user is editing.
  let scene = try engine.scene.create()
  let baseURL = try engine.guidesBaseURL

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(imageBlock, value: 800)
  try engine.block.setHeight(imageBlock, value: 600)
  try engine.block.appendChild(to: page, child: imageBlock)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(imageBlock, fill: imageFill)

  // The URL of your hosted (or app-bundled) tiled-PNG LUT image.
  let lutURL = baseURL.appendingPathComponent("ly.img.filter.lut/LUTs/imgly_lut_ad1920_5_5_128.png")

  try await engine.captureGuide(page, label: "before-lut")

  // highlight-customLutFilter-createEffect
  let lutEffect = try engine.block.createEffect(.lutFilter)
  // highlight-customLutFilter-createEffect

  // highlight-customLutFilter-configure
  try engine.block.setURL(lutEffect, property: "effect/lut_filter/lutFileURI", value: lutURL)
  try engine.block.setInt(lutEffect, property: "effect/lut_filter/horizontalTileCount", value: 5)
  try engine.block.setInt(lutEffect, property: "effect/lut_filter/verticalTileCount", value: 5)
  // highlight-customLutFilter-configure

  // highlight-customLutFilter-intensity
  try engine.block.setFloat(lutEffect, property: "effect/lut_filter/intensity", value: 0.9)
  // highlight-customLutFilter-intensity

  // highlight-customLutFilter-apply
  try engine.block.appendEffect(imageBlock, effectID: lutEffect)
  // highlight-customLutFilter-apply

  try await engine.captureGuide(page, label: "hero")

  // highlight-customLutFilter-toggle
  try engine.block.setEffectEnabled(effectID: lutEffect, enabled: false)
  let isEnabled = try engine.block.isEffectEnabled(effectID: lutEffect)
  print("LUT filter enabled: \(isEnabled)")
  try engine.block.setEffectEnabled(effectID: lutEffect, enabled: true)
  // highlight-customLutFilter-toggle

  // highlight-customLutFilter-manage
  let supportsEffects = try engine.block.supportsEffects(imageBlock)
  let effects = try engine.block.getEffects(imageBlock)
  print("Supports effects: \(supportsEffects), count: \(effects.count)")
  // highlight-customLutFilter-manage
}
