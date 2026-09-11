import Foundation
import IMGLYEngine

@MainActor
func cutouts(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-setup

  // highlight-create-cutouts
  let circle = try engine.block.createCutoutFromPath("M 0,25 a 25,25 0 1,1 50,0 a 25,25 0 1,1 -50,0 Z")
  try engine.block.setFloat(circle, property: "cutout/offset", value: 3.0)
  try engine.block.setEnum(circle, property: "cutout/type", value: "Dashed")

  var square = try engine.block.createCutoutFromPath("M 0,0 H 50 V 50 H 0 Z")
  try engine.block.setFloat(square, property: "cutout/offset", value: 6.0)
  // highlight-create-cutouts

  // highlight-cutout-union
  var union = try engine.block.createCutoutFromOperation(containing: [circle, square], cutoutOperation: .union)
  try engine.block.destroy(circle)
  try engine.block.destroy(square)
  // highlight-cutout-union

  // highlight-spot-color-solid
  engine.editor.setSpotColor(name: "CutContour", r: 0.0, g: 0.0, b: 1.0)
  // highlight-spot-color-solid
}
