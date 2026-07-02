import IMGLYEngine

@MainActor
func createShapes(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL

  // highlight-createShapes-checkSupport
  let probeBlock = try engine.block.create(.graphic)
  print("Graphic supports shape:", try engine.block.supportsShape(probeBlock)) // true

  let text = try engine.block.create(.text)
  print("Text supports shape:", try engine.block.supportsShape(text)) // false
  // highlight-createShapes-checkSupport
  try engine.block.destroy(probeBlock)
  try engine.block.destroy(text)

  // highlight-createShapes-createRectangle
  let rectangleBlock = try engine.block.create(.graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(rectangleBlock, shape: rectShape)

  let colorFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    colorFill,
    property: "fill/color/value",
    color: .rgba(r: 0.85, g: 0.25, b: 0.25),
  )
  try engine.block.setFill(rectangleBlock, fill: colorFill)

  try engine.block.setWidth(rectangleBlock, value: 320)
  try engine.block.setHeight(rectangleBlock, value: 220)
  try engine.block.setPositionX(rectangleBlock, value: 40)
  try engine.block.setPositionY(rectangleBlock, value: 40)
  try engine.block.appendChild(to: page, child: rectangleBlock)
  // highlight-createShapes-createRectangle

  // highlight-createShapes-createEllipse
  let ellipseBlock = try engine.block.create(.graphic)
  let ellipseShape = try engine.block.createShape(.ellipse)
  try engine.block.setShape(ellipseBlock, shape: ellipseShape)

  let gradientFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    gradientFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.2, g: 0.6, b: 0.95), stop: 0),
      GradientColorStop(color: .rgba(r: 0.1, g: 0.2, b: 0.6), stop: 1),
    ],
  )
  try engine.block.setFill(ellipseBlock, fill: gradientFill)
  // highlight-createShapes-createEllipse
  try engine.block.setWidth(ellipseBlock, value: 320)
  try engine.block.setHeight(ellipseBlock, value: 220)
  try engine.block.setPositionX(ellipseBlock, value: 440)
  try engine.block.setPositionY(ellipseBlock, value: 40)
  try engine.block.appendChild(to: page, child: ellipseBlock)

  // highlight-createShapes-createStar
  let starBlock = try engine.block.create(.graphic)
  let starShape = try engine.block.createShape(.star)
  try engine.block.setShape(starBlock, shape: starShape)

  try engine.block.setInt(starShape, property: "shape/star/points", value: 6)
  try engine.block.setFloat(starShape, property: "shape/star/innerDiameter", value: 0.5)

  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    starFill,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.75, b: 0.2),
  )
  try engine.block.setFill(starBlock, fill: starFill)
  // highlight-createShapes-createStar
  try engine.block.setWidth(starBlock, value: 220)
  try engine.block.setHeight(starBlock, value: 220)
  try engine.block.setPositionX(starBlock, value: 40)
  try engine.block.setPositionY(starBlock, value: 320)
  try engine.block.appendChild(to: page, child: starBlock)

  // highlight-createShapes-createPolygon
  let polygonBlock = try engine.block.create(.graphic)
  let polygonShape = try engine.block.createShape(.polygon)
  try engine.block.setShape(polygonBlock, shape: polygonShape)

  try engine.block.setInt(polygonShape, property: "shape/polygon/sides", value: 6)

  let polygonFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    polygonFill,
    property: "fill/color/value",
    color: .rgba(r: 0.3, g: 0.75, b: 0.4),
  )
  try engine.block.setFill(polygonBlock, fill: polygonFill)
  // highlight-createShapes-createPolygon
  try engine.block.setWidth(polygonBlock, value: 220)
  try engine.block.setHeight(polygonBlock, value: 220)
  try engine.block.setPositionX(polygonBlock, value: 290)
  try engine.block.setPositionY(polygonBlock, value: 320)
  try engine.block.appendChild(to: page, child: polygonBlock)

  // highlight-createShapes-createLine
  let lineBlock = try engine.block.create(.graphic)
  let lineShape = try engine.block.createShape(.line)
  try engine.block.setShape(lineBlock, shape: lineShape)

  let lineFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    lineFill,
    property: "fill/color/value",
    color: .rgba(r: 0.2, g: 0.2, b: 0.2),
  )
  try engine.block.setFill(lineBlock, fill: lineFill)
  // highlight-createShapes-createLine
  try engine.block.setWidth(lineBlock, value: 220)
  try engine.block.setHeight(lineBlock, value: 8)
  try engine.block.setPositionX(lineBlock, value: 540)
  try engine.block.setPositionY(lineBlock, value: 360)
  try engine.block.appendChild(to: page, child: lineBlock)

  // highlight-createShapes-createVectorPath
  let arrowBlock = try engine.block.create(.graphic)
  let arrowShape = try engine.block.createShape(.vectorPath)
  try engine.block.setString(
    arrowShape,
    property: "shape/vector_path/path",
    value: "M 0,40 L 60,40 L 60,20 L 100,50 L 60,80 L 60,60 L 0,60 Z",
  )
  try engine.block.setShape(arrowBlock, shape: arrowShape)

  let arrowFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    arrowFill,
    property: "fill/color/value",
    color: .rgba(r: 0.55, g: 0.3, b: 0.75),
  )
  try engine.block.setFill(arrowBlock, fill: arrowFill)
  // highlight-createShapes-createVectorPath
  try engine.block.setWidth(arrowBlock, value: 220)
  try engine.block.setHeight(arrowBlock, value: 120)
  try engine.block.setPositionX(arrowBlock, value: 540)
  try engine.block.setPositionY(arrowBlock, value: 420)
  try engine.block.appendChild(to: page, child: arrowBlock)

  try await engine.captureGuide(page, label: "hero")

  // highlight-createShapes-discoverProperties
  let starProperties = try engine.block.findAllProperties(starShape)
  print("Star properties:", starProperties)
  // highlight-createShapes-discoverProperties

  // highlight-createShapes-cornerRadius
  try engine.block.setFloat(rectShape, property: "shape/rect/cornerRadiusTL", value: 20)
  try engine.block.setFloat(rectShape, property: "shape/rect/cornerRadiusTR", value: 20)
  try engine.block.setFloat(rectShape, property: "shape/rect/cornerRadiusBL", value: 20)
  try engine.block.setFloat(rectShape, property: "shape/rect/cornerRadiusBR", value: 20)
  // highlight-createShapes-cornerRadius

  // highlight-createShapes-imageFill
  let imageBlock = try engine.block.create(.graphic)
  let imageRect = try engine.block.createShape(.rect)
  try engine.block.setShape(imageBlock, shape: imageRect)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(imageBlock, fill: imageFill)
  // highlight-createShapes-imageFill
  try engine.block.destroy(imageBlock)

  // highlight-createShapes-retrieveShape
  let currentShape = try engine.block.getShape(rectangleBlock)
  let currentShapeType = try engine.block.getType(currentShape)
  print("Current shape type:", currentShapeType)
  // highlight-createShapes-retrieveShape

  // highlight-createShapes-replaceShape
  let swapBlock = try engine.block.create(.graphic)
  let oldShape = try engine.block.createShape(.rect)
  try engine.block.setShape(swapBlock, shape: oldShape)

  let newShape = try engine.block.createShape(.ellipse)
  try engine.block.destroy(try engine.block.getShape(swapBlock))
  try engine.block.setShape(swapBlock, shape: newShape)
  // highlight-createShapes-replaceShape
  try engine.block.destroy(swapBlock)

  // highlight-createShapes-independence
  let independentBlock = try engine.block.create(.graphic)
  let initialShape = try engine.block.createShape(.star)
  try engine.block.setShape(independentBlock, shape: initialShape)

  let initialFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    initialFill,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.0, b: 0.0),
  )
  try engine.block.setFill(independentBlock, fill: initialFill)

  // Swap the shape, keep the same fill.
  let replacementShape = try engine.block.createShape(.rect)
  try engine.block.destroy(try engine.block.getShape(independentBlock))
  try engine.block.setShape(independentBlock, shape: replacementShape)

  // Swap the fill, keep the rectangular shape.
  let replacementFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    replacementFill,
    property: "fill/color/value",
    color: .rgba(r: 0.0, g: 0.0, b: 1.0),
  )
  try engine.block.destroy(try engine.block.getFill(independentBlock))
  try engine.block.setFill(independentBlock, fill: replacementFill)
  // highlight-createShapes-independence
  try engine.block.destroy(independentBlock)
}
