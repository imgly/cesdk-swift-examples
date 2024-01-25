import Foundation
import IMGLYEngine

@MainActor
func boolOps(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-setup

  // highlight-combine-union
  let circle1 = try engine.block.create("shapes/ellipse")
  try engine.block.setPositionX(circle1, value: 30)
  try engine.block.setPositionY(circle1, value: 30)
  try engine.block.setWidth(circle1, value: 40)
  try engine.block.setHeight(circle1, value: 40)
  try engine.block.appendChild(to: page, child: circle1)

  let circle2 = try engine.block.create("shapes/ellipse")
  try engine.block.setPositionX(circle2, value: 80)
  try engine.block.setPositionY(circle2, value: 30)
  try engine.block.setWidth(circle2, value: 40)
  try engine.block.setHeight(circle2, value: 40)
  try engine.block.appendChild(to: page, child: circle2)

  let circle3 = try engine.block.create("shapes/ellipse")
  try engine.block.setPositionX(circle3, value: 50)
  try engine.block.setPositionY(circle3, value: 50)
  try engine.block.setWidth(circle3, value: 50)
  try engine.block.setHeight(circle3, value: 50)
  try engine.block.appendChild(to: page, child: circle3)

  let union = try engine.block.combine([circle1, circle2, circle3], booleanOperation: .union)
  // highlight-combine-union

  // highlight-combine-difference
  let text = try engine.block.create("text")
  try engine.block.replaceText(text, text: "Removed text")
  try engine.block.setPositionX(text, value: 10)
  try engine.block.setPositionY(text, value: 40)
  try engine.block.setWidth(text, value: 80)
  try engine.block.setHeight(text, value: 10)
  try engine.block.appendChild(to: page, child: text)

  let image = try engine.block.create("image")
  try engine.block.setPositionX(image, value: 0)
  try engine.block.setPositionY(image, value: 0)
  try engine.block.setWidth(image, value: 100)
  try engine.block.setHeight(image, value: 100)
  try engine.block.setString(
    engine.block.getFill(image),
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg"
  )
  try engine.block.appendChild(to: page, child: image)

  try engine.block.sendToBack(image)
  let difference = try engine.block.combine([image, text], booleanOperation: .difference)
  // highlight-combine-difference
}
