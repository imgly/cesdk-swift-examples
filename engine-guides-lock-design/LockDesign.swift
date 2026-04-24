import Foundation
import IMGLYEngine

@MainActor
func lockDesign(engine: Engine) async throws {
  // highlight-lockDesign-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let imageURI = "https://img.ly/static/ubq_samples/sample_1.jpg"

  // Column 1: Fully Locked
  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(imageFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.setPositionX(imageBlock, value: 30)
  try engine.block.setPositionY(imageBlock, value: 100)
  try engine.block.setWidth(imageBlock, value: 220)
  try engine.block.setHeight(imageBlock, value: 165)
  try engine.block.appendChild(to: page, child: imageBlock)

  // Column 2: Text Editing Only
  let textBlock = try engine.block.create(.text)
  try engine.block.setString(textBlock, property: "text/text", value: "Edit Me")
  try engine.block.setFloat(textBlock, property: "text/fontSize", value: 72)
  try engine.block.setPositionX(textBlock, value: 290)
  try engine.block.setPositionY(textBlock, value: 100)
  try engine.block.setWidth(textBlock, value: 220)
  try engine.block.setHeight(textBlock, value: 165)
  try engine.block.appendChild(to: page, child: textBlock)

  // Column 3: Image Replace Only
  let placeholderBlock = try engine.block.create(.graphic)
  try engine.block.setShape(placeholderBlock, shape: engine.block.createShape(.rect))
  let placeholderFill = try engine.block.createFill(.image)
  try engine.block.setString(placeholderFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(placeholderBlock, fill: placeholderFill)
  try engine.block.setPositionX(placeholderBlock, value: 550)
  try engine.block.setPositionY(placeholderBlock, value: 100)
  try engine.block.setWidth(placeholderBlock, value: 220)
  try engine.block.setHeight(placeholderBlock, value: 165)
  try engine.block.appendChild(to: page, child: placeholderBlock)
  // highlight-lockDesign-setup

  // highlight-lockDesign-lockEntireDesign
  // Lock the entire design by setting all scopes to .deny
  let scopes = try engine.editor.findAllScopes()
  for scope in scopes {
    try engine.editor.setGlobalScope(key: scope, value: .deny)
  }
  // highlight-lockDesign-lockEntireDesign

  // highlight-lockDesign-enableSelection
  // Enable selection for specific blocks
  try engine.editor.setGlobalScope(key: "editor/select", value: .defer)
  try engine.block.setScopeEnabled(textBlock, key: "editor/select", enabled: true)
  try engine.block.setScopeEnabled(placeholderBlock, key: "editor/select", enabled: true)
  // highlight-lockDesign-enableSelection

  // highlight-lockDesign-textEditing
  // Enable text editing on the text block
  try engine.editor.setGlobalScope(key: "text/edit", value: .defer)
  try engine.editor.setGlobalScope(key: "text/character", value: .defer)
  try engine.block.setScopeEnabled(textBlock, key: "text/edit", enabled: true)
  try engine.block.setScopeEnabled(textBlock, key: "text/character", enabled: true)
  // highlight-lockDesign-textEditing

  // highlight-lockDesign-imageReplacement
  // Enable image replacement on the placeholder block
  try engine.editor.setGlobalScope(key: "fill/change", value: .defer)
  try engine.block.setScopeEnabled(placeholderBlock, key: "fill/change", enabled: true)
  // highlight-lockDesign-imageReplacement

  // highlight-lockDesign-checkPermissions
  // Check if operations are permitted on blocks
  let canEditText = try engine.block.isAllowedByScope(textBlock, key: "text/edit")
  let canMoveImage = try engine.block.isAllowedByScope(imageBlock, key: "layer/move")
  let canReplacePlaceholder = try engine.block.isAllowedByScope(placeholderBlock, key: "fill/change")

  print("Permission status:")
  print("- Can edit text:", canEditText) // true
  print("- Can move locked image:", canMoveImage) // false
  print("- Can replace placeholder:", canReplacePlaceholder) // true
  // highlight-lockDesign-checkPermissions

  // highlight-lockDesign-getScopes
  // Discover all available scopes
  let allScopes = try engine.editor.findAllScopes()
  print("Available scopes:", allScopes)

  // Check global scope settings
  let textEditGlobal = try engine.editor.getGlobalScope(key: "text/edit")
  let layerMoveGlobal = try engine.editor.getGlobalScope(key: "layer/move")
  print("Global text/edit:", textEditGlobal) // .defer
  print("Global layer/move:", layerMoveGlobal) // .deny

  // Check block-level scope settings
  let textEditEnabled = try engine.block.isScopeEnabled(textBlock, key: "text/edit")
  print("Text block text/edit enabled:", textEditEnabled) // true
  // highlight-lockDesign-getScopes

  // Select the text block to demonstrate editability
  try engine.block.select(textBlock)
}
