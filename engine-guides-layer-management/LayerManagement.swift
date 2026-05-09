import Foundation
import IMGLYEngine

@MainActor
func layerManagement(engine: Engine) async throws {
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-layerManagement-createBlock
  // Create a red rectangle
  let redRect = try engine.block.create(.graphic)
  try engine.block.setShape(redRect, shape: engine.block.createShape(.rect))
  let redFill = try engine.block.createFill(.color)
  try engine.block.setFill(redRect, fill: redFill)
  try engine.block.setColor(redFill, property: "fill/color/value", color: .rgba(r: 0.9, g: 0.2, b: 0.2, a: 1.0))
  try engine.block.setWidth(redRect, value: 180)
  try engine.block.setHeight(redRect, value: 180)
  try engine.block.setPositionX(redRect, value: 220)
  try engine.block.setPositionY(redRect, value: 120)
  // highlight-layerManagement-createBlock

  // Create a green rectangle
  let greenRect = try engine.block.create(.graphic)
  try engine.block.setShape(greenRect, shape: engine.block.createShape(.rect))
  let greenFill = try engine.block.createFill(.color)
  try engine.block.setFill(greenRect, fill: greenFill)
  try engine.block.setColor(greenFill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.8, b: 0.2, a: 1.0))
  try engine.block.setWidth(greenRect, value: 180)
  try engine.block.setHeight(greenRect, value: 180)
  try engine.block.setPositionX(greenRect, value: 280)
  try engine.block.setPositionY(greenRect, value: 180)

  // Create a blue rectangle
  let blueRect = try engine.block.create(.graphic)
  try engine.block.setShape(blueRect, shape: engine.block.createShape(.rect))
  let blueFill = try engine.block.createFill(.color)
  try engine.block.setFill(blueRect, fill: blueFill)
  try engine.block.setColor(blueFill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1.0))
  try engine.block.setWidth(blueRect, value: 180)
  try engine.block.setHeight(blueRect, value: 180)
  try engine.block.setPositionX(blueRect, value: 340)
  try engine.block.setPositionY(blueRect, value: 240)

  // highlight-layerManagement-appendChild
  // Add blocks to the page — last appended is on top
  try engine.block.appendChild(to: page, child: redRect)
  try engine.block.appendChild(to: page, child: greenRect)
  try engine.block.appendChild(to: page, child: blueRect)
  // highlight-layerManagement-appendChild

  // highlight-layerManagement-getParent
  // Get the parent of a block
  let parent = try engine.block.getParent(redRect)
  print("Parent of red rectangle:", parent as Any)
  // highlight-layerManagement-getParent

  // highlight-layerManagement-getChildren
  // Get all children of the page
  let children = try engine.block.getChildren(page)
  print("Page children (in render order):", children)
  // highlight-layerManagement-getChildren

  // highlight-layerManagement-insertChild
  // Insert a new block at a specific position (index 0 = back)
  let yellowRect = try engine.block.create(.graphic)
  try engine.block.setShape(yellowRect, shape: engine.block.createShape(.rect))
  let yellowFill = try engine.block.createFill(.color)
  try engine.block.setFill(yellowRect, fill: yellowFill)
  try engine.block.setColor(yellowFill, property: "fill/color/value", color: .rgba(r: 0.95, g: 0.85, b: 0.2, a: 1.0))
  try engine.block.setWidth(yellowRect, value: 180)
  try engine.block.setHeight(yellowRect, value: 180)
  try engine.block.setPositionX(yellowRect, value: 160)
  try engine.block.setPositionY(yellowRect, value: 60)
  try engine.block.insertChild(into: page, child: yellowRect, at: 0)
  // highlight-layerManagement-insertChild

  // highlight-layerManagement-bringToFront
  // Bring the red rectangle to the front
  try engine.block.bringToFront(redRect)
  print("Red rectangle brought to front")
  // highlight-layerManagement-bringToFront

  // highlight-layerManagement-sendToBack
  // Send the blue rectangle to the back
  try engine.block.sendToBack(blueRect)
  print("Blue rectangle sent to back")
  // highlight-layerManagement-sendToBack

  // highlight-layerManagement-bringForward
  // Move the green rectangle forward one layer
  try engine.block.bringForward(greenRect)
  print("Green rectangle moved forward")
  // highlight-layerManagement-bringForward

  // highlight-layerManagement-sendBackward
  // Move the yellow rectangle backward one layer
  try engine.block.sendBackward(yellowRect)
  print("Yellow rectangle moved backward")
  // highlight-layerManagement-sendBackward

  // highlight-layerManagement-visibility
  // Check and toggle visibility
  let isVisible = try engine.block.isVisible(blueRect)
  print("Blue rectangle visible:", isVisible)

  // Hide the blue rectangle temporarily
  try engine.block.setVisible(blueRect, visible: false)
  print("Blue rectangle hidden")

  // Show it again for the final composition
  try engine.block.setVisible(blueRect, visible: true)
  print("Blue rectangle shown again")
  // highlight-layerManagement-visibility

  // highlight-layerManagement-duplicate
  // Duplicate a block
  let duplicateGreen = try engine.block.duplicate(greenRect)
  try engine.block.setPositionX(duplicateGreen, value: 400)
  try engine.block.setPositionY(duplicateGreen, value: 300)
  // Change the duplicate's color to purple
  let purpleFill = try engine.block.createFill(.color)
  try engine.block.setFill(duplicateGreen, fill: purpleFill)
  try engine.block.setColor(purpleFill, property: "fill/color/value", color: .rgba(r: 0.6, g: 0.2, b: 0.8, a: 1.0))
  print("Green rectangle duplicated")
  // highlight-layerManagement-duplicate

  // highlight-layerManagement-isValid
  // Check if a block is valid before operations
  let isValidBefore = engine.block.isValid(yellowRect)
  print("Yellow rectangle valid before destroy:", isValidBefore)
  // highlight-layerManagement-isValid

  // highlight-layerManagement-destroy
  // Remove a block from the scene
  try engine.block.destroy(yellowRect)
  print("Yellow rectangle destroyed")

  // Check validity after destruction
  let isValidAfter = engine.block.isValid(yellowRect)
  print("Yellow rectangle valid after destroy:", isValidAfter)
  // highlight-layerManagement-destroy

  // highlight-layerManagement-zoom
  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)
  // highlight-layerManagement-zoom
}
