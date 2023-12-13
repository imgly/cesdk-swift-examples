import Foundation
import IMGLYEngine

@MainActor
func usingFills(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block, value: 100)
  try engine.block.setHeight(block, value: 100)
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  try engine.block.appendChild(to: page, child: block)
  // highlight-setup

  // highlight-hasFill
  try engine.block.hasFill(scene) // Returns false
  try engine.block.hasFill(block) // Returns true
  // highlight-hasFill

  // highlight-getFill
  let colorFill = try engine.block.getFill(block)
  let defaultRectFillType = try engine.block.getType(colorFill)
  // highlight-getFill
  // highlight-getProperties
  let allFillProperties = try engine.block.findAllProperties(colorFill)
  // highlight-getProperties
  // highlight-modifyProperties
  try engine.block.setColor(colorFill, property: "fill/color/value", color: .rgba(r: 1.0, g: 0.0, b: 0.0, a: 1.0))
  // highlight-modifyProperties

  // highlight-disableFill
  try engine.block.setFillEnabled(block, enabled: false)
  try engine.block.setFillEnabled(block, enabled: !engine.block.isFillEnabled(block))
  // highlight-disableFill

  // highlight-createFill
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg"
  )
  // highlight-createFill

  // highlight-replaceFill
  try engine.block.destroy(colorFill)
  try engine.block.setFill(block, fill: imageFill)

  /* The following line would also destroy imageFill */
  // try engine.block.destroy(circle)
  // highlight-replaceFill

  // highlight-duplicateFill
  let duplicateBlock = try engine.block.duplicate(block)
  try engine.block.setPositionX(duplicateBlock, value: 450)
  let autoDuplicateFill = try engine.block.getFill(duplicateBlock)
  try engine.block.setString(
    autoDuplicateFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_2.jpg"
  )

  // let manualDuplicateFill = try engine.block.duplicate(autoDuplicateFill)
  // /* We could now assign this fill to another block. */
  // try engine.block.destroy(manualDuplicateFill)
  // highlight-duplicateFill

  // highlight-sharedFill
  let sharedFillBlock = try engine.block.create(.graphic)
  try engine.block.setShape(sharedFillBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(sharedFillBlock, value: 350)
  try engine.block.setPositionY(sharedFillBlock, value: 400)
  try engine.block.setWidth(sharedFillBlock, value: 100)
  try engine.block.setHeight(sharedFillBlock, value: 100)
  try engine.block.appendChild(to: page, child: sharedFillBlock)

  try engine.block.setFill(sharedFillBlock, fill: engine.block.getFill(block))
  // highlight-sharedFill
}
