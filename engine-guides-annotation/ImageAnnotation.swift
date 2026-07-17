import IMGLYEngine

@MainActor
func imageAnnotation(engine: Engine) async throws {
  // Demo scaffolding: a page with a light placeholder rectangle that stands in
  // for an image so the annotations rendered below have something to sit on
  // top of in the captured hero.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let imageArea = try engine.block.create(.graphic)
  try engine.block.setShape(imageArea, shape: engine.block.createShape(.rect))
  let imageAreaFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    imageAreaFill,
    property: "fill/color/value",
    color: .rgba(r: 0.92, g: 0.94, b: 0.96, a: 1.0),
  )
  try engine.block.setFill(imageArea, fill: imageAreaFill)
  try engine.block.setPositionX(imageArea, value: 40)
  try engine.block.setPositionY(imageArea, value: 40)
  try engine.block.setWidth(imageArea, value: 720)
  try engine.block.setHeight(imageArea, value: 520)
  try engine.block.appendChild(to: page, child: imageArea)

  let highlight = try addRectangleAnnotation(engine: engine, page: page)
  _ = try addCircleAnnotation(engine: engine, page: page)
  _ = try addLineAnnotation(engine: engine, page: page)
  _ = try addRedactionBox(engine: engine, page: page)
  try styleRectangleAnnotationAppearance(engine: engine, rectangle: highlight)

  try await engine.captureGuide(page, label: "hero")
}

// highlight-imageAnnotation-rectangle
@MainActor
func addRectangleAnnotation(engine: Engine, page: DesignBlockID) throws -> DesignBlockID {
  let highlight = try engine.block.create(.graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(highlight, shape: rectShape)

  try engine.block.setPositionX(highlight, value: 100)
  try engine.block.setPositionY(highlight, value: 100)
  try engine.block.setWidth(highlight, value: 220)
  try engine.block.setHeight(highlight, value: 90)

  let fill = try engine.block.createFill(.color)
  try engine.block.setColor(
    fill,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.82, b: 0.0, a: 0.4),
  )
  try engine.block.setFill(highlight, fill: fill)

  try engine.block.appendChild(to: page, child: highlight)
  return highlight
}

// highlight-imageAnnotation-rectangle

// highlight-imageAnnotation-circle
@MainActor
func addCircleAnnotation(engine: Engine, page: DesignBlockID) throws -> DesignBlockID {
  let callout = try engine.block.create(.graphic)
  let ellipseShape = try engine.block.createShape(.ellipse)
  try engine.block.setShape(callout, shape: ellipseShape)

  try engine.block.setPositionX(callout, value: 360)
  try engine.block.setPositionY(callout, value: 155)
  try engine.block.setWidth(callout, value: 120)
  try engine.block.setHeight(callout, value: 120)

  try engine.block.setFillEnabled(callout, enabled: false)
  try engine.block.setStrokeEnabled(callout, enabled: true)
  try engine.block.setStrokeColor(callout, color: .rgba(r: 1.0, g: 0.0, b: 0.0, a: 1.0))
  try engine.block.setStrokeWidth(callout, width: 4)

  try engine.block.appendChild(to: page, child: callout)
  return callout
}

// highlight-imageAnnotation-circle

// highlight-imageAnnotation-line
@MainActor
func addLineAnnotation(engine: Engine, page: DesignBlockID) throws -> DesignBlockID {
  let underline = try engine.block.create(.graphic)
  let lineShape = try engine.block.createShape(.line)
  try engine.block.setShape(underline, shape: lineShape)

  try engine.block.setPositionX(underline, value: 85)
  try engine.block.setPositionY(underline, value: 430)
  try engine.block.setWidth(underline, value: 320)
  let lineThickness: Float = 8
  try engine.block.setHeight(underline, value: lineThickness)

  try engine.block.setStrokeEnabled(underline, enabled: true)
  try engine.block.setStrokeColor(underline, color: .rgba(r: 0.05, g: 0.25, b: 0.95, a: 1.0))
  try engine.block.setStrokeWidth(underline, width: lineThickness)

  try engine.block.appendChild(to: page, child: underline)
  return underline
}

// highlight-imageAnnotation-line

// highlight-imageAnnotation-redaction
@MainActor
func addRedactionBox(engine: Engine, page: DesignBlockID) throws -> DesignBlockID {
  let redaction = try engine.block.create(.graphic)
  try engine.block.setShape(redaction, shape: engine.block.createShape(.rect))

  try engine.block.setPositionX(redaction, value: 500)
  try engine.block.setPositionY(redaction, value: 360)
  try engine.block.setWidth(redaction, value: 180)
  try engine.block.setHeight(redaction, value: 34)

  let fill = try engine.block.createFill(.color)
  try engine.block.setColor(
    fill,
    property: "fill/color/value",
    color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0),
  )
  try engine.block.setFill(redaction, fill: fill)

  try engine.block.appendChild(to: page, child: redaction)
  return redaction
}

// highlight-imageAnnotation-redaction

// highlight-imageAnnotation-style
@MainActor
func styleRectangleAnnotationAppearance(engine: Engine, rectangle: DesignBlockID) throws {
  try engine.block.setOpacity(rectangle, value: 0.5)

  let shape = try engine.block.getShape(rectangle)
  try engine.block.setFloat(shape, property: "shape/rect/cornerRadiusTL", value: 10)
  try engine.block.setFloat(shape, property: "shape/rect/cornerRadiusTR", value: 10)
  try engine.block.setFloat(shape, property: "shape/rect/cornerRadiusBL", value: 10)
  try engine.block.setFloat(shape, property: "shape/rect/cornerRadiusBR", value: 10)

  try engine.block.setStrokeEnabled(rectangle, enabled: true)
  try engine.block.setStrokeStyle(rectangle, style: .dashed)
  try engine.block.setStrokeWidth(rectangle, width: 3)
  try engine.block.setStrokeColor(rectangle, color: .rgba(r: 0.9, g: 0.35, b: 0.0, a: 1.0))
}

// highlight-imageAnnotation-style
