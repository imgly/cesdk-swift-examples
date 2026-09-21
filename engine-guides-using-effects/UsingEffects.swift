import Foundation
import IMGLYEngine

@MainActor
func usingEffects(engine: Engine) async throws {
  // Demo scaffolding: a scene with one page laid out as a 2x3 comparison grid.
  // Each cell is a graphic block with an image fill of the same sample image,
  // so the result shows the same photo under different effects side by side.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  let originalCell = try makeImageCell(engine: engine, page: page, x: 20, y: 20, imageURL: imageURL)
  let pixelizeCell = try makeImageCell(engine: engine, page: page, x: 280, y: 20, imageURL: imageURL)
  let adjustmentsCell = try makeImageCell(engine: engine, page: page, x: 540, y: 20, imageURL: imageURL)
  let duotoneCell = try makeImageCell(engine: engine, page: page, x: 20, y: 300, imageURL: imageURL)
  let lutCell = try makeImageCell(engine: engine, page: page, x: 280, y: 300, imageURL: imageURL)
  let combinedCell = try makeImageCell(engine: engine, page: page, x: 540, y: 300, imageURL: imageURL)

  try await engine.captureGuide(page, label: "after-image")

  // highlight-usingEffects-supportsEffects
  let sceneSupportsEffects = try engine.block.supportsEffects(scene) // false
  let blockSupportsEffects = try engine.block.supportsEffects(originalCell) // true
  print("scene supports effects: \(sceneSupportsEffects)")
  print("graphic block supports effects: \(blockSupportsEffects)")
  // highlight-usingEffects-supportsEffects

  // highlight-usingEffects-createEffect
  let pixelize = try engine.block.createEffect(.pixelize)
  let adjustments = try engine.block.createEffect(.adjustments)
  // highlight-usingEffects-createEffect

  // highlight-usingEffects-addEffect
  try engine.block.appendEffect(pixelizeCell, effectID: pixelize)
  try engine.block.appendEffect(adjustmentsCell, effectID: adjustments)
  // highlight-usingEffects-addEffect

  // highlight-usingEffects-getProperties
  let pixelizeProperties = try engine.block.findAllProperties(pixelize)
  let adjustmentProperties = try engine.block.findAllProperties(adjustments)
  print("pixelize properties: \(pixelizeProperties)")
  print("adjustment properties: \(adjustmentProperties)")
  // highlight-usingEffects-getProperties

  // highlight-usingEffects-modifyProperties
  try engine.block.setInt(pixelize, property: "effect/pixelize/horizontalPixelSize", value: 10)
  try engine.block.setFloat(adjustments, property: "effect/adjustments/brightness", value: 0.2)
  try engine.block.setFloat(adjustments, property: "effect/adjustments/contrast", value: 0.15)
  // highlight-usingEffects-modifyProperties

  // highlight-usingEffects-lutFilter
  let lutFilter = try engine.block.createEffect(.lutFilter)
  try engine.block.setURL(
    lutFilter,
    property: "effect/lut_filter/lutFileURI",
    value: baseURL.appendingPathComponent("ly.img.filter.lut/LUTs/imgly_lut_ad1920_5_5_128.png"),
  )
  try engine.block.setInt(lutFilter, property: "effect/lut_filter/horizontalTileCount", value: 5)
  try engine.block.setInt(lutFilter, property: "effect/lut_filter/verticalTileCount", value: 5)
  try engine.block.setFloat(lutFilter, property: "effect/lut_filter/intensity", value: 0.9)
  try engine.block.appendEffect(lutCell, effectID: lutFilter)
  // highlight-usingEffects-lutFilter

  // highlight-usingEffects-duotoneFilter
  let duotone = try engine.block.createEffect(.duotoneFilter)
  try engine.block.setColor(
    duotone,
    property: "effect/duotone_filter/darkColor",
    color: .rgba(r: 0.1, g: 0.2, b: 0.4, a: 1),
  )
  try engine.block.setColor(
    duotone,
    property: "effect/duotone_filter/lightColor",
    color: .rgba(r: 0.95, g: 0.85, b: 0.6, a: 1),
  )
  try engine.block.setFloat(duotone, property: "effect/duotone_filter/intensity", value: 0.8)
  try engine.block.appendEffect(duotoneCell, effectID: duotone)
  // highlight-usingEffects-duotoneFilter

  try await engine.captureGuide(page, label: "after-effects")

  // highlight-usingEffects-combineEffects
  let comboAdjustments = try engine.block.createEffect(.adjustments)
  try engine.block.setFloat(comboAdjustments, property: "effect/adjustments/brightness", value: 0.2)
  let comboDuotone = try engine.block.createEffect(.duotoneFilter)
  try engine.block.setColor(
    comboDuotone,
    property: "effect/duotone_filter/lightColor",
    color: .rgba(r: 0.95, g: 0.85, b: 0.6, a: 1),
  )
  try engine.block.setFloat(comboDuotone, property: "effect/duotone_filter/intensity", value: 0.6)
  let comboPixelize = try engine.block.createEffect(.pixelize)
  try engine.block.setInt(comboPixelize, property: "effect/pixelize/horizontalPixelSize", value: 6)

  try engine.block.appendEffect(combinedCell, effectID: comboDuotone)
  try engine.block.appendEffect(combinedCell, effectID: comboPixelize)
  try engine.block.insertEffect(combinedCell, effectID: comboAdjustments, index: 0)
  // highlight-usingEffects-combineEffects

  // highlight-usingEffects-getEffects
  let effectsList = try engine.block.getEffects(combinedCell)
  print("applied effects: \(effectsList)")
  // highlight-usingEffects-getEffects

  try await engine.captureGuide(page, label: "hero")

  // highlight-usingEffects-disableEffect
  try engine.block.setEffectEnabled(effectID: comboPixelize, enabled: false)
  let pixelizeEnabled = try engine.block.isEffectEnabled(effectID: comboPixelize)
  print("pixelize enabled: \(pixelizeEnabled)")
  // highlight-usingEffects-disableEffect

  // highlight-usingEffects-destroyEffect
  try engine.block.removeEffect(combinedCell, index: 2)
  try engine.block.destroy(comboPixelize)
  // highlight-usingEffects-destroyEffect

  // highlight-usingEffects-batchProcessing
  let graphicBlocks = try engine.block.find(byType: .graphic)
  for graphic in graphicBlocks {
    guard try engine.block.supportsEffects(graphic) else { continue }
    let batchAdjustments = try engine.block.createEffect(.adjustments)
    try engine.block.setFloat(batchAdjustments, property: "effect/adjustments/brightness", value: 0.1)
    try engine.block.appendEffect(graphic, effectID: batchAdjustments)
  }
  // highlight-usingEffects-batchProcessing

  try applyVintagePreset(engine: engine, to: originalCell)
}

@MainActor
private func makeImageCell(
  engine: Engine,
  page: DesignBlockID,
  x: Float,
  y: Float,
  imageURL: URL,
) throws -> DesignBlockID {
  let cell = try engine.block.create(.graphic)
  try engine.block.setShape(cell, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(cell, value: x)
  try engine.block.setPositionY(cell, value: y)
  try engine.block.setWidth(cell, value: 240)
  try engine.block.setHeight(cell, value: 260)
  let fill = try engine.block.createFill(.image)
  try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(cell, fill: fill)
  try engine.block.appendChild(to: page, child: cell)
  return cell
}

// highlight-usingEffects-presets
@MainActor
private func applyVintagePreset(engine: Engine, to block: DesignBlockID) throws {
  let adjustments = try engine.block.createEffect(.adjustments)
  try engine.block.setFloat(adjustments, property: "effect/adjustments/contrast", value: -0.15)
  try engine.block.setFloat(adjustments, property: "effect/adjustments/saturation", value: -0.2)
  try engine.block.appendEffect(block, effectID: adjustments)

  let duotone = try engine.block.createEffect(.duotoneFilter)
  try engine.block.setColor(
    duotone,
    property: "effect/duotone_filter/darkColor",
    color: .rgba(r: 0.2, g: 0.15, b: 0.1, a: 1),
  )
  try engine.block.setColor(
    duotone,
    property: "effect/duotone_filter/lightColor",
    color: .rgba(r: 0.95, g: 0.9, b: 0.75, a: 1),
  )
  try engine.block.setFloat(duotone, property: "effect/duotone_filter/intensity", value: 0.4)
  try engine.block.appendEffect(block, effectID: duotone)
}

// highlight-usingEffects-presets
