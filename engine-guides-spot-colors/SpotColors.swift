import Foundation
import IMGLYEngine

@MainActor
func spotColors(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)

  let text = try engine.block.create(.text)
  try engine.block.setPositionX(text, value: 350)
  try engine.block.setPositionY(text, value: 100)

  let star = try engine.block.create(.starShape)
  try engine.block.setPositionX(star, value: 350)
  try engine.block.setPositionY(star, value: 400)
  try engine.block.setWidth(star, value: 100)
  try engine.block.setHeight(star, value: 100)
  // highlight-setup

  // highlight-create
  engine.editor.setSpotColor(name: "Crayola-Pink-Flamingo", r: 0.988, g: 0.455, b: 0.992)
  engine.editor.setSpotColor(name: "Pantone-ColorOfTheYear-2022", r: 0.4, g: 0.404, b: 0.671)
  engine.editor.setSpotColor(name: "Yellow", r: 1, g: 1, b: 0)
  engine.editor.getSpotColor(name: "Yellow") // (r: 1, g: 1, b: 0)
  engine.editor.findAllSpotColors() // ["Crayola-Pink-Flamingo", "Pantone-ColorOfTheYear-2022", "Yellow"]
  // highlight-create

  // highlight-apply-star
  try engine.block.setColorSpot(star, property: "fill/solid/color", name: "Crayola-Pink-Flamingo")

  try engine.block.setColorSpot(star, property: "stroke/color", name: "Yellow", tint: 0.8)
  try engine.block.setStrokeEnabled(star, enabled: true)

  try engine.block.getColorSpotName(star, property: "fill/solid/color") // "Crayola-Pink-Flamingo"
  try engine.block.getColorSpotTint(star, property: "stroke/color") // 0.8
  // highlight-apply-star

  // highlight-apply-text
  try engine.block.setColorSpot(text, property: "fill/solid/color", name: "Yellow")

  try engine.block.setColorSpot(text, property: "stroke/color", name: "Crayola-Pink-Flamingo", tint: 0.5)
  try engine.block.setStrokeEnabled(text, enabled: true)

  try engine.block.setColorSpot(text, property: "backgroundColor/color", name: "Pantone-ColorOfTheYear-2022", tint: 0.9)
  try engine.block.setBackgroundColorEnabled(text, enabled: true)
  // highlight-apply-text

  // highlight-change
  engine.editor.setSpotColor(name: "Yellow", r: 1, g: 1, b: 0.4)
  // highlight-change

  // highlight-undefine
  try engine.editor.removeSpotColor(name: "Yellow")
  // highlight-undefine
}
