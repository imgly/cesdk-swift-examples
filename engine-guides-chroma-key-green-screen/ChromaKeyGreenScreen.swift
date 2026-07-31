import Foundation
import IMGLYEngine

@MainActor
func chromaKeyGreenScreen(engine: Engine) async throws {
  // Demo scaffolding: a scene with one page, plus synthesized green-screen
  // footage — an astronaut sticker flattened onto a uniform green backdrop,
  // exported into an engine buffer — so the example has a keyable frame to work with.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL

  let backdrop = try engine.block.create(.graphic)
  try engine.block.setShape(backdrop, shape: engine.block.createShape(.rect))
  let backdropFill = try engine.block.createFill(.color)
  try engine.block.setColor(backdropFill, property: "fill/color/value", color: .rgba(r: 0, g: 0.8, b: 0.25, a: 1))
  try engine.block.setFill(backdrop, fill: backdropFill)
  try engine.block.setWidth(backdrop, value: 800)
  try engine.block.setHeight(backdrop, value: 600)
  try engine.block.setPositionX(backdrop, value: 0)
  try engine.block.setPositionY(backdrop, value: 0)
  try engine.block.appendChild(to: page, child: backdrop)

  let subject = try engine.block.create(.graphic)
  try engine.block.setShape(subject, shape: engine.block.createShape(.rect))
  let subjectFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    subjectFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.sticker/images/3Dstickers/3d_stickers_astronaut.png"),
  )
  try engine.block.setFill(subject, fill: subjectFill)
  try engine.block.setWidth(subject, value: 360)
  try engine.block.setHeight(subject, value: 400)
  try engine.block.setPositionX(subject, value: 220)
  try engine.block.setPositionY(subject, value: 130)
  try engine.block.appendChild(to: page, child: subject)

  let frameData = try await engine.block.export(page, mimeType: .png)
  // Keep the buffer alive while the image fill references it.
  // Destroy it when the fill is no longer needed.
  let frameURL = engine.editor.createBuffer()
  try engine.editor.setBufferData(url: frameURL, offset: 0, data: frameData)
  try engine.block.destroy(backdrop)
  try engine.block.destroy(subject)

  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: frameURL)
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.setWidth(imageBlock, value: 600)
  try engine.block.setHeight(imageBlock, value: 450)
  try engine.block.setPositionX(imageBlock, value: 100)
  try engine.block.setPositionY(imageBlock, value: 75)
  try engine.block.appendChild(to: page, child: imageBlock)

  try await engine.captureGuide(page, label: "before-key")

  // highlight-chromaKey-createEffect
  let greenScreenEffect = try engine.block.createEffect(.greenScreen)
  try engine.block.appendEffect(imageBlock, effectID: greenScreenEffect)
  // highlight-chromaKey-createEffect

  // highlight-chromaKey-configureColor
  try engine.block.setColor(
    greenScreenEffect,
    property: "effect/green_screen/fromColor",
    color: .rgba(r: 0, g: 0.8, b: 0.25, a: 1),
  )
  // highlight-chromaKey-configureColor

  try await engine.captureGuide(page, label: "after-color")

  // highlight-chromaKey-colorMatch
  try engine.block.setFloat(greenScreenEffect, property: "effect/green_screen/colorMatch", value: 0.26)
  // highlight-chromaKey-colorMatch

  // highlight-chromaKey-smoothness
  try engine.block.setFloat(greenScreenEffect, property: "effect/green_screen/smoothness", value: 0.15)
  // highlight-chromaKey-smoothness

  // highlight-chromaKey-spill
  try engine.block.setFloat(greenScreenEffect, property: "effect/green_screen/spill", value: 0.4)
  // highlight-chromaKey-spill

  try await engine.captureGuide(page, label: "after-tuning")

  // highlight-chromaKey-composite
  let backgroundBlock = try engine.block.create(.graphic)
  try engine.block.setShape(backgroundBlock, shape: engine.block.createShape(.rect))
  let backgroundFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    backgroundFill,
    property: "fill/color/value",
    color: .rgba(r: 0.2, g: 0.4, b: 0.8, a: 1),
  )
  try engine.block.setFill(backgroundBlock, fill: backgroundFill)
  try engine.block.setWidth(backgroundBlock, value: 800)
  try engine.block.setHeight(backgroundBlock, value: 600)
  try engine.block.setPositionX(backgroundBlock, value: 0)
  try engine.block.setPositionY(backgroundBlock, value: 0)
  try engine.block.appendChild(to: page, child: backgroundBlock)
  try engine.block.sendToBack(backgroundBlock)
  try engine.block.bringToFront(imageBlock)
  // highlight-chromaKey-composite

  try await engine.captureGuide(page, label: "hero")

  // highlight-chromaKey-checkEnabled
  let isEnabled = try engine.block.isEffectEnabled(effectID: greenScreenEffect)
  print("Green screen effect enabled: \(isEnabled)")
  // highlight-chromaKey-checkEnabled

  // highlight-chromaKey-setEnabled
  try engine.block.setEffectEnabled(effectID: greenScreenEffect, enabled: !isEnabled)
  // highlight-chromaKey-setEnabled

  // highlight-chromaKey-manageEffects
  let blockSupportsEffects = try engine.block.supportsEffects(imageBlock)
  print("Block supports effects: \(blockSupportsEffects)")

  let effects = try engine.block.getEffects(imageBlock)
  print("Number of effects: \(effects.count)")

  if let effectIndex = effects.firstIndex(of: greenScreenEffect) {
    try engine.block.removeEffect(imageBlock, index: effectIndex)
  }
  try engine.block.destroy(greenScreenEffect)
  // highlight-chromaKey-manageEffects
}
