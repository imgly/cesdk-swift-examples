import Foundation
import IMGLYEngine

@MainActor
func compoundShapes(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-compoundShapes-createCompound
  // A graphic block draws the outline of its compound shape with its fill
  let badge = try engine.block.create(.graphic)
  let badgeFill = try engine.block.createFill(.color)
  try engine.block.setColor(badgeFill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1))
  try engine.block.setFill(badge, fill: badgeFill)
  try engine.block.setWidth(badge, value: 300)
  try engine.block.setHeight(badge, value: 300)
  try engine.block.setPositionX(badge, value: 75)
  try engine.block.setPositionY(badge, value: 150)
  try engine.block.appendChild(to: page, child: badge)

  let compound = try engine.block.createShape(.compound)
  try engine.block.setShape(badge, shape: compound)
  // highlight-compoundShapes-createCompound

  // highlight-compoundShapes-appendSubshapes
  // The first subshape is the base. A new subshape fills the reference box.
  let circle = try engine.block.createShape(.ellipse)
  try engine.block.appendSubshape(compound, subshapeID: circle)

  let diamond = try engine.block.createShape(.rect)
  try engine.block.appendSubshape(compound, subshapeID: diamond)
  // highlight-compoundShapes-appendSubshapes

  // highlight-compoundShapes-placeSubshape
  // A 40 by 40 square, centered in the 100 by 100 reference box and turned
  // into a diamond. Rotation turns the box about its anchor.
  try engine.block.setFloat(diamond, property: "shape/width", value: 40)
  try engine.block.setFloat(diamond, property: "shape/height", value: 40)
  try engine.block.setFloat(diamond, property: "shape/anchor/x", value: 20)
  try engine.block.setFloat(diamond, property: "shape/anchor/y", value: 20)
  try engine.block.setFloat(diamond, property: "shape/position/x", value: 50)
  try engine.block.setFloat(diamond, property: "shape/position/y", value: 50)
  try engine.block.setFloat(diamond, property: "shape/rotation", value: 45)
  // highlight-compoundShapes-placeSubshape

  // highlight-compoundShapes-combineMode
  // Cut every later subshape out of the base circle
  try engine.block.setEnum(compound, property: "shape/compound/mode", value: "Subtract")
  // highlight-compoundShapes-combineMode

  // highlight-compoundShapes-reorder
  // Insert a small dot between the circle and the diamond
  let dot = try engine.block.createShape(.ellipse)
  try engine.block.setFloat(dot, property: "shape/width", value: 16)
  try engine.block.setFloat(dot, property: "shape/height", value: 16)
  try engine.block.setFloat(dot, property: "shape/position/x", value: 42)
  try engine.block.setFloat(dot, property: "shape/position/y", value: 8)
  try engine.block.insertSubshape(compound, subshapeID: dot, index: 1)
  print(try engine.block.getSubshapes(compound)) // [circle, dot, diamond]

  // Removing a subshape does not destroy it
  try engine.block.removeSubshape(compound, index: 1)
  print(engine.block.isValid(dot)) // true
  try engine.block.destroy(dot)
  // highlight-compoundShapes-reorder

  // highlight-compoundShapes-fillRule
  // Two overlapping squares in Merge mode. EvenOdd makes the overlap a hole.
  let squares = try engine.block.create(.graphic)
  let squaresFill = try engine.block.createFill(.color)
  try engine.block.setColor(squaresFill, property: "fill/color/value", color: .rgba(r: 0.95, g: 0.5, b: 0.1, a: 1))
  try engine.block.setFill(squares, fill: squaresFill)
  try engine.block.setWidth(squares, value: 300)
  try engine.block.setHeight(squares, value: 300)
  try engine.block.setPositionX(squares, value: 425)
  try engine.block.setPositionY(squares, value: 150)
  try engine.block.appendChild(to: page, child: squares)

  let squaresCompound = try engine.block.createShape(.compound)
  try engine.block.setShape(squares, shape: squaresCompound)

  let firstSquare = try engine.block.createShape(.rect)
  try engine.block.setFloat(firstSquare, property: "shape/width", value: 60)
  try engine.block.setFloat(firstSquare, property: "shape/height", value: 60)
  try engine.block.appendSubshape(squaresCompound, subshapeID: firstSquare)

  let secondSquare = try engine.block.createShape(.rect)
  try engine.block.setFloat(secondSquare, property: "shape/width", value: 60)
  try engine.block.setFloat(secondSquare, property: "shape/height", value: 60)
  try engine.block.setFloat(secondSquare, property: "shape/position/x", value: 40)
  try engine.block.setFloat(secondSquare, property: "shape/position/y", value: 40)
  try engine.block.appendSubshape(squaresCompound, subshapeID: secondSquare)

  try engine.block.setEnum(squaresCompound, property: "shape/compound/fillRule", value: "EvenOdd")
  // highlight-compoundShapes-fillRule

  // highlight-compoundShapes-animateSubshape
  // Slide the second square to the top left corner and back over the
  // duration of the graphic block
  try engine.block.setKeyframes(secondSquare, property: "shape/position", keyframes: [
    Keyframe(time: 0, value: .vec2([40, 40])),
    Keyframe(time: 0.5, value: .vec2([0, 0])),
    Keyframe(time: 1, value: .vec2([40, 40])),
  ])
  // highlight-compoundShapes-animateSubshape

  // highlight-compoundShapes-errors
  let line = try engine.block.createShape(.line)
  do {
    try engine.block.appendSubshape(compound, subshapeID: line)
  } catch let error as EngineError {
    print(error.catalogCode == .blockSubshapeTypeUnsupported) // true
  }
  try engine.block.destroy(line)
  // highlight-compoundShapes-errors

  // highlight-compoundShapes-export
  let png = try await engine.block.export(page, mimeType: .png)
  print("Exported \(png.count) bytes")
  // highlight-compoundShapes-export
}
