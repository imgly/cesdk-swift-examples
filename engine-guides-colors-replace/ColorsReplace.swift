import Foundation
import IMGLYEngine

@MainActor
func colorsReplace(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-colorsReplace-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  // highlight-colorsReplace-setup

  // highlight-colorsReplace-createRecolor
  // Create a Recolor effect that swaps red pixels for blue, then attach it to
  // an image block using `appendEffect`.
  let recolorBlock = try engine.block.create(.graphic)
  try engine.block.setShape(recolorBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(recolorBlock, value: 50)
  try engine.block.setPositionY(recolorBlock, value: 50)
  try engine.block.setWidth(recolorBlock, value: 200)
  try engine.block.setHeight(recolorBlock, value: 150)
  try engine.block.appendChild(to: page, child: recolorBlock)

  let recolorFill = try engine.block.createFill(.image)
  try engine.block.setURL(recolorFill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(recolorBlock, fill: recolorFill)

  let recolorEffect = try engine.block.createEffect(.recolor)
  try engine.block.setColor(
    recolorEffect,
    property: "effect/recolor/fromColor",
    color: .rgba(r: 1, g: 0, b: 0, a: 1),
  )
  try engine.block.setColor(
    recolorEffect,
    property: "effect/recolor/toColor",
    color: .rgba(r: 0, g: 0.5, b: 1, a: 1),
  )
  try engine.block.appendEffect(recolorBlock, effectID: recolorEffect)
  // highlight-colorsReplace-createRecolor

  // highlight-colorsReplace-configureRecolor
  // Fine-tune which pixels the Recolor effect affects. All three tolerances
  // accept values between `0` and `1`.
  let tolerancesBlock = try engine.block.create(.graphic)
  try engine.block.setShape(tolerancesBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(tolerancesBlock, value: 300)
  try engine.block.setPositionY(tolerancesBlock, value: 50)
  try engine.block.setWidth(tolerancesBlock, value: 200)
  try engine.block.setHeight(tolerancesBlock, value: 150)
  try engine.block.appendChild(to: page, child: tolerancesBlock)

  let tolerancesFill = try engine.block.createFill(.image)
  try engine.block.setURL(tolerancesFill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(tolerancesBlock, fill: tolerancesFill)

  let tolerancesEffect = try engine.block.createEffect(.recolor)
  try engine.block.setColor(
    tolerancesEffect,
    property: "effect/recolor/fromColor",
    color: .rgba(r: 0.8, g: 0.6, b: 0.4, a: 1),
  )
  try engine.block.setColor(
    tolerancesEffect,
    property: "effect/recolor/toColor",
    color: .rgba(r: 0.3, g: 0.7, b: 0.3, a: 1),
  )
  try engine.block.setFloat(tolerancesEffect, property: "effect/recolor/colorMatch", value: 0.3)
  try engine.block.setFloat(tolerancesEffect, property: "effect/recolor/brightnessMatch", value: 0.2)
  try engine.block.setFloat(tolerancesEffect, property: "effect/recolor/smoothness", value: 0.1)
  try engine.block.appendEffect(tolerancesBlock, effectID: tolerancesEffect)
  // highlight-colorsReplace-configureRecolor

  // highlight-colorsReplace-createGreenScreen
  // Create a Green Screen effect. `fromColor` picks the color to remove; any
  // pixel close enough to that color becomes transparent.
  let greenScreenBlock = try engine.block.create(.graphic)
  try engine.block.setShape(greenScreenBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(greenScreenBlock, value: 550)
  try engine.block.setPositionY(greenScreenBlock, value: 50)
  try engine.block.setWidth(greenScreenBlock, value: 200)
  try engine.block.setHeight(greenScreenBlock, value: 150)
  try engine.block.appendChild(to: page, child: greenScreenBlock)

  let greenScreenFill = try engine.block.createFill(.image)
  try engine.block.setURL(greenScreenFill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(greenScreenBlock, fill: greenScreenFill)

  let greenScreenEffect = try engine.block.createEffect(.greenScreen)
  try engine.block.setColor(
    greenScreenEffect,
    property: "effect/green_screen/fromColor",
    color: .rgba(r: 0, g: 1, b: 0, a: 1),
  )
  try engine.block.appendEffect(greenScreenBlock, effectID: greenScreenEffect)
  // highlight-colorsReplace-createGreenScreen

  // highlight-colorsReplace-configureGreenScreen
  // Control how the Green Screen effect cuts out the background. `spill`
  // reduces color bleed from the removed background onto subject edges.
  let spillBlock = try engine.block.create(.graphic)
  try engine.block.setShape(spillBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(spillBlock, value: 50)
  try engine.block.setPositionY(spillBlock, value: 250)
  try engine.block.setWidth(spillBlock, value: 200)
  try engine.block.setHeight(spillBlock, value: 150)
  try engine.block.appendChild(to: page, child: spillBlock)

  let spillFill = try engine.block.createFill(.image)
  try engine.block.setURL(spillFill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(spillBlock, fill: spillFill)

  let spillEffect = try engine.block.createEffect(.greenScreen)
  try engine.block.setColor(
    spillEffect,
    property: "effect/green_screen/fromColor",
    color: .rgba(r: 0.2, g: 0.8, b: 0.3, a: 1),
  )
  try engine.block.setFloat(spillEffect, property: "effect/green_screen/colorMatch", value: 0.4)
  try engine.block.setFloat(spillEffect, property: "effect/green_screen/smoothness", value: 0.2)
  try engine.block.setFloat(spillEffect, property: "effect/green_screen/spill", value: 0.5)
  try engine.block.appendEffect(spillBlock, effectID: spillEffect)
  // highlight-colorsReplace-configureGreenScreen

  // highlight-colorsReplace-manageEffects
  // Stack multiple Recolor effects on a single block, then toggle individual
  // entries with `setEffectEnabled` without removing them from the stack.
  let stackedBlock = try engine.block.create(.graphic)
  try engine.block.setShape(stackedBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(stackedBlock, value: 300)
  try engine.block.setPositionY(stackedBlock, value: 250)
  try engine.block.setWidth(stackedBlock, value: 200)
  try engine.block.setHeight(stackedBlock, value: 150)
  try engine.block.appendChild(to: page, child: stackedBlock)

  let stackedFill = try engine.block.createFill(.image)
  try engine.block.setURL(stackedFill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(stackedBlock, fill: stackedFill)

  let redToBlue = try engine.block.createEffect(.recolor)
  try engine.block.setColor(redToBlue, property: "effect/recolor/fromColor", color: .rgba(r: 1, g: 0, b: 0, a: 1))
  try engine.block.setColor(redToBlue, property: "effect/recolor/toColor", color: .rgba(r: 0, g: 0, b: 1, a: 1))
  try engine.block.appendEffect(stackedBlock, effectID: redToBlue)

  let greenToOrange = try engine.block.createEffect(.recolor)
  try engine.block.setColor(greenToOrange, property: "effect/recolor/fromColor", color: .rgba(r: 0, g: 1, b: 0, a: 1))
  try engine.block.setColor(greenToOrange, property: "effect/recolor/toColor", color: .rgba(r: 1, g: 0.5, b: 0, a: 1))
  try engine.block.appendEffect(stackedBlock, effectID: greenToOrange)

  let stackedEffects = try engine.block.getEffects(stackedBlock)
  print("Number of effects: \(stackedEffects.count)") // 2

  try engine.block.setEffectEnabled(effectID: stackedEffects[0], enabled: false)
  let isEnabled = try engine.block.isEffectEnabled(effectID: stackedEffects[0])
  print("First effect enabled: \(isEnabled)") // false
  // highlight-colorsReplace-manageEffects

  // highlight-colorsReplace-batchProcessing
  // Apply a consistent Recolor effect to every graphic block in the scene.
  // Skip blocks that already carry an effect so existing work isn't overwritten.
  let batchBlock = try engine.block.create(.graphic)
  try engine.block.setShape(batchBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(batchBlock, value: 550)
  try engine.block.setPositionY(batchBlock, value: 250)
  try engine.block.setWidth(batchBlock, value: 200)
  try engine.block.setHeight(batchBlock, value: 150)
  try engine.block.appendChild(to: page, child: batchBlock)

  let batchFill = try engine.block.createFill(.image)
  try engine.block.setURL(batchFill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(batchBlock, fill: batchFill)

  let allGraphicBlocks = try engine.block.find(byType: .graphic)
  for blockID in allGraphicBlocks {
    if try engine.block.getEffects(blockID).isEmpty == false {
      continue
    }
    let batchRecolor = try engine.block.createEffect(.recolor)
    try engine.block.setColor(
      batchRecolor,
      property: "effect/recolor/fromColor",
      color: .rgba(r: 0.8, g: 0.7, b: 0.6, a: 1),
    )
    try engine.block.setColor(
      batchRecolor,
      property: "effect/recolor/toColor",
      color: .rgba(r: 0.6, g: 0.7, b: 0.9, a: 1),
    )
    try engine.block.setFloat(batchRecolor, property: "effect/recolor/colorMatch", value: 0.25)
    try engine.block.appendEffect(blockID, effectID: batchRecolor)
  }
  // highlight-colorsReplace-batchProcessing
}
