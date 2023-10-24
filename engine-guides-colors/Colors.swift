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

  let star = try engine.block.create(.starShape)
  try engine.block.setPositionX(star, value: 350)
  try engine.block.setPositionY(star, value: 400)
  try engine.block.setWidth(star, value: 100)
  try engine.block.setHeight(star, value: 100)

  let fill = try engine.block.getFill(star)
  // highlight-setup

  // highlight-create-colors
  let rgbaBlue = Color.rgba(r: 0, g: 0, b: 1, a: 1)
  let cmykRed = Color.cmyk(c: 0, m: 1, y: 1, k: 0, tint: 1)
  let cmykPartialRed = Color.cmyk(c: 0, m: 1, y: 1, k: 0, tint: 0.5)

  try engine.editor.setSpotColor(name: "Pink-Flamingo", r: 0.988, g: 0.455, b: 0.992)
  try engine.editor.setSpotColor(name: "Yellow", c: 0, m: 0, y: 1, k: 0)
  let spotPinkFlamingo = Color.spot(name: "Pink-Flamingo", tint: 1.0, externalReference: "Crayola")
  let spotPartialYellow = Color.spot(name: "Yellow", tint: 0.3, externalReference: "")
  // highlight-create-colors

  // highlight-apply-colors
  try engine.block.setColor(fill, property: "fill/color/value", color: rgbaBlue)
  try engine.block.setColor(fill, property: "fill/color/value", color: cmykRed)
  try engine.block.setColor(star, property: "stroke/color", color: cmykPartialRed)
  try engine.block.setColor(fill, property: "fill/color/value", color: spotPinkFlamingo)
  try engine.block.setColor(star, property: "dropShadow/color", color: spotPartialYellow)
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
  try engine.editor.setSpotColor(name: "Yellow", c: 0.2, m: 0, y: 1, k: 0)
  // highlight-change-spot

  // highlight-undefine-spot
  try engine.editor.removeSpotColor(name: "Yellow")
  // highlight-undefine-spot
}
