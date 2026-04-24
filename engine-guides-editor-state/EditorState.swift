import Foundation
import IMGLYEngine

@MainActor
func editorState(engine: Engine) async throws {
  // highlight-editorState-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // Add an image block to demonstrate Crop mode
  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(imageBlock, value: 350)
  try engine.block.setHeight(imageBlock, value: 250)
  try engine.block.setPositionX(imageBlock, value: 50)
  try engine.block.setPositionY(imageBlock, value: 175)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg",
  )
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.appendChild(to: page, child: imageBlock)

  // Add a text block to demonstrate Text mode
  let textBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: textBlock)
  try engine.block.replaceText(textBlock, text: "Edit this text")
  try engine.block.setTextFontSize(textBlock, fontSize: 48)
  try engine.block.setWidthMode(textBlock, mode: .auto)
  try engine.block.setHeightMode(textBlock, mode: .auto)
  try engine.block.setPositionX(textBlock, value: 450)
  try engine.block.setPositionY(textBlock, value: 275)
  // highlight-editorState-setup

  // highlight-editorState-onStateChanged
  // Subscribe to state changes using AsyncStream
  let stateTask = Task {
    for await _ in engine.editor.onStateChanged {
      let currentMode = engine.editor.getEditMode()
      print("Edit mode changed to: \(currentMode)")
    }
  }
  // highlight-editorState-onStateChanged

  // highlight-editorState-getEditMode
  // Get the current edit mode (default is Transform)
  let initialMode = engine.editor.getEditMode()
  print("Initial edit mode: \(initialMode)")
  // highlight-editorState-getEditMode

  // highlight-editorState-setEditMode
  // Select the image block and switch to Crop mode
  try engine.block.select(imageBlock)
  engine.editor.setEditMode(.crop)
  print("Switched to Crop mode")

  // Switch back to Transform mode
  engine.editor.setEditMode(.transform)
  print("Switched back to Transform mode")
  // highlight-editorState-setEditMode

  // highlight-editorState-cursorType
  // Get the cursor type to display the appropriate cursor
  let cursorType = engine.editor.getCursorType()
  print("Cursor type: \(cursorType)")
  // Returns: .arrow, .move, .moveNotPermitted, .resize, .rotate, or .text
  // highlight-editorState-cursorType

  // highlight-editorState-cursorRotation
  // Get cursor rotation for directional cursors like resize handles
  let cursorRotation = engine.editor.getCursorRotation()
  print("Cursor rotation (radians): \(cursorRotation)")
  // highlight-editorState-cursorRotation

  // highlight-editorState-textCursorPosition
  // Select the text block and switch to Text mode to get cursor position
  try engine.block.select(textBlock)
  engine.editor.setEditMode(.text)

  // Get text cursor position in screen space
  let textCursorX = engine.editor.getTextCursorPositionInScreenSpaceX()
  let textCursorY = engine.editor.getTextCursorPositionInScreenSpaceY()
  print("Text cursor position: (\(textCursorX), \(textCursorY))")
  // highlight-editorState-textCursorPosition

  // highlight-editorState-interactionHappening
  // Check if a user interaction is currently in progress
  let isInteracting = try engine.editor.unstable_isInteractionHappening()
  print("Is interaction happening: \(isInteracting)")
  // highlight-editorState-interactionHappening

  // Clean up the state subscription
  stateTask.cancel()

  // Switch back to Transform mode
  engine.editor.setEditMode(.transform)
}
