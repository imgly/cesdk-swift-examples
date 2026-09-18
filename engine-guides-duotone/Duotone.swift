import Foundation
import IMGLYEngine

@MainActor
func duotone(engine: Engine) async throws {
  // Demo scaffolding: a wide page that holds three image blocks, each showing
  // the same photo under a different duotone treatment.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1100)
  try engine.block.setHeight(page, value: 380)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL
  let imageURI = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  // Demo scaffolding: the first image block, styled by the preset section below.
  let presetImage = try engine.block.create(.graphic)
  try engine.block.setShape(presetImage, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(presetImage, value: 340)
  try engine.block.setHeight(presetImage, value: 320)
  try engine.block.setPositionX(presetImage, value: 20)
  try engine.block.setPositionY(presetImage, value: 30)
  let presetFill = try engine.block.createFill(.image)
  try engine.block.setURL(presetFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(presetImage, fill: presetFill)
  try engine.block.appendChild(to: page, child: presetImage)

  // highlight-duotone-supportsEffects
  let canApplyEffects = try engine.block.supportsEffects(presetImage)
  guard canApplyEffects else { return }
  // highlight-duotone-supportsEffects

  // highlight-duotone-queryPresets
  let filterSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("ly.img.filter/content.json"),
    matcher: ["ly.img.filter.duotone.*"],
  )
  let presetResult = try await engine.asset.findAssets(
    sourceID: filterSourceID,
    query: AssetQueryData(query: nil, page: 0, perPage: 10),
  )
  let duotonePresets = presetResult.assets
  // highlight-duotone-queryPresets

  // highlight-duotone-createEffect
  let presetEffect = try engine.block.createEffect(.duotoneFilter)
  // highlight-duotone-createEffect

  // highlight-duotone-applyPreset
  if let preset = duotonePresets.first,
     let darkHex = preset.meta?["darkColor"],
     let lightHex = preset.meta?["lightColor"] {
    try engine.block.setColor(presetEffect, property: "effect/duotone_filter/darkColor", color: hexToRGBA(darkHex))
    try engine.block.setColor(presetEffect, property: "effect/duotone_filter/lightColor", color: hexToRGBA(lightHex))
    try engine.block.setFloat(presetEffect, property: "effect/duotone_filter/intensity", value: 0.9)
  }
  // highlight-duotone-applyPreset

  // highlight-duotone-appendPreset
  try engine.block.appendEffect(presetImage, effectID: presetEffect)
  // highlight-duotone-appendPreset

  try await engine.captureGuide(page, label: "after-preset")

  // Demo scaffolding: a second image block for the custom-color treatment.
  let customImage = try engine.block.create(.graphic)
  try engine.block.setShape(customImage, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(customImage, value: 340)
  try engine.block.setHeight(customImage, value: 320)
  try engine.block.setPositionX(customImage, value: 380)
  try engine.block.setPositionY(customImage, value: 30)
  let customFill = try engine.block.createFill(.image)
  try engine.block.setURL(customFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(customImage, fill: customFill)
  try engine.block.appendChild(to: page, child: customImage)

  // highlight-duotone-customColors
  let customEffect = try engine.block.createEffect(.duotoneFilter)
  // Dark color maps to shadows, light color maps to highlights.
  try engine.block.setColor(
    customEffect,
    property: "effect/duotone_filter/darkColor",
    color: .rgba(r: 0.1, g: 0.15, b: 0.3, a: 1.0),
  )
  try engine.block.setColor(
    customEffect,
    property: "effect/duotone_filter/lightColor",
    color: .rgba(r: 0.95, g: 0.9, b: 0.8, a: 1.0),
  )
  try engine.block.setFloat(customEffect, property: "effect/duotone_filter/intensity", value: 0.85)
  try engine.block.appendEffect(customImage, effectID: customEffect)
  // highlight-duotone-customColors

  try await engine.captureGuide(page, label: "after-custom")

  // Demo scaffolding: a third image block for the combined-effects treatment.
  let combinedImage = try engine.block.create(.graphic)
  try engine.block.setShape(combinedImage, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(combinedImage, value: 340)
  try engine.block.setHeight(combinedImage, value: 320)
  try engine.block.setPositionX(combinedImage, value: 740)
  try engine.block.setPositionY(combinedImage, value: 30)
  let combinedFill = try engine.block.createFill(.image)
  try engine.block.setURL(combinedFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(combinedImage, fill: combinedFill)
  try engine.block.appendChild(to: page, child: combinedImage)

  // highlight-duotone-combineEffects
  // Adjustments run first, then duotone maps the adjusted tones.
  let adjustments = try engine.block.createEffect(.adjustments)
  try engine.block.setFloat(adjustments, property: "effect/adjustments/brightness", value: 0.1)
  try engine.block.setFloat(adjustments, property: "effect/adjustments/contrast", value: 0.15)
  try engine.block.appendEffect(combinedImage, effectID: adjustments)

  let combinedDuotone = try engine.block.createEffect(.duotoneFilter)
  try engine.block.setColor(
    combinedDuotone,
    property: "effect/duotone_filter/darkColor",
    color: .rgba(r: 0.2, g: 0.1, b: 0.3, a: 1.0),
  )
  try engine.block.setColor(
    combinedDuotone,
    property: "effect/duotone_filter/lightColor",
    color: .rgba(r: 1.0, g: 0.85, b: 0.7, a: 1.0),
  )
  try engine.block.setFloat(combinedDuotone, property: "effect/duotone_filter/intensity", value: 0.75)
  try engine.block.appendEffect(combinedImage, effectID: combinedDuotone)
  // highlight-duotone-combineEffects

  try await engine.captureGuide(page, label: "hero")

  // highlight-duotone-listEffects
  let appliedEffects = try engine.block.getEffects(presetImage)
  print("Image has \(appliedEffects.count) effect(s) applied")
  // highlight-duotone-listEffects

  // highlight-duotone-toggleEffects
  if let firstEffect = appliedEffects.first {
    try engine.block.setEffectEnabled(effectID: firstEffect, enabled: false)
    let isEnabled = try engine.block.isEffectEnabled(effectID: firstEffect)
    print("Effect enabled: \(isEnabled)")
    try engine.block.setEffectEnabled(effectID: firstEffect, enabled: true)
  }
  // highlight-duotone-toggleEffects

  // highlight-duotone-removeEffect
  let customEffects = try engine.block.getEffects(customImage)
  if let effectToRemove = customEffects.first {
    // Detach the effect from the block's stack, then destroy it to free its resources.
    try engine.block.removeEffect(customImage, index: 0)
    try engine.block.destroy(effectToRemove)
  }
  // highlight-duotone-removeEffect
}

// highlight-duotone-hexHelper
/// Converts a `#rrggbb` (or `rrggbb`) hex string to a `Color` with channels in the 0–1 range.
private func hexToRGBA(_ hex: String) -> Color {
  let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
  let value = UInt64(cleaned, radix: 16) ?? 0
  let red = Float((value >> 16) & 0xFF) / 255
  let green = Float((value >> 8) & 0xFF) / 255
  let blue = Float(value & 0xFF) / 255
  return .rgba(r: red, g: green, b: blue, a: 1.0)
}

// highlight-duotone-hexHelper
