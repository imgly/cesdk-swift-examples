import Foundation
import IMGLYEngine

@MainActor
func multiPage(engine: Engine) async throws {
  // highlight-multiPage-createScene
  // Create a scene with HorizontalStack layout
  try engine.scene.create(sceneLayout: .horizontalStack)

  // Get the stack container
  let stacks = try engine.block.find(byType: .stack)
  let stack = stacks[0]

  // Create the first page
  let firstPage = try engine.block.create(.page)
  try engine.block.setWidth(firstPage, value: 800)
  try engine.block.setHeight(firstPage, value: 600)
  try engine.block.appendChild(to: stack, child: firstPage)
  // highlight-multiPage-createScene

  // highlight-multiPage-stackSpacing
  // Add spacing between pages (20 pixels in screen space)
  try engine.block.setFloat(stack, property: "stack/spacing", value: 20)
  try engine.block.setBool(stack, property: "stack/spacingInScreenspace", value: true)
  // highlight-multiPage-stackSpacing

  // Add content to the first page
  let imageBlock1 = try engine.block.create(.graphic)
  let rectShape1 = try engine.block.createShape(.rect)
  try engine.block.setShape(imageBlock1, shape: rectShape1)
  try engine.block.setWidth(imageBlock1, value: 300)
  try engine.block.setHeight(imageBlock1, value: 200)
  try engine.block.setPositionX(imageBlock1, value: 250)
  try engine.block.setPositionY(imageBlock1, value: 200)
  let imageFill1 = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill1,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg",
  )
  try engine.block.setFill(imageBlock1, fill: imageFill1)
  try engine.block.appendChild(to: firstPage, child: imageBlock1)

  // highlight-multiPage-addPage
  // Create a second page with different content
  let secondPage = try engine.block.create(.page)
  try engine.block.setWidth(secondPage, value: 800)
  try engine.block.setHeight(secondPage, value: 600)
  try engine.block.appendChild(to: stack, child: secondPage)

  // Add a different image to the second page
  let imageBlock2 = try engine.block.create(.graphic)
  let rectShape2 = try engine.block.createShape(.rect)
  try engine.block.setShape(imageBlock2, shape: rectShape2)
  try engine.block.setWidth(imageBlock2, value: 300)
  try engine.block.setHeight(imageBlock2, value: 200)
  try engine.block.setPositionX(imageBlock2, value: 250)
  try engine.block.setPositionY(imageBlock2, value: 200)
  let imageFill2 = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill2,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_2.jpg",
  )
  try engine.block.setFill(imageBlock2, fill: imageFill2)
  try engine.block.appendChild(to: secondPage, child: imageBlock2)
  // highlight-multiPage-addPage

  // highlight-multiPage-zoom
  try engine.block.select(firstPage)
  try engine.scene.enableZoomAutoFit(firstPage, axis: .both)
  // highlight-multiPage-zoom
}
