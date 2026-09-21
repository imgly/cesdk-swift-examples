import Foundation
import IMGLYEngine

@MainActor
func shadowsAndGlows(engine: Engine) async throws {
  let scene = try engine.scene.create(designUnit: .px)

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // A gradient page fill gives the shadows and glows a backdrop to stand out against.
  let gradientFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(gradientFill, property: "fill/gradient/colors", colors: [
    GradientColorStop(color: .rgba(r: 0.0, g: 0.75, b: 0.85, a: 1.0), stop: 0.0),
    GradientColorStop(color: .rgba(r: 0.95, g: 0.85, b: 0.7, a: 1.0), stop: 0.5),
    GradientColorStop(color: .rgba(r: 0.85, g: 0.55, b: 0.45, a: 1.0), stop: 1.0),
  ])
  try engine.block.setFloat(gradientFill, property: "fill/gradient/linear/startPointX", value: 0)
  try engine.block.setFloat(gradientFill, property: "fill/gradient/linear/startPointY", value: 0)
  try engine.block.setFloat(gradientFill, property: "fill/gradient/linear/endPointX", value: 1)
  try engine.block.setFloat(gradientFill, property: "fill/gradient/linear/endPointY", value: 1)
  try engine.block.setFill(page, fill: gradientFill)

  let baseURL = try engine.guidesBaseURL

  // A title text block to carry the drop shadow.
  let textBlock = try engine.block.create(.text)
  try engine.block.replaceText(textBlock, text: "Shadows & Glows")
  try engine.block.setTextFontSize(textBlock, fontSize: 80)
  try engine.block.setTextColor(textBlock, color: .rgba(r: 1.0, g: 1.0, b: 1.0, a: 1.0))
  try engine.block.setWidthMode(textBlock, mode: .auto)
  try engine.block.setHeightMode(textBlock, mode: .auto)
  try engine.block.setPositionX(textBlock, value: 40)
  try engine.block.setPositionY(textBlock, value: 40)
  try engine.block.appendChild(to: page, child: textBlock)

  // highlight-shadowsAndGlows-checkDropShadowSupport
  let supportsDropShadow = try engine.block.supportsDropShadow(textBlock)
  print("Block supports drop shadow: \(supportsDropShadow)")
  // highlight-shadowsAndGlows-checkDropShadowSupport

  if supportsDropShadow {
    // highlight-shadowsAndGlows-enableDropShadow
    try engine.block.setDropShadowEnabled(textBlock, enabled: true)
    let shadowEnabled = try engine.block.isDropShadowEnabled(textBlock)
    print("Drop shadow enabled: \(shadowEnabled)")
    // highlight-shadowsAndGlows-enableDropShadow

    // highlight-shadowsAndGlows-setColor
    try engine.block.setDropShadowColor(textBlock, color: .rgba(r: 0.0, g: 0.3, b: 0.4, a: 0.8))
    let shadowColor: Color = try engine.block.getDropShadowColor(textBlock)
    print("Drop shadow color: \(shadowColor)")
    // highlight-shadowsAndGlows-setColor

    // highlight-shadowsAndGlows-setOffset
    try engine.block.setDropShadowOffsetX(textBlock, offsetX: 6)
    try engine.block.setDropShadowOffsetY(textBlock, offsetY: 6)
    let offsetX = try engine.block.getDropShadowOffsetX(textBlock)
    let offsetY = try engine.block.getDropShadowOffsetY(textBlock)
    print("Drop shadow offset: \(offsetX), \(offsetY)")
    // highlight-shadowsAndGlows-setOffset

    // highlight-shadowsAndGlows-setBlur
    try engine.block.setDropShadowBlurRadiusX(textBlock, blurRadiusX: 12)
    try engine.block.setDropShadowBlurRadiusY(textBlock, blurRadiusY: 12)
    let blurX = try engine.block.getDropShadowBlurRadiusX(textBlock)
    let blurY = try engine.block.getDropShadowBlurRadiusY(textBlock)
    print("Drop shadow blur: \(blurX), \(blurY)")
    // highlight-shadowsAndGlows-setBlur
  }

  try await engine.captureGuide(page, label: "after-drop-shadow")

  // An image block to carry the glow effect.
  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(imageBlock, value: 440)
  try engine.block.setPositionY(imageBlock, value: 220)
  try engine.block.setWidth(imageBlock, value: 300)
  try engine.block.setHeight(imageBlock, value: 300)
  try engine.block.appendChild(to: page, child: imageBlock)
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_4.jpg"),
  )
  try engine.block.setFill(imageBlock, fill: imageFill)

  // highlight-shadowsAndGlows-checkGlowSupport
  let supportsEffects = try engine.block.supportsEffects(imageBlock)
  print("Block supports effects: \(supportsEffects)")
  // highlight-shadowsAndGlows-checkGlowSupport

  if supportsEffects {
    // highlight-shadowsAndGlows-createGlow
    let glow = try engine.block.createEffect(.glow)
    try engine.block.appendEffect(imageBlock, effectID: glow)
    // highlight-shadowsAndGlows-createGlow

    // highlight-shadowsAndGlows-configureGlow
    try engine.block.setFloat(glow, property: "effect/glow/size", value: 10)
    try engine.block.setFloat(glow, property: "effect/glow/amount", value: 0.7)
    try engine.block.setFloat(glow, property: "effect/glow/darkness", value: 0.25)
    // highlight-shadowsAndGlows-configureGlow
  }

  try await engine.captureGuide(page, label: "after-glow")

  // A second image block to carry both a drop shadow and a glow at once.
  let combinedBlock = try engine.block.create(.graphic)
  try engine.block.setShape(combinedBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(combinedBlock, value: 60)
  try engine.block.setPositionY(combinedBlock, value: 220)
  try engine.block.setWidth(combinedBlock, value: 300)
  try engine.block.setHeight(combinedBlock, value: 300)
  try engine.block.appendChild(to: page, child: combinedBlock)
  let combinedFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    combinedFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_5.jpg"),
  )
  try engine.block.setFill(combinedBlock, fill: combinedFill)

  // highlight-shadowsAndGlows-combine
  if try engine.block.supportsDropShadow(combinedBlock) {
    try engine.block.setDropShadowEnabled(combinedBlock, enabled: true)
    try engine.block.setDropShadowColor(combinedBlock, color: .rgba(r: 0.0, g: 0.2, b: 0.3, a: 0.6))
    try engine.block.setDropShadowOffsetX(combinedBlock, offsetX: 8)
    try engine.block.setDropShadowOffsetY(combinedBlock, offsetY: 8)
    try engine.block.setDropShadowBlurRadiusX(combinedBlock, blurRadiusX: 20)
    try engine.block.setDropShadowBlurRadiusY(combinedBlock, blurRadiusY: 20)
    try engine.block.setDropShadowClip(combinedBlock, clip: false)
    let clipsToShape = try engine.block.getDropShadowClip(combinedBlock)
    print("Drop shadow clips to shape: \(clipsToShape)")
  }
  if try engine.block.supportsEffects(combinedBlock) {
    let combinedGlow = try engine.block.createEffect(.glow)
    try engine.block.appendEffect(combinedBlock, effectID: combinedGlow)
    try engine.block.setFloat(combinedGlow, property: "effect/glow/size", value: 8)
    try engine.block.setFloat(combinedGlow, property: "effect/glow/amount", value: 0.5)
    try engine.block.setFloat(combinedGlow, property: "effect/glow/darkness", value: 0.15)
  }
  // highlight-shadowsAndGlows-combine

  try await engine.captureGuide(page, label: "hero")

  // highlight-shadowsAndGlows-toggleShadow
  let shadowWasEnabled = try engine.block.isDropShadowEnabled(textBlock)
  try engine.block.setDropShadowEnabled(textBlock, enabled: false)
  let shadowAfterDisable = try engine.block.isDropShadowEnabled(textBlock)
  try engine.block.setDropShadowEnabled(textBlock, enabled: shadowWasEnabled)
  let shadowAfterRestore = try engine.block.isDropShadowEnabled(textBlock)
  print("Drop shadow toggled off then on: \(shadowAfterDisable) -> \(shadowAfterRestore)")
  // highlight-shadowsAndGlows-toggleShadow

  // highlight-shadowsAndGlows-toggleGlow
  let effects = try engine.block.getEffects(imageBlock)
  if let glowEffect = effects.first {
    try engine.block.setEffectEnabled(effectID: glowEffect, enabled: false)
    let glowAfterDisable = try engine.block.isEffectEnabled(effectID: glowEffect)
    try engine.block.setEffectEnabled(effectID: glowEffect, enabled: true)
    let glowAfterRestore = try engine.block.isEffectEnabled(effectID: glowEffect)
    print("Glow toggled off then on: \(glowAfterDisable) -> \(glowAfterRestore)")
  }
  // highlight-shadowsAndGlows-toggleGlow

  // highlight-shadowsAndGlows-removeGlow
  let attachedEffects = try engine.block.getEffects(imageBlock)
  if let glowToRemove = attachedEffects.first {
    try engine.block.removeEffect(imageBlock, index: 0)
    try engine.block.destroy(glowToRemove)
  }
  // highlight-shadowsAndGlows-removeGlow
}
