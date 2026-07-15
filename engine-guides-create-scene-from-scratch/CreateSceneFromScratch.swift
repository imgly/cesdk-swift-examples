import Foundation
import IMGLYEngine

@MainActor
func createSceneFromScratch(engine: Engine) async throws {
  // highlight-createSceneFromScratch-create
  let scene = try engine.scene.create()
  // highlight-createSceneFromScratch-create

  // highlight-createSceneFromScratch-add-page
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-createSceneFromScratch-add-page

  // highlight-createSceneFromScratch-background
  let pageFill = try engine.block.createFill(.color)
  try engine.block.setColor(pageFill, property: "fill/color/value", color: .rgba(r: 0.95, g: 0.95, b: 0.96, a: 1))
  try engine.block.setFill(page, fill: pageFill)
  // highlight-createSceneFromScratch-background

  // highlight-createSceneFromScratch-add-block
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.star))
  let fill = try engine.block.createFill(.color)
  try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.27, g: 0.52, b: 0.96, a: 1))
  try engine.block.setFill(block, fill: fill)
  try engine.block.setWidth(block, value: 300)
  try engine.block.setHeight(block, value: 300)
  try engine.block.setPositionX(block, value: 250)
  try engine.block.setPositionY(block, value: 150)
  try engine.block.appendChild(to: page, child: block)
  // highlight-createSceneFromScratch-add-block

  // highlight-createSceneFromScratch-zoom
  try engine.scene.enableZoomAutoFit(
    page,
    axis: .both,
    paddingLeft: 40,
    paddingTop: 40,
    paddingRight: 40,
    paddingBottom: 40,
  )
  // highlight-createSceneFromScratch-zoom
}
