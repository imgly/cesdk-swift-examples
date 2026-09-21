import Foundation
import IMGLYEngine

@MainActor
func lockContent(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let sampleImage1 = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  let sampleImage2 = baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg")

  // Build a sample scene with four blocks, each demonstrating a different
  // locking outcome. This setup runs before any scope is locked, so every
  // creation call succeeds.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1200)
  try engine.block.setHeight(page, value: 800)
  try engine.block.appendChild(to: scene, child: page)

  // Top-left: an image that stays fully locked.
  let lockedImage = try engine.block.create(.graphic)
  try engine.block.setShape(lockedImage, shape: engine.block.createShape(.rect))
  let lockedFill = try engine.block.createFill(.image)
  try engine.block.setURL(lockedFill, property: "fill/image/imageFileURI", value: sampleImage1)
  try engine.block.setFill(lockedImage, fill: lockedFill)
  try engine.block.setPositionX(lockedImage, value: 185)
  try engine.block.setPositionY(lockedImage, value: 70)
  try engine.block.setWidth(lockedImage, value: 300)
  try engine.block.setHeight(lockedImage, value: 200)
  try engine.block.setName(lockedImage, name: "Locked Image")
  try engine.block.appendChild(to: page, child: lockedImage)

  // Top-right: a text block that allows text editing only.
  let editableText = try engine.block.create(.text)
  try engine.block.setString(editableText, property: "text/text", value: "Edit me!")
  try engine.block.setFloat(editableText, property: "text/fontSize", value: 90)
  try engine.block.setPositionX(editableText, value: 565)
  try engine.block.setPositionY(editableText, value: 70)
  try engine.block.setWidth(editableText, value: 450)
  try engine.block.setHeight(editableText, value: 200)
  try engine.block.setName(editableText, name: "Editable Text")
  try engine.block.appendChild(to: page, child: editableText)

  // Bottom-left: an image that allows replacement only.
  let replaceableImage = try engine.block.create(.graphic)
  try engine.block.setShape(replaceableImage, shape: engine.block.createShape(.rect))
  let replaceableFill = try engine.block.createFill(.image)
  try engine.block.setURL(replaceableFill, property: "fill/image/imageFileURI", value: sampleImage2)
  try engine.block.setFill(replaceableImage, fill: replaceableFill)
  try engine.block.setPositionX(replaceableImage, value: 185)
  try engine.block.setPositionY(replaceableImage, value: 380)
  try engine.block.setWidth(replaceableImage, value: 300)
  try engine.block.setHeight(replaceableImage, value: 200)
  try engine.block.setName(replaceableImage, name: "Replaceable Image")
  try engine.block.appendChild(to: page, child: replaceableImage)

  // Bottom-right: a shape that allows moving and resizing only.
  let movableShape = try engine.block.create(.graphic)
  try engine.block.setShape(movableShape, shape: engine.block.createShape(.rect))
  let shapeFill = try engine.block.createFill(.color)
  try engine.block.setColor(shapeFill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.6, b: 0.9, a: 1.0))
  try engine.block.setFill(movableShape, fill: shapeFill)
  try engine.block.setPositionX(movableShape, value: 565)
  try engine.block.setPositionY(movableShape, value: 380)
  try engine.block.setWidth(movableShape, value: 200)
  try engine.block.setHeight(movableShape, value: 200)
  try engine.block.setName(movableShape, name: "Movable Shape")
  try engine.block.appendChild(to: page, child: movableShape)

  // highlight-lockContent-findAllScopes
  let allScopes = engine.editor.findAllScopes()
  print("Available scopes:", allScopes)
  // highlight-lockContent-findAllScopes

  // highlight-lockContent-lockAll
  for scope in allScopes {
    try engine.editor.setGlobalScope(key: scope, value: .deny)
  }
  // highlight-lockContent-lockAll

  // editor/select was locked along with everything else. Re-open it so the
  // interactive blocks below can be selected; a block cannot be touched at all
  // while its selection is denied, no matter which other scopes are enabled.
  try engine.editor.setGlobalScope(key: "editor/select", value: .defer)
  try engine.block.setScopeEnabled(editableText, key: "editor/select", enabled: true)
  try engine.block.setScopeEnabled(replaceableImage, key: "editor/select", enabled: true)
  try engine.block.setScopeEnabled(movableShape, key: "editor/select", enabled: true)

  // highlight-lockContent-textEdit
  // text/edit gates the content, text/character gates styling (font, size, color).
  try engine.editor.setGlobalScope(key: "text/edit", value: .defer)
  try engine.editor.setGlobalScope(key: "text/character", value: .defer)
  try engine.block.setScopeEnabled(editableText, key: "text/edit", enabled: true)
  try engine.block.setScopeEnabled(editableText, key: "text/character", enabled: true)
  // highlight-lockContent-textEdit

  // highlight-lockContent-imageReplace
  try engine.editor.setGlobalScope(key: "fill/change", value: .defer)
  try engine.block.setScopeEnabled(replaceableImage, key: "fill/change", enabled: true)
  // highlight-lockContent-imageReplace

  // highlight-lockContent-positionAdjust
  try engine.editor.setGlobalScope(key: "layer/move", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/resize", value: .defer)
  try engine.block.setScopeEnabled(movableShape, key: "layer/move", enabled: true)
  try engine.block.setScopeEnabled(movableShape, key: "layer/resize", enabled: true)
  // highlight-lockContent-positionAdjust

  // highlight-lockContent-checkPermissions
  let canEditText = try engine.block.isAllowedByScope(editableText, key: "text/edit")
  let canMoveLockedImage = try engine.block.isAllowedByScope(lockedImage, key: "layer/move")
  let canReplaceImage = try engine.block.isAllowedByScope(replaceableImage, key: "fill/change")
  let canMoveShape = try engine.block.isAllowedByScope(movableShape, key: "layer/move")

  print("Can edit text:", canEditText) // true
  print("Can move locked image:", canMoveLockedImage) // false
  print("Can replace image:", canReplaceImage) // true
  print("Can move shape:", canMoveShape) // true

  let textEditGlobal = try engine.editor.getGlobalScope(key: "text/edit")
  let textEditEnabled = try engine.block.isScopeEnabled(editableText, key: "text/edit")
  print("Global text/edit is .defer:", textEditGlobal == .defer) // true
  print("Block-level text/edit enabled:", textEditEnabled) // true
  // highlight-lockContent-checkPermissions
}
