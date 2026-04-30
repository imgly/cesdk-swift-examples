import Foundation
import IMGLYEngine

@MainActor
func designUnits(engine: Engine) async throws {
  // highlight-designUnits-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-designUnits-setup

  // highlight-designUnits-getDesignUnit
  // Get the current design unit — defaults to .px for new scenes
  let currentUnit = try engine.scene.getDesignUnit()
  print("Current design unit:", currentUnit) // .px
  // highlight-designUnits-getDesignUnit

  // highlight-designUnits-setDesignUnit
  // Switch to millimeters for a print workflow
  try engine.scene.setDesignUnit(.mm)

  // Verify the change
  let newUnit = try engine.scene.getDesignUnit()
  print("Design unit changed to:", newUnit) // .mm
  // highlight-designUnits-setDesignUnit

  // highlight-designUnits-configureDpi
  // Set DPI to 300 for print-quality exports
  try engine.block.setFloat(scene, property: "scene/dpi", value: 300)

  // Read back the DPI value
  let dpi = try engine.block.getFloat(scene, property: "scene/dpi")
  print("DPI set to:", dpi) // 300.0
  // highlight-designUnits-configureDpi

  // highlight-designUnits-setPageDimensions
  // Set page to A4 dimensions (210 x 297 mm)
  try engine.block.setWidth(page, value: 210)
  try engine.block.setHeight(page, value: 297)

  let pageWidth = try engine.block.getWidth(page)
  let pageHeight = try engine.block.getHeight(page)
  print("Page dimensions: \(pageWidth)mm x \(pageHeight)mm")
  // highlight-designUnits-setPageDimensions

  // highlight-designUnits-createTextBlock
  // Create a text block positioned and sized in millimeters
  let textBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: textBlock)

  // Position at 20 mm from left, 30 mm from top
  try engine.block.setPositionX(textBlock, value: 20)
  try engine.block.setPositionY(textBlock, value: 30)

  // Size: 170 mm wide, 50 mm tall
  try engine.block.setWidth(textBlock, value: 170)
  try engine.block.setHeight(textBlock, value: 50)

  try engine.block.setString(
    textBlock,
    property: "text/text",
    value: "This A4 document uses millimeter units with 300 DPI for print-ready output.",
  )
  // highlight-designUnits-createTextBlock

  // highlight-designUnits-compareUnits
  // At 300 DPI: 1 inch = 300 pixels, 1 mm ≈ 11.81 pixels
  let a4WidthPixels = 210.0 * (300.0 / 25.4)
  let a4HeightPixels = 297.0 * (300.0 / 25.4)
  print("A4 at 300 DPI exports as \(Int(a4WidthPixels)) x \(Int(a4HeightPixels)) pixels")
  // highlight-designUnits-compareUnits
}
