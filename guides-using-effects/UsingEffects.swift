import Foundation
import IMGLYEngine

@MainActor
func usingEffects(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)

  let rect = try engine.block.create(.rectShape)
  try engine.block.setPositionX(rect, value: 100)
  try engine.block.setPositionY(rect, value: 50)
  try engine.block.setWidth(rect, value: 300)
  try engine.block.setHeight(rect, value: 300)
  try engine.block.appendChild(to: page, child: rect)
  let imageFill = try engine.block.createFill("image")
  try engine.block.destroy(engine.block.getFill(rect))
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg"
  )
  try engine.block.setFill(rect, fill: imageFill)
  // highlight-setup

  // highlight-hasEffects
  try engine.block.hasEffects(scene) // Returns false
  try engine.block.hasEffects(rect) // Returns true
  // highlight-hasEffects

  // highlight-createEffect
  let pixelize = try engine.block.createEffect(type: "pixelize")
  let adjustments = try engine.block.createEffect(type: "adjustments")
  // highlight-createEffect

  // highlight-addEffect
  try engine.block.appendEffect(rect, effectID: pixelize)
  try engine.block.insertEffect(rect, effectID: adjustments, index: 0)
  // try engine.block.removeEffect(rect, index: 0)
  // highlight-addEffect

  // highlight-getEffects
  // This will return [adjustments, pixelize]
  let effectsList = try engine.block.getEffects(rect)
  // highlight-getEffects

  // highlight-destroyEffect
  let unusedEffect = try engine.block.createEffect(type: "half_tone")
  try engine.block.destroy(unusedEffect)
  // highlight-destroyEffect

  // highlight-getProperties
  let allPixelizeProperties = try engine.block.findAllProperties(pixelize)
  let allAdjustmentProperties = try engine.block.findAllProperties(adjustments)
  // highlight-getProperties
  // highlight-modifyProperties
  try engine.block.setInt(pixelize, property: "pixelize/horizontalPixelSize", value: 20)
  try engine.block.setFloat(adjustments, property: "effect/adjustments/brightness", value: 0.2)
  // highlight-modifyProperties

  // highlight-disableEffect
  try engine.block.setEffectEnabled(effectID: pixelize, enabled: false)
  try engine.block.setEffectEnabled(effectID: pixelize, enabled: !engine.block.isEffectEnabled(effectID: pixelize))
  // highlight-disableEffect
}
