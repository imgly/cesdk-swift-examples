import Foundation
import IMGLYEngine

@MainActor
func dynamicContent(engine: Engine) async throws {
  // Resolve sample assets against the engine's configured base URL.
  let baseURL = try engine.guidesBaseURL

  // Demo scaffolding: create an 800×600 pixel page to hold the template content.
  let scene = try engine.scene.create()
  try engine.scene.setDesignUnit(.px)
  try engine.block.setFloat(scene, property: "scene/dpi", value: 72)
  try engine.block.setFloat(scene, property: "scene/pixelScaleFactor", value: 1)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // Set the Adopter role before creating the template's content so the engine
  // enforces the editing scopes configured below.
  try engine.editor.setRole("Adopter")

  // Content area: 480px wide, centered (left margin = 160px)
  let contentX: Float = 160
  let contentWidth: Float = 480

  // highlight-dynamicContent-textVariables
  try engine.variable.set(key: "firstName", value: "Jane")
  try engine.variable.set(key: "lastName", value: "Doe")
  try engine.variable.set(key: "companyName", value: "IMG.LY")

  // Create heading with variable tokens
  let headingText = try engine.block.create(.text)
  try engine.block.replaceText(
    headingText,
    text: "Welcome to {{companyName}}, {{firstName}} {{lastName}}.",
  )

  // Discover all variables in the scene
  let allVariables = engine.variable.findAll()
  print("Variables in scene:", allVariables)
  // highlight-dynamicContent-textVariables
  try engine.block.setWidth(headingText, value: contentWidth)
  try engine.block.setHeightMode(headingText, mode: .auto)
  try engine.block.setFloat(headingText, property: "text/fontSize", value: 32)
  try engine.block.setTextHorizontalAlignment(headingText, alignment: .left)
  try engine.block.appendChild(to: page, child: headingText)
  try engine.block.setPositionX(headingText, value: contentX)
  try engine.block.setPositionY(headingText, value: 200)

  // Create description with bullet points
  let descriptionText = try engine.block.create(.text)
  try engine.block.replaceText(
    descriptionText,
    text: "This example demonstrates dynamic templates.\n\n"
      + "• Text Variables — Personalize content with {{tokens}}\n"
      + "• Placeholders — Swappable images and media\n"
      + "• Editing Constraints — Protected brand elements",
  )
  try engine.block.setWidth(descriptionText, value: contentWidth)
  try engine.block.setHeightMode(descriptionText, mode: .auto)
  try engine.block.setFloat(descriptionText, property: "text/fontSize", value: 20)
  try engine.block.setTextHorizontalAlignment(descriptionText, alignment: .left)
  try engine.block.appendChild(to: page, child: descriptionText)
  try engine.block.setPositionX(descriptionText, value: contentX)
  try engine.block.setPositionY(descriptionText, value: 300)

  try await engine.captureGuide(page, label: "after-text-variables")

  // Demo scaffolding: create a hero image that the placeholder section below
  // turns into a swappable drop zone.
  let heroImage = try engine.block.create(.graphic)
  try engine.block.setShape(heroImage, shape: engine.block.createShape(.rect))
  let heroFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    heroFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(heroImage, fill: heroFill)
  try engine.block.setWidth(heroImage, value: contentWidth)
  try engine.block.setHeight(heroImage, value: 140)
  try engine.block.appendChild(to: page, child: heroImage)
  try engine.block.setPositionX(heroImage, value: contentX)
  try engine.block.setPositionY(heroImage, value: 40)

  // highlight-dynamicContent-placeholders
  // Enable placeholder behavior on the image fill
  let fill = try engine.block.getFill(heroImage)
  if try engine.block.supportsPlaceholderBehavior(fill) {
    try engine.block.setPlaceholderBehaviorEnabled(fill, enabled: true)
  }

  // Enable user interaction and visual controls on the block
  try engine.block.setPlaceholderEnabled(heroImage, enabled: true)
  if try engine.block.supportsPlaceholderControls(heroImage) {
    try engine.block.setPlaceholderControlsOverlayEnabled(heroImage, enabled: true)
    try engine.block.setPlaceholderControlsButtonEnabled(heroImage, enabled: true)
  }

  // Find all placeholders in the scene
  let placeholders = engine.block.findAllPlaceholders()
  print("Placeholders in scene:", placeholders.count)
  // highlight-dynamicContent-placeholders

  // Demo scaffolding: create a brand image that the constraints section below
  // protects from user edits.
  let brandImage = try engine.block.create(.graphic)
  try engine.block.setShape(brandImage, shape: engine.block.createShape(.rect))
  let brandFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    brandFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_4.jpg"),
  )
  try engine.block.setFill(brandImage, fill: brandFill)
  try engine.block.setWidth(brandImage, value: 100)
  try engine.block.setHeight(brandImage, value: 25)
  try engine.block.appendChild(to: page, child: brandImage)
  try engine.block.setPositionX(brandImage, value: 350)
  try engine.block.setPositionY(brandImage, value: 540)

  // highlight-dynamicContent-editingConstraints
  // Lock the brand image: prevent moving, resizing, and selection
  try engine.block.setScopeEnabled(brandImage, key: "layer/move", enabled: false)
  try engine.block.setScopeEnabled(brandImage, key: "layer/resize", enabled: false)
  try engine.block.setScopeEnabled(brandImage, key: "editor/select", enabled: false)

  // Verify constraints are applied
  let canSelect = try engine.block.isScopeEnabled(brandImage, key: "editor/select")
  let canMove = try engine.block.isScopeEnabled(brandImage, key: "layer/move")
  print("Brand image - canSelect:", canSelect, "canMove:", canMove)
  // highlight-dynamicContent-editingConstraints

  try await engine.captureGuide(page, label: "hero")
}
