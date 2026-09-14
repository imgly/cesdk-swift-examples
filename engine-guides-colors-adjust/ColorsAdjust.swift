import Foundation
import IMGLYEngine

@MainActor
func colorsAdjust(engine: Engine) async throws {
  // highlight-colorsAdjust-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let imageURI = "https://img.ly/static/ubq_samples/sample_1.jpg"

  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(imageBlock, value: 400)
  try engine.block.setHeight(imageBlock, value: 300)
  try engine.block.setPositionX(imageBlock, value: 200)
  try engine.block.setPositionY(imageBlock, value: 150)
  try engine.block.appendChild(to: page, child: imageBlock)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(imageFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(imageBlock, fill: imageFill)
  // highlight-colorsAdjust-setup

  // highlight-colorsAdjust-checkSupport
  // Not every block type supports effects. Pages return false, while image and
  // graphic blocks return true.
  let supportsEffects = try engine.block.supportsEffects(imageBlock)
  print("Block supports effects: \(supportsEffects)")
  // highlight-colorsAdjust-checkSupport

  // highlight-colorsAdjust-createAdjustments
  // Create an adjustments effect and attach it to the image block. A block can
  // hold one adjustments effect in its effect stack; it exposes every color
  // adjustment property through a single effect instance.
  let adjustmentsEffect = try engine.block.createEffect(.adjustments)
  try engine.block.appendEffect(imageBlock, effectID: adjustmentsEffect)
  // highlight-colorsAdjust-createAdjustments

  // highlight-colorsAdjust-setProperties
  // Each adjustment property uses the "effect/adjustments/" prefix followed by
  // the property name.
  try engine.block.setFloat(adjustmentsEffect, property: "effect/adjustments/brightness", value: 0.4)
  try engine.block.setFloat(adjustmentsEffect, property: "effect/adjustments/contrast", value: 0.35)
  try engine.block.setFloat(adjustmentsEffect, property: "effect/adjustments/saturation", value: 0.5)
  try engine.block.setFloat(adjustmentsEffect, property: "effect/adjustments/temperature", value: 0.25)
  // highlight-colorsAdjust-setProperties

  // highlight-colorsAdjust-readValues
  // Read a single adjustment value with getFloat, or list every property on the
  // adjustments effect with findAllProperties.
  let brightness = try engine.block.getFloat(adjustmentsEffect, property: "effect/adjustments/brightness")
  print("Current brightness: \(brightness)")

  let allProperties = try engine.block.findAllProperties(adjustmentsEffect)
  print("Available adjustment properties: \(allProperties)")
  // highlight-colorsAdjust-readValues

  // highlight-colorsAdjust-enableDisable
  // Toggle the adjustments effect without removing it. The values remain
  // attached; only rendering is suppressed while disabled.
  try engine.block.setEffectEnabled(effectID: adjustmentsEffect, enabled: false)
  let isEnabled = try engine.block.isEffectEnabled(effectID: adjustmentsEffect)
  print("Adjustments enabled: \(isEnabled)")

  try engine.block.setEffectEnabled(effectID: adjustmentsEffect, enabled: true)
  // highlight-colorsAdjust-enableDisable

  // highlight-colorsAdjust-combineEffects
  // Combine adjustments to create a distinct visual style. Here we build a
  // moody look with darker brightness, higher contrast, and lower saturation.
  let secondImageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(secondImageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(secondImageBlock, value: 200)
  try engine.block.setHeight(secondImageBlock, value: 150)
  try engine.block.setPositionX(secondImageBlock, value: 50)
  try engine.block.setPositionY(secondImageBlock, value: 50)
  try engine.block.appendChild(to: page, child: secondImageBlock)
  let secondFill = try engine.block.createFill(.image)
  try engine.block.setString(secondFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(secondImageBlock, fill: secondFill)

  let combinedAdjustments = try engine.block.createEffect(.adjustments)
  try engine.block.appendEffect(secondImageBlock, effectID: combinedAdjustments)
  try engine.block.setFloat(combinedAdjustments, property: "effect/adjustments/brightness", value: -0.15)
  try engine.block.setFloat(combinedAdjustments, property: "effect/adjustments/contrast", value: 0.4)
  try engine.block.setFloat(combinedAdjustments, property: "effect/adjustments/saturation", value: -0.3)

  let effects = try engine.block.getEffects(secondImageBlock)
  print("Effects on second image: \(effects.count)")
  // highlight-colorsAdjust-combineEffects

  // highlight-colorsAdjust-refinementAdjustments
  // Refinement properties target image detail and tonal balance rather than
  // global color shifts.
  let tempBlock = try engine.block.create(.graphic)
  try engine.block.setShape(tempBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(tempBlock, value: 150)
  try engine.block.setHeight(tempBlock, value: 100)
  try engine.block.setPositionX(tempBlock, value: 550)
  try engine.block.setPositionY(tempBlock, value: 50)
  try engine.block.appendChild(to: page, child: tempBlock)
  let tempFill = try engine.block.createFill(.image)
  try engine.block.setString(tempFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(tempBlock, fill: tempFill)

  let refinementEffect = try engine.block.createEffect(.adjustments)
  try engine.block.appendEffect(tempBlock, effectID: refinementEffect)
  try engine.block.setFloat(refinementEffect, property: "effect/adjustments/sharpness", value: 0.4)
  try engine.block.setFloat(refinementEffect, property: "effect/adjustments/clarity", value: 0.35)
  try engine.block.setFloat(refinementEffect, property: "effect/adjustments/highlights", value: -0.2)
  try engine.block.setFloat(refinementEffect, property: "effect/adjustments/shadows", value: 0.3)
  // highlight-colorsAdjust-refinementAdjustments

  // highlight-colorsAdjust-removeAdjustments
  // Remove an effect by its index in the stack, then destroy the returned
  // effect block to free its resources.
  let tempEffects = try engine.block.getEffects(tempBlock)
  if let effectIndex = tempEffects.firstIndex(of: refinementEffect) {
    try engine.block.removeEffect(tempBlock, index: effectIndex)
  }
  try engine.block.destroy(refinementEffect)
  // highlight-colorsAdjust-removeAdjustments
}
