import Foundation
import IMGLYEngine

@MainActor
func addBackground(engine: Engine) async throws {
  // highlight-addBackground-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-addBackground-setup

  // highlight-addBackground-pageFill
  if try engine.block.supportsFill(page) {
    let gradientFill = try engine.block.createFill(.linearGradient)
    try engine.block.setGradientColorStops(gradientFill, property: "fill/gradient/colors", colors: [
      GradientColorStop(color: .rgba(r: 0.85, g: 0.75, b: 0.95, a: 1.0), stop: 0),
      GradientColorStop(color: .rgba(r: 0.7, g: 0.9, b: 0.95, a: 1.0), stop: 1),
    ])
    try engine.block.setFill(page, fill: gradientFill)
  }
  // highlight-addBackground-pageFill

  // Create a text block to demonstrate background color
  let textBlock = try engine.block.create(.text)
  try engine.block.setString(textBlock, property: "text/text", value: "Backgrounds")
  try engine.block.setFloat(textBlock, property: "text/fontSize", value: 48)
  try engine.block.setWidth(textBlock, value: 280)
  try engine.block.setHeightMode(textBlock, mode: .auto)
  try engine.block.setPositionX(textBlock, value: 66)
  try engine.block.setPositionY(textBlock, value: 280)
  try engine.block.appendChild(to: page, child: textBlock)

  // highlight-addBackground-backgroundColor
  if try engine.block.supportsBackgroundColor(textBlock) {
    try engine.block.setBackgroundColorEnabled(textBlock, enabled: true)
    try engine.block.setColor(
      textBlock,
      property: "backgroundColor/color",
      color: .rgba(r: 1.0, g: 1.0, b: 1.0, a: 1.0),
    )
    try engine.block.setFloat(textBlock, property: "backgroundColor/paddingLeft", value: 16)
    try engine.block.setFloat(textBlock, property: "backgroundColor/paddingRight", value: 16)
    try engine.block.setFloat(textBlock, property: "backgroundColor/paddingTop", value: 10)
    try engine.block.setFloat(textBlock, property: "backgroundColor/paddingBottom", value: 10)
    try engine.block.setFloat(textBlock, property: "backgroundColor/cornerRadius", value: 8)
  }
  // highlight-addBackground-backgroundColor

  // Create a graphic block to demonstrate image fill on a shape
  let imageBlock = try engine.block.create(.graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(imageBlock, shape: rectShape)
  try engine.block.setWidth(imageBlock, value: 340)
  try engine.block.setHeight(imageBlock, value: 400)
  try engine.block.setPositionX(imageBlock, value: 420)
  try engine.block.setPositionY(imageBlock, value: 100)
  try engine.block.appendChild(to: page, child: imageBlock)

  // highlight-addBackground-shapeFill
  if try engine.block.supportsFill(imageBlock) {
    let imageFill = try engine.block.createFill(.image)
    try engine.block.setString(
      imageFill,
      property: "fill/image/imageFileURI",
      value: "https://img.ly/static/ubq_samples/sample_1.jpg",
    )
    try engine.block.setFill(imageBlock, fill: imageFill)
  }
  // highlight-addBackground-shapeFill

  // highlight-addBackground-checkSupport
  let pageSupportsFill = try engine.block.supportsFill(page) // true
  let textSupportsBackground = try engine.block.supportsBackgroundColor(textBlock) // true
  let imageSupportsFill = try engine.block.supportsFill(imageBlock) // true
  // highlight-addBackground-checkSupport
}
