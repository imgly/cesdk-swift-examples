import Foundation
import IMGLYEngine

@MainActor
func editShapes(engine: Engine) async throws {
  // Demo scaffolding: a scene with a single page that holds every example
  // block in this guide. Each section creates one or more graphic blocks and
  // places them at fixed positions so the final hero capture shows the full
  // gallery.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-editShapes-setup
  // Start from a graphic block with a rectangle shape and a solid color fill.
  let demoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(demoBlock, shape: engine.block.createShape(.rect))
  let demoFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    demoFill,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.85, b: 0.30, a: 1.0),
  )
  try engine.block.setFill(demoBlock, fill: demoFill)
  try engine.block.setWidth(demoBlock, value: 220)
  try engine.block.setHeight(demoBlock, value: 220)
  try engine.block.setPositionX(demoBlock, value: 40)
  try engine.block.setPositionY(demoBlock, value: 40)
  try engine.block.appendChild(to: page, child: demoBlock)
  // highlight-editShapes-setup

  // ## Accessing Shapes
  // highlight-editShapes-accessShape
  let supportsShapes = try engine.block.supportsShape(demoBlock)
  let shape = try engine.block.getShape(demoBlock)
  let shapeType = try engine.block.getType(shape)
  print("Supports shape: \(supportsShapes), shape type: \(shapeType)")
  // highlight-editShapes-accessShape

  // ## Changing Shape Type
  // highlight-editShapes-replaceShape
  // Hold a reference to the old shape, swap it for the new one, then destroy
  // the old shape so it doesn't leak.
  let oldShape = try engine.block.getShape(demoBlock)
  let ellipseShape = try engine.block.createShape(.ellipse)
  try engine.block.setShape(demoBlock, shape: ellipseShape)
  try engine.block.destroy(oldShape)
  // highlight-editShapes-replaceShape

  try await engine.captureGuide(page, label: "after-shape-replace")

  // ## Discovering Shape Properties
  // highlight-editShapes-discoverProperties
  // Each shape type exposes its own property keys. Use findAllProperties to
  // list them.
  let starBlock = try engine.block.create(.graphic)
  let starShape = try engine.block.createShape(.star)
  try engine.block.setShape(starBlock, shape: starShape)
  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    starFill,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.55, b: 0.35, a: 1.0),
  )
  try engine.block.setFill(starBlock, fill: starFill)
  try engine.block.setWidth(starBlock, value: 200)
  try engine.block.setHeight(starBlock, value: 200)
  try engine.block.setPositionX(starBlock, value: 290)
  try engine.block.setPositionY(starBlock, value: 40)
  try engine.block.appendChild(to: page, child: starBlock)

  let starProperties = try engine.block.findAllProperties(starShape)
  print("Star properties: \(starProperties)")
  // Prints: ["includedInExport", "name", "shape/star/cornerRadius", "shape/star/innerDiameter", "shape/star/points", "type", "uuid"]
  // highlight-editShapes-discoverProperties

  // ### Star Properties
  // highlight-editShapes-starProperties
  try engine.block.setInt(starShape, property: "shape/star/points", value: 7)
  try engine.block.setFloat(starShape, property: "shape/star/innerDiameter", value: 0.45)
  // highlight-editShapes-starProperties

  // ### Rectangle Corner Radii
  // highlight-editShapes-rectProperties
  // Each corner has its own property — set them independently.
  let roundedBlock = try engine.block.create(.graphic)
  let roundedShape = try engine.block.createShape(.rect)
  try engine.block.setShape(roundedBlock, shape: roundedShape)
  let roundedFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    roundedFill,
    property: "fill/color/value",
    color: .rgba(r: 0.42, g: 0.66, b: 0.94, a: 1.0),
  )
  try engine.block.setFill(roundedBlock, fill: roundedFill)
  try engine.block.setWidth(roundedBlock, value: 200)
  try engine.block.setHeight(roundedBlock, value: 160)
  try engine.block.setPositionX(roundedBlock, value: 540)
  try engine.block.setPositionY(roundedBlock, value: 60)
  try engine.block.appendChild(to: page, child: roundedBlock)

  try engine.block.setFloat(roundedShape, property: "shape/rect/cornerRadiusTL", value: 40)
  try engine.block.setFloat(roundedShape, property: "shape/rect/cornerRadiusTR", value: 40)
  try engine.block.setFloat(roundedShape, property: "shape/rect/cornerRadiusBR", value: 40)
  try engine.block.setFloat(roundedShape, property: "shape/rect/cornerRadiusBL", value: 40)
  // highlight-editShapes-rectProperties

  // ### Polygon Properties
  // highlight-editShapes-polygonProperties
  let polygonBlock = try engine.block.create(.graphic)
  let polygonShape = try engine.block.createShape(.polygon)
  try engine.block.setShape(polygonBlock, shape: polygonShape)
  let polygonFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    polygonFill,
    property: "fill/color/value",
    color: .rgba(r: 0.20, g: 0.65, b: 0.55, a: 1.0),
  )
  try engine.block.setFill(polygonBlock, fill: polygonFill)
  try engine.block.setWidth(polygonBlock, value: 160)
  try engine.block.setHeight(polygonBlock, value: 160)
  try engine.block.setPositionX(polygonBlock, value: 40)
  try engine.block.setPositionY(polygonBlock, value: 290)
  try engine.block.appendChild(to: page, child: polygonBlock)

  try engine.block.setInt(polygonShape, property: "shape/polygon/sides", value: 6)
  // highlight-editShapes-polygonProperties

  // ### Line
  // highlight-editShapes-lineProperties
  // Lines have no shape-specific properties. Their visual thickness comes
  // from the parent block's stroke.
  let lineBlock = try engine.block.create(.graphic)
  try engine.block.setShape(lineBlock, shape: engine.block.createShape(.line))
  try engine.block.setStrokeEnabled(lineBlock, enabled: true)
  try engine.block.setStrokeColor(lineBlock, color: .rgba(r: 0.15, g: 0.15, b: 0.15, a: 1.0))
  try engine.block.setStrokeWidth(lineBlock, width: 4)
  try engine.block.setWidth(lineBlock, value: 160)
  try engine.block.setHeight(lineBlock, value: 8)
  try engine.block.setPositionX(lineBlock, value: 40)
  try engine.block.setPositionY(lineBlock, value: 470)
  try engine.block.appendChild(to: page, child: lineBlock)
  // highlight-editShapes-lineProperties

  // ### Vector Path
  // highlight-editShapes-vectorPath
  let vectorPathBlock = try engine.block.create(.graphic)
  let vectorPathShape = try engine.block.createShape(.vectorPath)
  try engine.block.setShape(vectorPathBlock, shape: vectorPathShape)
  let vectorPathFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    vectorPathFill,
    property: "fill/color/value",
    color: .rgba(r: 0.55, g: 0.35, b: 0.85, a: 1.0),
  )
  try engine.block.setFill(vectorPathBlock, fill: vectorPathFill)
  try engine.block.setWidth(vectorPathBlock, value: 160)
  try engine.block.setHeight(vectorPathBlock, value: 160)
  try engine.block.setPositionX(vectorPathBlock, value: 230)
  try engine.block.setPositionY(vectorPathBlock, value: 290)
  try engine.block.appendChild(to: page, child: vectorPathBlock)

  // Single-path SVG-style path data (a heart shape).
  try engine.block.setString(
    vectorPathShape,
    property: "shape/vector_path/path",
    value: "M 50,15 C 35,-5 5,5 5,30 C 5,55 30,75 50,95 C 70,75 95,55 95,30 C 95,5 65,-5 50,15 Z",
  )
  // highlight-editShapes-vectorPath

  // ## Editing Fill Color
  // highlight-editShapes-fillColor
  // Read the existing fill from the demo block and update its color.
  let fill = try engine.block.getFill(demoBlock)
  try engine.block.setColor(
    fill,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.30, b: 0.45, a: 1.0),
  )
  // highlight-editShapes-fillColor

  try await engine.captureGuide(page, label: "after-color-change")

  // ## Replacing Fill Type
  // highlight-editShapes-replaceFill
  // Build a linear-gradient fill, then swap the demo block's color fill for it.
  let gradientFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    gradientFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.95, g: 0.30, b: 0.45, a: 1.0), stop: 0.0),
      GradientColorStop(color: .rgba(r: 0.85, g: 0.55, b: 0.95, a: 1.0), stop: 1.0),
    ],
  )
  // Destroy the previous fill before swapping so it doesn't leak.
  try engine.block.destroy(engine.block.getFill(demoBlock))
  try engine.block.setFill(demoBlock, fill: gradientFill)
  // highlight-editShapes-replaceFill

  // ## Editing Stroke Properties
  // highlight-editShapes-stroke
  if try engine.block.supportsStroke(demoBlock) {
    try engine.block.setStrokeEnabled(demoBlock, enabled: true)
    try engine.block.setStrokeColor(demoBlock, color: .rgba(r: 0.10, g: 0.10, b: 0.30, a: 1.0))
    try engine.block.setStrokeWidth(demoBlock, width: 6)
    try engine.block.setStrokePosition(demoBlock, position: .outer)
  }
  // highlight-editShapes-stroke

  try await engine.captureGuide(page, label: "after-stroke")

  // ## Transform Operations
  // highlight-editShapes-transforms
  // Position and dimensions move the block around the page; rotation expects
  // radians; flips mirror the rendered content.
  try engine.block.setPositionX(demoBlock, value: 40)
  try engine.block.setPositionY(demoBlock, value: 40)
  try engine.block.setWidth(demoBlock, value: 220)
  try engine.block.setHeight(demoBlock, value: 220)
  try engine.block.setRotation(demoBlock, radians: .pi / 12)
  try engine.block.setFlipHorizontal(demoBlock, flip: true)
  // highlight-editShapes-transforms

  try await engine.captureGuide(page, label: "after-transform")

  // ## Combining Shapes with Boolean Operations
  // highlight-editShapes-booleanCombine
  // Create two overlapping ellipses, then combine them into one graphic.
  let booleanA = try engine.block.create(.graphic)
  try engine.block.setShape(booleanA, shape: engine.block.createShape(.ellipse))
  let booleanFillA = try engine.block.createFill(.color)
  try engine.block.setColor(
    booleanFillA,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.45, b: 0.75, a: 1.0),
  )
  try engine.block.setFill(booleanA, fill: booleanFillA)
  try engine.block.setWidth(booleanA, value: 140)
  try engine.block.setHeight(booleanA, value: 140)
  try engine.block.setPositionX(booleanA, value: 420)
  try engine.block.setPositionY(booleanA, value: 310)
  try engine.block.appendChild(to: page, child: booleanA)

  let booleanB = try engine.block.create(.graphic)
  try engine.block.setShape(booleanB, shape: engine.block.createShape(.ellipse))
  let booleanFillB = try engine.block.createFill(.color)
  try engine.block.setColor(
    booleanFillB,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.45, b: 0.75, a: 1.0),
  )
  try engine.block.setFill(booleanB, fill: booleanFillB)
  try engine.block.setWidth(booleanB, value: 140)
  try engine.block.setHeight(booleanB, value: 140)
  try engine.block.setPositionX(booleanB, value: 510)
  try engine.block.setPositionY(booleanB, value: 360)
  try engine.block.appendChild(to: page, child: booleanB)

  // combine() destroys the input blocks and returns a new graphic that carries
  // a vector_path shape with the merged geometry.
  let union = try engine.block.combine([booleanA, booleanB], booleanOperation: .union)
  print("Union block: \(union)")
  // highlight-editShapes-booleanCombine

  // ## Applying Effects to Shapes
  // highlight-editShapes-effect
  let effectBlock = try engine.block.create(.graphic)
  try engine.block.setShape(effectBlock, shape: engine.block.createShape(.rect))
  let effectFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    effectFill,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.85, b: 0.30, a: 1.0),
  )
  try engine.block.setFill(effectBlock, fill: effectFill)
  try engine.block.setWidth(effectBlock, value: 200)
  try engine.block.setHeight(effectBlock, value: 80)
  try engine.block.setPositionX(effectBlock, value: 290)
  try engine.block.setPositionY(effectBlock, value: 500)
  try engine.block.appendChild(to: page, child: effectBlock)

  let extrudeBlur = try engine.block.createEffect(.extrudeBlur)
  try engine.block.setFloat(extrudeBlur, property: "effect/extrude_blur/amount", value: 0.8)
  try engine.block.appendEffect(effectBlock, effectID: extrudeBlur)
  // highlight-editShapes-effect

  // ## Grouping and Ungrouping
  // highlight-editShapes-group
  let groupChildA = try engine.block.create(.graphic)
  try engine.block.setShape(groupChildA, shape: engine.block.createShape(.rect))
  let groupFillA = try engine.block.createFill(.color)
  try engine.block.setColor(
    groupFillA,
    property: "fill/color/value",
    color: .rgba(r: 0.42, g: 0.66, b: 0.94, a: 1.0),
  )
  try engine.block.setFill(groupChildA, fill: groupFillA)
  try engine.block.setWidth(groupChildA, value: 80)
  try engine.block.setHeight(groupChildA, value: 80)
  try engine.block.setPositionX(groupChildA, value: 520)
  try engine.block.setPositionY(groupChildA, value: 500)
  try engine.block.appendChild(to: page, child: groupChildA)

  let groupChildB = try engine.block.create(.graphic)
  try engine.block.setShape(groupChildB, shape: engine.block.createShape(.ellipse))
  let groupFillB = try engine.block.createFill(.color)
  try engine.block.setColor(
    groupFillB,
    property: "fill/color/value",
    color: .rgba(r: 0.20, g: 0.65, b: 0.55, a: 1.0),
  )
  try engine.block.setFill(groupChildB, fill: groupFillB)
  try engine.block.setWidth(groupChildB, value: 80)
  try engine.block.setHeight(groupChildB, value: 80)
  try engine.block.setPositionX(groupChildB, value: 620)
  try engine.block.setPositionY(groupChildB, value: 500)
  try engine.block.appendChild(to: page, child: groupChildB)

  let canGroup = try engine.block.isGroupable([groupChildA, groupChildB])
  if canGroup {
    let groupBlock = try engine.block.group([groupChildA, groupChildB])
    print("Group container: \(groupBlock)")
    // Call ungroup() to dissolve the container and re-parent the children:
    // try engine.block.ungroup(groupBlock)
  }
  // highlight-editShapes-group

  try await engine.captureGuide(page, label: "hero")
}
