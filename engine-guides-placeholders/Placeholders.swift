import Foundation
import IMGLYEngine

@MainActor
func placeholders(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let sampleImage1 = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  let sampleImage2 = baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg")

  // Build a sample template with an image placeholder, a text placeholder, and a
  // second "featured" image. This setup runs before any placeholder API is
  // called, so every creation call succeeds.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1200)
  try engine.block.setHeight(page, value: 800)
  try engine.block.appendChild(to: scene, child: page)

  // A graphic block backed by an image fill — the primary placeholder.
  let imagePlaceholder = try engine.block.create(.graphic)
  try engine.block.setShape(imagePlaceholder, shape: engine.block.createShape(.rect))
  let imageSetupFill = try engine.block.createFill(.image)
  try engine.block.setURL(imageSetupFill, property: "fill/image/imageFileURI", value: sampleImage1)
  try engine.block.setFill(imagePlaceholder, fill: imageSetupFill)
  try engine.block.setPositionX(imagePlaceholder, value: 80)
  try engine.block.setPositionY(imagePlaceholder, value: 250)
  try engine.block.setWidth(imagePlaceholder, value: 300)
  try engine.block.setHeight(imagePlaceholder, value: 300)
  try engine.block.appendChild(to: page, child: imagePlaceholder)

  // A text block — the text placeholder.
  let textPlaceholder = try engine.block.create(.text)
  try engine.block.setString(textPlaceholder, property: "text/text", value: "Your headline here")
  try engine.block.setFloat(textPlaceholder, property: "text/fontSize", value: 48)
  try engine.block.setPositionX(textPlaceholder, value: 80)
  try engine.block.setPositionY(textPlaceholder, value: 120)
  try engine.block.setWidth(textPlaceholder, value: 600)
  try engine.block.setHeight(textPlaceholder, value: 80)
  try engine.block.appendChild(to: page, child: textPlaceholder)

  // A second graphic block used to demonstrate the combined "Act as Placeholder" setup.
  let featuredImage = try engine.block.create(.graphic)
  try engine.block.setShape(featuredImage, shape: engine.block.createShape(.rect))
  let featuredSetupFill = try engine.block.createFill(.image)
  try engine.block.setURL(featuredSetupFill, property: "fill/image/imageFileURI", value: sampleImage2)
  try engine.block.setFill(featuredImage, fill: featuredSetupFill)
  try engine.block.setPositionX(featuredImage, value: 440)
  try engine.block.setPositionY(featuredImage, value: 250)
  try engine.block.setWidth(featuredImage, value: 300)
  try engine.block.setHeight(featuredImage, value: 300)
  try engine.block.appendChild(to: page, child: featuredImage)

  // highlight-placeholders-checkSupport
  let imageFill = try engine.block.getFill(imagePlaceholder)
  let supportsBehavior = try engine.block.supportsPlaceholderBehavior(imageFill)
  let supportsControls = try engine.block.supportsPlaceholderControls(imagePlaceholder)
  print("Image fill supports placeholder behavior:", supportsBehavior) // true
  print("Image block supports placeholder controls:", supportsControls) // true
  // highlight-placeholders-checkSupport

  // highlight-placeholders-enableBehaviorGraphic
  if try engine.block.supportsPlaceholderBehavior(imageFill) {
    try engine.block.setPlaceholderBehaviorEnabled(imageFill, enabled: true)
  }
  let behaviorEnabled = try engine.block.isPlaceholderBehaviorEnabled(imageFill)
  print("Placeholder behavior enabled on the image fill:", behaviorEnabled) // true
  // highlight-placeholders-enableBehaviorGraphic

  // highlight-placeholders-enableBehaviorText
  if try engine.block.supportsPlaceholderBehavior(textPlaceholder) {
    try engine.block.setPlaceholderBehaviorEnabled(textPlaceholder, enabled: true)
  }
  // highlight-placeholders-enableBehaviorText

  // highlight-placeholders-enableAdopterMode
  try engine.block.setPlaceholderEnabled(imagePlaceholder, enabled: true)
  let isInteractive = try engine.block.isPlaceholderEnabled(imagePlaceholder)
  print("Placeholder is interactive in Adopter mode:", isInteractive) // true
  // highlight-placeholders-enableAdopterMode

  // highlight-placeholders-fullConfiguration
  let featuredFill = try engine.block.getFill(featuredImage)
  if try engine.block.supportsPlaceholderBehavior(featuredFill) {
    try engine.block.setPlaceholderBehaviorEnabled(featuredFill, enabled: true)
  }
  if try engine.block.supportsPlaceholderControls(featuredImage) {
    try engine.block.setPlaceholderControlsOverlayEnabled(featuredImage, enabled: true)
    try engine.block.setPlaceholderControlsButtonEnabled(featuredImage, enabled: true)
  }
  // highlight-placeholders-fullConfiguration

  // highlight-placeholders-enableOverlay
  try engine.block.setPlaceholderControlsOverlayEnabled(imagePlaceholder, enabled: true)
  // highlight-placeholders-enableOverlay

  // highlight-placeholders-enableButton
  try engine.block.setPlaceholderControlsButtonEnabled(imagePlaceholder, enabled: true)
  // highlight-placeholders-enableButton

  // highlight-placeholders-scopes
  try engine.block.setScopeEnabled(imagePlaceholder, key: "fill/change", enabled: true)
  try engine.block.setScopeEnabled(imagePlaceholder, key: "fill/changeType", enabled: true)
  try engine.block.setScopeEnabled(imagePlaceholder, key: "layer/crop", enabled: true)

  try engine.block.setScopeEnabled(textPlaceholder, key: "text/edit", enabled: true)
  try engine.block.setScopeEnabled(textPlaceholder, key: "text/character", enabled: true)
  // highlight-placeholders-scopes

  // highlight-placeholders-batchOperation
  for url in [sampleImage1, sampleImage2] {
    let slot = try engine.block.create(.graphic)
    try engine.block.setShape(slot, shape: engine.block.createShape(.rect))
    let slotFill = try engine.block.createFill(.image)
    try engine.block.setURL(slotFill, property: "fill/image/imageFileURI", value: url)
    try engine.block.setFill(slot, fill: slotFill)
    try engine.block.appendChild(to: page, child: slot)

    try engine.block.setPlaceholderEnabled(slot, enabled: true)
    if try engine.block.supportsPlaceholderBehavior(slotFill) {
      try engine.block.setPlaceholderBehaviorEnabled(slotFill, enabled: true)
    }
  }
  // highlight-placeholders-batchOperation
}
