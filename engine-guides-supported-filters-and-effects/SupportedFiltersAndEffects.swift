import Foundation
import IMGLYEngine

@MainActor
func supportedFiltersAndEffects(engine: Engine) async throws {
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // Resolve sample assets against the bundled asset base URL.
  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  // highlight-supportedEffects-checkSupport
  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(imageBlock, value: 600)
  try engine.block.setHeight(imageBlock, value: 450)
  try engine.block.setPositionX(imageBlock, value: 100)
  try engine.block.setPositionY(imageBlock, value: 75)
  try engine.block.appendChild(to: page, child: imageBlock)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(imageBlock, fill: imageFill)

  let canHaveEffects = try engine.block.supportsEffects(imageBlock)
  print("Block supports effects: \(canHaveEffects)")
  // highlight-supportedEffects-checkSupport

  // highlight-supportedEffects-addEffect
  let duotoneEffect = try engine.block.createEffect(.duotoneFilter)
  try engine.block.appendEffect(imageBlock, effectID: duotoneEffect)
  // highlight-supportedEffects-addEffect

  // highlight-supportedEffects-configure
  try engine.block.setColor(
    duotoneEffect,
    property: "effect/duotone_filter/darkColor",
    color: .rgba(r: 0.02, g: 0.04, b: 0.12, a: 1.0),
  )
  try engine.block.setColor(
    duotoneEffect,
    property: "effect/duotone_filter/lightColor",
    color: .rgba(r: 0.5, g: 0.7, b: 1.0, a: 1.0),
  )
  try engine.block.setFloat(duotoneEffect, property: "effect/duotone_filter/intensity", value: 0.8)
  // highlight-supportedEffects-configure

  // highlight-supportedEffects-getEffects
  let appliedEffects = try engine.block.getEffects(imageBlock)
  print("Number of applied effects: \(appliedEffects.count)")

  for (index, effect) in appliedEffects.enumerated() {
    let effectType = try engine.block.getType(effect)
    print("Effect \(index): \(effectType)")
  }
  // highlight-supportedEffects-getEffects
}
