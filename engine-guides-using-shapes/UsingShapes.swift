import Foundation
import IMGLYEngine

@MainActor
func usingShapes(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let graphic = try engine.block.create(.graphic)
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg"
  )
  try engine.block.setFill(graphic, fill: imageFill)
  try engine.block.setWidth(graphic, value: 100)
  try engine.block.setHeight(graphic, value: 100)
  try engine.block.appendChild(to: scene, child: graphic)

  try await engine.scene.zoom(to: graphic, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)

  // highlight-setup

  // highlight-hasShape
  try engine.block.hasShape(graphic) // Returns true
  let text = try engine.block.create(.text)
  try engine.block.hasShape(text) // Returns false
  // highlight-hasShape

  // highlight-createShape
  let rectShape = try engine.block.createShape(.rect)
  // highlight-setShape
  try engine.block.setShape(graphic, shape: rectShape)
  // highlight-getShape
  let shape = try engine.block.getShape(graphic)
  let shapeType = try engine.block.getType(shape)
  // highlight-getShape

  // highlight-replaceShape
  let starShape = try engine.block.createShape(.star)
  try engine.block.destroy(engine.block.getShape(graphic))
  try engine.block.setShape(graphic, shape: starShape)
  /* The following line would also destroy the currently attached starShape */
  // engine.block.destroy(graphic)
  // highlight-replaceShape

  // highlight-getProperties
  let allShapeProperties = try engine.block.findAllProperties(starShape)
  // highlight-getProperties
  // highlight-modifyProperties
  try engine.block.setInt(starShape, property: "shape/star/points", value: 6)
  // highlight-modifyProperties
}
