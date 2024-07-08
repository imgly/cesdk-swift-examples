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

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(block, value: 100)
  try engine.block.setPositionY(block, value: 50)
  try engine.block.setWidth(block, value: 300)
  try engine.block.setHeight(block, value: 300)
  try engine.block.appendChild(to: page, child: block)
  let fill = try engine.block.createFill(.image)

  try engine.block.setString(
    fill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg"
  )
  try engine.block.setFill(block, fill: fill)
  // highlight-setup

  // highlight-supportsEffects
  try engine.block.supportsEffects(scene) // Returns false
  try engine.block.supportsEffects(block) // Returns true
  // highlight-supportsEffects

  // highlight-createEffect
  let pixelize = try engine.block.createEffect(.pixelize)
  let adjustments = try engine.block.createEffect(.adjustments)
  // highlight-createEffect

  // highlight-addEffect
  try engine.block.appendEffect(block, effectID: pixelize)
  try engine.block.insertEffect(block, effectID: adjustments, index: 0)
  // try engine.block.removeEffect(rect, index: 0)
  // highlight-addEffect

  // highlight-getEffects
  // This will return [adjustments, pixelize]
  let effectsList = try engine.block.getEffects(block)
  // highlight-getEffects

  // highlight-destroyEffect
  let unusedEffect = try engine.block.createEffect(.halfTone)
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
