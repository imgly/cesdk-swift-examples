import Foundation
import IMGLYEngine

@MainActor
func pages(engine: Engine) async throws {
  // highlight-pages-createScene
  // Create a scene with VerticalStack layout for multi-page designs
  let scene = try engine.scene.create(sceneLayout: .verticalStack)

  // Configure spacing between pages
  let stacks = try engine.block.find(byType: .stack)
  let stack = stacks[0]
  try engine.block.setFloat(stack, property: "stack/spacing", value: 20)
  try engine.block.setBool(stack, property: "stack/spacingInScreenspace", value: true)
  // highlight-pages-createScene

  // highlight-pages-setDimensions
  // Set page dimensions at the scene level (all pages share these dimensions)
  try engine.block.setFloat(scene, property: "scene/pageDimensions/width", value: 800)
  try engine.block.setFloat(scene, property: "scene/pageDimensions/height", value: 600)
  // highlight-pages-setDimensions

  // highlight-pages-createPages
  // Create the first page and set its dimensions
  let firstPage = try engine.block.create(.page)
  try engine.block.setWidth(firstPage, value: 800)
  try engine.block.setHeight(firstPage, value: 600)
  try engine.block.appendChild(to: stack, child: firstPage)

  // Create the second page with the same dimensions
  let secondPage = try engine.block.create(.page)
  try engine.block.setWidth(secondPage, value: 800)
  try engine.block.setHeight(secondPage, value: 600)
  try engine.block.appendChild(to: stack, child: secondPage)
  // highlight-pages-createPages

  // highlight-pages-addContent
  // Add an image block to the first page
  let imageBlock = try engine.block.create(.graphic)
  try engine.block.appendChild(to: firstPage, child: imageBlock)

  // Create a rect shape for the graphic block
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(imageBlock, shape: rectShape)

  // Configure size and position after appending to the page
  try engine.block.setWidth(imageBlock, value: 400)
  try engine.block.setHeight(imageBlock, value: 300)
  try engine.block.setPositionX(imageBlock, value: 200)
  try engine.block.setPositionY(imageBlock, value: 150)

  // Create and configure the image fill
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg",
  )
  try engine.block.setFill(imageBlock, fill: imageFill)

  // Add a text block to the second page
  let textBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: secondPage, child: textBlock)

  // Configure text properties
  try engine.block.replaceText(textBlock, text: "Page 2")
  try engine.block.setTextFontSize(textBlock, fontSize: 48)
  try engine.block.setTextColor(textBlock, color: .rgba(r: 0.2, g: 0.2, b: 0.2, a: 1.0))
  try engine.block.setEnum(textBlock, property: "text/horizontalAlignment", value: "Center")
  try engine.block.setWidthMode(textBlock, mode: .auto)
  try engine.block.setHeightMode(textBlock, mode: .auto)
  // highlight-pages-addContent

  // highlight-pages-pageMargins
  // Enable and set margins for print bleed on the first page
  try engine.block.setBool(firstPage, property: "page/marginEnabled", value: true)
  try engine.block.setFloat(firstPage, property: "page/margin/top", value: 10)
  try engine.block.setFloat(firstPage, property: "page/margin/bottom", value: 10)
  try engine.block.setFloat(firstPage, property: "page/margin/left", value: 10)
  try engine.block.setFloat(firstPage, property: "page/margin/right", value: 10)
  // highlight-pages-pageMargins

  // highlight-pages-titleTemplate
  // Set custom title templates for each page
  try engine.block.setString(firstPage, property: "page/titleTemplate", value: "Cover")
  try engine.block.setString(secondPage, property: "page/titleTemplate", value: "Content")
  // highlight-pages-titleTemplate

  // highlight-pages-pageBackground
  // Set a background fill on the second page
  let colorFill = try engine.block.createFill(.color)
  try engine.block.setColor(colorFill, property: "fill/color/value", color: .rgba(r: 0.95, g: 0.95, b: 1.0, a: 1.0))
  try engine.block.setFill(secondPage, fill: colorFill)
  // highlight-pages-pageBackground

  // highlight-pages-findPages
  // Get all pages in sorted order
  let allPages = try engine.scene.getPages()
  print("All pages:", allPages)
  print("Number of pages:", allPages.count)

  // Get the current page (nearest to viewport center or containing selection)
  let currentPage = try engine.scene.getCurrentPage()
  print("Current page:", currentPage as Any)

  // Find pages using the block API
  let pagesByType = try engine.block.find(byType: .page)
  print("Pages found by type:", pagesByType)
  // highlight-pages-findPages
}
