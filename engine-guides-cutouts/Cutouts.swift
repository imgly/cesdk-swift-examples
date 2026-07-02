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

  // highlight-create-cutout-from-path
  let circle = try engine.block.createCutoutFromPath("M 0,25 a 25,25 0 1,1 50,0 a 25,25 0 1,1 -50,0 Z")
  try engine.block.appendChild(to: page, child: circle)
  // highlight-create-cutout-from-path

  // highlight-configure-cutout-type
  try engine.block.setEnum(circle, property: "cutout/type", value: "Dashed")
  // highlight-configure-cutout-type

  // highlight-configure-cutout-offset
  try engine.block.setFloat(circle, property: "cutout/offset", value: 3.0)
  // highlight-configure-cutout-offset

  // highlight-configure-cutout-smoothing
  try engine.block.setFloat(circle, property: "cutout/smoothing", value: 2.0)
  // highlight-configure-cutout-smoothing

  // highlight-create-square-cutout
  let square = try engine.block.createCutoutFromPath("M 0,0 H 50 V 50 H 0 Z")
  try engine.block.setFloat(square, property: "cutout/offset", value: 6.0)
  try engine.block.appendChild(to: page, child: square)
  // highlight-create-square-cutout

  // highlight-combine-cutouts
  let union = try engine.block.createCutoutFromOperation(
    containing: [circle, square],
    cutoutOperation: .union,
  )
  try engine.block.appendChild(to: page, child: union)
  try engine.block.destroy(circle)
  try engine.block.destroy(square)
  // highlight-combine-cutouts

  // highlight-customize-spot-color
  engine.editor.setSpotColor(name: "CutContour", r: 0.0, g: 0.0, b: 1.0)
  engine.editor.setSpotColor(name: "PerfCutContour", r: 1.0, g: 0.5, b: 0.0)
  // highlight-customize-spot-color

  // highlight-create-cutout-from-blocks
  let graphic = try engine.block.create(.graphic)
  try engine.block.setShape(graphic, shape: engine.block.createShape(.rect))
  let fill = try engine.block.createFill(.color)
  try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0, g: 0, b: 0))
  try engine.block.setFill(graphic, fill: fill)
  try engine.block.setWidth(graphic, value: 100)
  try engine.block.setHeight(graphic, value: 100)
  try engine.block.appendChild(to: page, child: graphic)

  let traced = try engine.block.createCutoutFromBlocks(
    ids: [graphic],
    vectorizeDistanceThreshold: 2,
    simplifyDistanceThreshold: 4,
    useExistingShapeInformation: true,
  )
  try engine.block.appendChild(to: page, child: traced)
  // highlight-create-cutout-from-blocks
}
