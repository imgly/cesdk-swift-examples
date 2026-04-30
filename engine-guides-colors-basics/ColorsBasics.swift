import Foundation
import IMGLYEngine

@MainActor
func colorsBasics(engine: Engine) async throws {
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-colorsBasics-srgb
  // Create a graphic block with a color fill
  let srgbBlock = try engine.block.create(.graphic)
  try engine.block.setShape(srgbBlock, shape: engine.block.createShape(.rect))
  let srgbFill = try engine.block.createFill(.color)
  try engine.block.setFill(srgbBlock, fill: srgbFill)
  try engine.block.appendChild(to: page, child: srgbBlock)

  // Set fill color using an sRGB color (values 0.0-1.0)
  let srgbColor = Color.rgba(r: 0.2, g: 0.4, b: 0.9, a: 1.0)
  try engine.block.setColor(srgbFill, property: "fill/color/value", color: srgbColor)
  // highlight-colorsBasics-srgb

  // highlight-colorsBasics-cmyk
  // Create another block with a CMYK color
  let cmykBlock = try engine.block.create(.graphic)
  try engine.block.setShape(cmykBlock, shape: engine.block.createShape(.rect))
  let cmykFill = try engine.block.createFill(.color)
  try engine.block.setFill(cmykBlock, fill: cmykFill)
  try engine.block.appendChild(to: page, child: cmykBlock)

  // Set fill color using a CMYK color (values 0.0-1.0, tint controls opacity)
  let cmykColor = Color.cmyk(c: 0.0, m: 0.8, y: 0.95, k: 0.0, tint: 1.0)
  try engine.block.setColor(cmykFill, property: "fill/color/value", color: cmykColor)
  // highlight-colorsBasics-cmyk

  // highlight-colorsBasics-defineSpot
  // Define a spot color with an RGB approximation for screen preview
  engine.editor.setSpotColor(name: "MyBrand Red", r: 0.95, g: 0.25, b: 0.21)
  // You can also define a spot color with a CMYK approximation
  engine.editor.setSpotColor(name: "MyBrand Blue", c: 1.0, m: 0.7, y: 0.0, k: 0.1)
  // highlight-colorsBasics-defineSpot

  // highlight-colorsBasics-spot
  // Create a block and apply the defined spot color
  let spotBlock = try engine.block.create(.graphic)
  try engine.block.setShape(spotBlock, shape: engine.block.createShape(.rect))
  let spotFill = try engine.block.createFill(.color)
  try engine.block.setFill(spotBlock, fill: spotFill)
  try engine.block.appendChild(to: page, child: spotBlock)

  // Reference the spot color by name, with a tint and optional external reference
  let spotColor = Color.spot(name: "MyBrand Red", tint: 1.0, externalReference: "")
  try engine.block.setColor(spotFill, property: "fill/color/value", color: spotColor)
  // highlight-colorsBasics-spot

  // highlight-colorsBasics-stroke
  // Enable stroke and apply a stroke color using sRGB
  try engine.block.setStrokeEnabled(srgbBlock, enabled: true)
  try engine.block.setStrokeWidth(srgbBlock, width: 4)
  try engine.block.setColor(srgbBlock, property: "stroke/color", color: .rgba(r: 0.1, g: 0.2, b: 0.5, a: 1.0))

  // Apply a CMYK stroke color
  try engine.block.setStrokeEnabled(cmykBlock, enabled: true)
  try engine.block.setStrokeWidth(cmykBlock, width: 4)
  let cmykStroke = Color.cmyk(c: 0.0, m: 0.5, y: 0.6, k: 0.2, tint: 1.0)
  try engine.block.setColor(cmykBlock, property: "stroke/color", color: cmykStroke)

  // Apply a spot color stroke with reduced tint
  try engine.block.setStrokeEnabled(spotBlock, enabled: true)
  try engine.block.setStrokeWidth(spotBlock, width: 4)
  try engine.block.setColor(spotBlock, property: "stroke/color", color: .spot(name: "MyBrand Red", tint: 0.7))
  // highlight-colorsBasics-stroke

  // highlight-colorsBasics-getColor
  // Read back color values from a property
  let readSrgb: Color = try engine.block.getColor(srgbFill, property: "fill/color/value")
  let readCmyk: Color = try engine.block.getColor(cmykFill, property: "fill/color/value")
  let readSpot: Color = try engine.block.getColor(spotFill, property: "fill/color/value")

  // The returned Color enum indicates the color space through its case
  for color in [readSrgb, readCmyk, readSpot] {
    switch color {
    case let .rgba(r, g, b, a):
      print("sRGB: r=\(r), g=\(g), b=\(b), a=\(a)")
    case let .cmyk(c, m, y, k, tint):
      print("CMYK: c=\(c), m=\(m), y=\(y), k=\(k), tint=\(tint)")
    case let .spot(name, tint, externalReference):
      print("Spot: name=\(name), tint=\(tint), ref=\(externalReference)")
    @unknown default:
      print("Unknown color space")
    }
  }
  // highlight-colorsBasics-getColor
}
