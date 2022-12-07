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

  let rect = try engine.block.create(.rectShape)
  try engine.block.setWidth(rect, value: 100)
  try engine.block.setHeight(rect, value: 100)
  try engine.block.appendChild(to: page, child: rect)

  let circle = try engine.block.create(.ellipseShape)
  try engine.block.setPositionX(circle, value: 100)
  try engine.block.setPositionY(circle, value: 50)
  try engine.block.setWidth(circle, value: 300)
  try engine.block.setHeight(circle, value: 300)
  try engine.block.appendChild(to: page, child: circle)
  // highlight-setup

  // highlight-hasFill
  try engine.block.hasFill(scene) // Returns false
  try engine.block.hasFill(rect) // Returns true
  // highlight-hasFill

  // highlight-getFill
  let rectFill = try engine.block.getFill(rect)
  let defaultRectFillType = try engine.block.getType(rectFill)
  // highlight-getFill
  // highlight-getProperties
  let allFillProperties = try engine.block.findAllProperties(rectFill)
  // highlight-getProperties
  // highlight-modifyProperties
  try engine.block.setColor(rectFill, property: "fill/color/value", r: 1.0, g: 0.0, b: 0.0, a: 1.0)
  // highlight-modifyProperties

  // highlight-disableFill
  try engine.block.setFillEnabled(rect, enabled: false)
  try engine.block.setFillEnabled(rect, enabled: !engine.block.isFillEnabled(rect))
  // highlight-disableFill

  // highlight-createFill
  let imageFill = try engine.block.createFill("image")
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg"
  )
  // highlight-createFill

  // highlight-replaceFill
  try engine.block.destroy(engine.block.getFill(circle))
  try engine.block.setFill(circle, fill: imageFill)

  /* The following line would also destroy imageFill */
  // try engine.block.destroy(circle)
  // highlight-replaceFill

  // highlight-duplicateFill
  let duplicateCircle = try engine.block.duplicate(circle)
  try engine.block.setPositionX(duplicateCircle, value: 450)
  let autoDuplicateFill = try engine.block.getFill(duplicateCircle)
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
  let star = try engine.block.create(.starShape)
  try engine.block.setPositionX(star, value: 350)
  try engine.block.setPositionY(star, value: 400)
  try engine.block.setWidth(star, value: 100)
  try engine.block.setHeight(star, value: 100)
  try engine.block.appendChild(to: page, child: star)

  try engine.block.setFill(star, fill: engine.block.getFill(circle))
  // highlight-sharedFill
}
