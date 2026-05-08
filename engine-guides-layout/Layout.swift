import Foundation
import IMGLYEngine

@MainActor
func layout(engine: Engine) async throws {
  // highlight-layout-verticalStack
  // Create a scene with VerticalStack layout. Pages appended to the stack
  // container are arranged top-to-bottom automatically.
  try engine.scene.create(sceneLayout: .verticalStack)

  // Get the stack container that was created with the scene.
  let stacks = try engine.block.find(byType: .stack)
  let stack = stacks[0]

  // Create two pages that will stack vertically.
  let page1 = try engine.block.create(.page)
  try engine.block.setWidth(page1, value: 400)
  try engine.block.setHeight(page1, value: 300)
  try engine.block.appendChild(to: stack, child: page1)

  let page2 = try engine.block.create(.page)
  try engine.block.setWidth(page2, value: 400)
  try engine.block.setHeight(page2, value: 300)
  try engine.block.appendChild(to: stack, child: page2)

  // Configure spacing between stacked pages.
  try engine.block.setFloat(stack, property: "stack/spacing", value: 20)
  try engine.block.setBool(stack, property: "stack/spacingInScreenspace", value: true)
  // highlight-layout-verticalStack

  // highlight-layout-addBlocks
  // Add an image block to the first page.
  let block1 = try engine.block.create(.graphic)
  let shape1 = try engine.block.createShape(.rect)
  try engine.block.setShape(block1, shape: shape1)
  try engine.block.setWidth(block1, value: 350)
  try engine.block.setHeight(block1, value: 250)
  try engine.block.setPositionX(block1, value: 25)
  try engine.block.setPositionY(block1, value: 25)
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg",
  )
  try engine.block.setFill(block1, fill: imageFill)
  try engine.block.appendChild(to: page1, child: block1)

  // Add a colored rectangle to the second page.
  let block2 = try engine.block.create(.graphic)
  let shape2 = try engine.block.createShape(.rect)
  try engine.block.setShape(block2, shape: shape2)
  try engine.block.setWidth(block2, value: 350)
  try engine.block.setHeight(block2, value: 250)
  try engine.block.setPositionX(block2, value: 25)
  try engine.block.setPositionY(block2, value: 25)
  let colorFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    colorFill,
    property: "fill/color/value",
    color: .rgba(r: 0.3, g: 0.6, b: 0.9, a: 1.0),
  )
  try engine.block.setFill(block2, fill: colorFill)
  try engine.block.appendChild(to: page2, child: block2)
  // highlight-layout-addBlocks

  // highlight-layout-horizontalStack
  // Switch to a horizontal stack. Existing pages reposition left-to-right.
  try engine.scene.setLayout(.horizontalStack)

  // Verify the layout type.
  let currentLayout = try engine.scene.getLayout()
  print("Current layout:", currentLayout)
  // highlight-layout-horizontalStack

  // highlight-layout-addPage
  // Append a new page to the existing stack. It snaps to the end with the
  // configured spacing.
  let page3 = try engine.block.create(.page)
  try engine.block.setWidth(page3, value: 400)
  try engine.block.setHeight(page3, value: 300)
  try engine.block.appendChild(to: stack, child: page3)

  // Add content to the new page.
  let block3 = try engine.block.create(.graphic)
  let shape3 = try engine.block.createShape(.rect)
  try engine.block.setShape(block3, shape: shape3)
  try engine.block.setWidth(block3, value: 350)
  try engine.block.setHeight(block3, value: 250)
  try engine.block.setPositionX(block3, value: 25)
  try engine.block.setPositionY(block3, value: 25)
  let fill3 = try engine.block.createFill(.color)
  try engine.block.setColor(
    fill3,
    property: "fill/color/value",
    color: .rgba(r: 0.9, g: 0.5, b: 0.3, a: 1.0),
  )
  try engine.block.setFill(block3, fill: fill3)
  try engine.block.appendChild(to: page3, child: block3)
  // highlight-layout-addPage

  // highlight-layout-reorder
  // Move page3 to the first position using insertChild.
  try engine.block.insertChild(into: stack, child: page3, at: 0)

  // Verify the new order.
  let pageOrder = try engine.block.getChildren(stack)
  print("Page order after reordering:", pageOrder)
  // highlight-layout-reorder

  // highlight-layout-spacing
  // Update the spacing between stacked pages.
  try engine.block.setFloat(stack, property: "stack/spacing", value: 40)

  // Verify the spacing value.
  let updatedSpacing = try engine.block.getFloat(stack, property: "stack/spacing")
  print("Updated spacing:", updatedSpacing)
  // highlight-layout-spacing

  // highlight-layout-freeLayout
  // Switch back to a free layout to position pages manually.
  try engine.scene.setLayout(.free)

  // Position a page directly — stacks no longer manage placement.
  let pages = try engine.block.find(byType: .page)
  let page = pages[0]
  try engine.block.setPositionX(page, value: 100)
  try engine.block.setPositionY(page, value: 200)
  // highlight-layout-freeLayout
}
