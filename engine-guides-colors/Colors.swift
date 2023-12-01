import Foundation
import IMGLYEngine

@MainActor
func colors(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(block, value: 350)
  try engine.block.setPositionY(block, value: 400)
  try engine.block.setWidth(block, value: 100)
  try engine.block.setHeight(block, value: 100)

  let fill = try engine.block.createFill(.color)
  try engine.block.setFill(block, fill: fill)
  // highlight-setup

  // highlight-create-colors
  let rgbaBlue = Color.rgba(r: 0, g: 0, b: 1, a: 1)
  let cmykRed = Color.cmyk(c: 0, m: 1, y: 1, k: 0, tint: 1)
  let cmykPartialRed = Color.cmyk(c: 0, m: 1, y: 1, k: 0, tint: 0.5)

  engine.editor.setSpotColor(name: "Pink-Flamingo", r: 0.988, g: 0.455, b: 0.992)
  engine.editor.setSpotColor(name: "Yellow", c: 0, m: 0, y: 1, k: 0)
  let spotPinkFlamingo = Color.spot(name: "Pink-Flamingo", tint: 1.0, externalReference: "Crayola")
  let spotPartialYellow = Color.spot(name: "Yellow", tint: 0.3, externalReference: "")
  // highlight-create-colors

  // highlight-apply-colors
  try engine.block.setColor(fill, property: "fill/color/value", color: rgbaBlue)
  try engine.block.setColor(fill, property: "fill/color/value", color: cmykRed)
  try engine.block.setColor(block, property: "stroke/color", color: cmykPartialRed)
  try engine.block.setColor(fill, property: "fill/color/value", color: spotPinkFlamingo)
  try engine.block.setColor(block, property: "dropShadow/color", color: spotPartialYellow)
  // highlight-apply-colors

  // highlight-convert-color
  let cmykBlueConverted = try engine.editor.convertColorToColorSpace(color: rgbaBlue, colorSpace: .cmyk)
  let rgbaPinkFlamingoConverted = try engine.editor.convertColorToColorSpace(
    color: spotPinkFlamingo,
    colorSpace: .sRGB
  )
  // highlight-convert-color

  // highlight-find-spot
  engine.editor.findAllSpotColors() // ["Crayola-Pink-Flamingo", "Yellow"]
  // highlight-find-spot

  // highlight-change-spot
  engine.editor.setSpotColor(name: "Yellow", c: 0.2, m: 0, y: 1, k: 0)
  // highlight-change-spot

  // highlight-undefine-spot
  try engine.editor.removeSpotColor(name: "Yellow")
  // highlight-undefine-spot
}
