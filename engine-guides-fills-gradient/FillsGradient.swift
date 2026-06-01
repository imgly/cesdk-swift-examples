import IMGLYEngine

@MainActor
func fillsGradient(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-fillsGradient-checkFillSupport
  guard try engine.block.supportsFill(page) else { return }
  // highlight-fillsGradient-checkFillSupport

  // Helper to create a renderable graphic block with a rect shape on the page.
  func createBlock(
    x: Float, y: Float,
    width: Float = 120, height: Float = 100,
  ) throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setWidth(block, value: width)
    try engine.block.setHeight(block, value: height)
    try engine.block.setPositionX(block, value: x)
    try engine.block.setPositionY(block, value: y)
    try engine.block.appendChild(to: page, child: block)
    return block
  }

  // =========================================================================
  // 1 - Linear Gradient (Vertical: gold to blue)
  // =========================================================================
  // highlight-fillsGradient-createLinear
  let linearFill = try engine.block.createFill(.linearGradient)
  // highlight-fillsGradient-createLinear

  // highlight-fillsGradient-linearGradient
  try engine.block.setGradientColorStops(
    linearFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 1.0, g: 0.8, b: 0.2), stop: 0),
      GradientColorStop(color: .rgba(r: 0.3, g: 0.4, b: 0.7), stop: 1),
    ],
  )
  // highlight-fillsGradient-linearGradient

  // highlight-fillsGradient-linearPosition
  try engine.block.setFloat(linearFill, property: "fill/gradient/linear/startPointX", value: 0.5)
  try engine.block.setFloat(linearFill, property: "fill/gradient/linear/startPointY", value: 0)
  try engine.block.setFloat(linearFill, property: "fill/gradient/linear/endPointX", value: 0.5)
  try engine.block.setFloat(linearFill, property: "fill/gradient/linear/endPointY", value: 1)
  // highlight-fillsGradient-linearPosition

  // highlight-fillsGradient-applyGradient
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let gradientFill = try engine.block.createFill(.linearGradient)
  try engine.block.setFill(block, fill: gradientFill)
  // highlight-fillsGradient-applyGradient
  try engine.block.destroy(block)

  let linearBlock = try createBlock(x: 20, y: 20)
  try engine.block.setFill(linearBlock, fill: linearFill)

  // =========================================================================
  // 2 - Linear Gradient (Horizontal: pink to teal)
  // =========================================================================
  let horizontalFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    horizontalFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.8, g: 0.2, b: 0.4), stop: 0),
      GradientColorStop(color: .rgba(r: 0.2, g: 0.8, b: 0.6), stop: 1),
    ],
  )
  // highlight-fillsGradient-horizontalDirection
  try engine.block.setFloat(horizontalFill, property: "fill/gradient/linear/startPointX", value: 0)
  try engine.block.setFloat(horizontalFill, property: "fill/gradient/linear/startPointY", value: 0.5)
  try engine.block.setFloat(horizontalFill, property: "fill/gradient/linear/endPointX", value: 1)
  try engine.block.setFloat(horizontalFill, property: "fill/gradient/linear/endPointY", value: 0.5)
  // highlight-fillsGradient-horizontalDirection

  let horizontalBlock = try createBlock(x: 160, y: 20)
  try engine.block.setFill(horizontalBlock, fill: horizontalFill)

  // =========================================================================
  // 3 - Linear Gradient (Diagonal: purple to orange)
  // =========================================================================
  let diagonalFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    diagonalFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.5, g: 0.2, b: 0.8), stop: 0),
      GradientColorStop(color: .rgba(r: 0.9, g: 0.6, b: 0.2), stop: 1),
    ],
  )
  // highlight-fillsGradient-diagonalDirection
  try engine.block.setFloat(diagonalFill, property: "fill/gradient/linear/startPointX", value: 0)
  try engine.block.setFloat(diagonalFill, property: "fill/gradient/linear/startPointY", value: 0)
  try engine.block.setFloat(diagonalFill, property: "fill/gradient/linear/endPointX", value: 1)
  try engine.block.setFloat(diagonalFill, property: "fill/gradient/linear/endPointY", value: 1)
  // highlight-fillsGradient-diagonalDirection

  let diagonalBlock = try createBlock(x: 300, y: 20)
  try engine.block.setFill(diagonalBlock, fill: diagonalFill)

  // =========================================================================
  // 4 - Aurora Multi-Stop Linear Gradient (purple -> pink -> orange -> gold)
  // =========================================================================
  // highlight-fillsGradient-auroraGradient
  let auroraFill = try engine.block.createFill(.linearGradient)

  // highlight-fillsGradient-colorStops
  try engine.block.setGradientColorStops(
    auroraFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.4, g: 0.1, b: 0.8), stop: 0),
      GradientColorStop(color: .rgba(r: 0.8, g: 0.2, b: 0.6), stop: 0.3),
      GradientColorStop(color: .rgba(r: 1.0, g: 0.5, b: 0.3), stop: 0.6),
      GradientColorStop(color: .rgba(r: 1.0, g: 0.8, b: 0.2), stop: 1),
    ],
  )
  // highlight-fillsGradient-colorStops

  try engine.block.setFloat(auroraFill, property: "fill/gradient/linear/startPointX", value: 0)
  try engine.block.setFloat(auroraFill, property: "fill/gradient/linear/startPointY", value: 0.5)
  try engine.block.setFloat(auroraFill, property: "fill/gradient/linear/endPointX", value: 1)
  try engine.block.setFloat(auroraFill, property: "fill/gradient/linear/endPointY", value: 0.5)
  // highlight-fillsGradient-auroraGradient

  let auroraBlock = try createBlock(x: 440, y: 20)
  try engine.block.setFill(auroraBlock, fill: auroraFill)

  // =========================================================================
  // 5 - Radial Gradient (Centered: white translucent to blue)
  // =========================================================================
  // highlight-fillsGradient-createRadial
  let radialFill = try engine.block.createFill(.radialGradient)
  // highlight-fillsGradient-createRadial

  // highlight-fillsGradient-radialGradient
  try engine.block.setGradientColorStops(
    radialFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 1.0, g: 1.0, b: 1.0, a: 0.3), stop: 0),
      GradientColorStop(color: .rgba(r: 0.2, g: 0.4, b: 0.8), stop: 1),
    ],
  )
  // highlight-fillsGradient-radialGradient

  // highlight-fillsGradient-radialPosition
  try engine.block.setFloat(radialFill, property: "fill/gradient/radial/centerPointX", value: 0.5)
  try engine.block.setFloat(radialFill, property: "fill/gradient/radial/centerPointY", value: 0.5)
  try engine.block.setFloat(radialFill, property: "fill/gradient/radial/radius", value: 0.8)
  // highlight-fillsGradient-radialPosition

  let radialBlock = try createBlock(x: 580, y: 20)
  try engine.block.setFill(radialBlock, fill: radialFill)

  // =========================================================================
  // 6 - Radial Gradient (Top-Left Highlight / Button Effect)
  // =========================================================================
  // highlight-fillsGradient-buttonGradient
  let buttonFill = try engine.block.createFill(.radialGradient)
  try engine.block.setGradientColorStops(
    buttonFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 1.0, g: 1.0, b: 1.0, a: 0.3), stop: 0),
      GradientColorStop(color: .rgba(r: 0.2, g: 0.4, b: 0.8), stop: 1),
    ],
  )
  // highlight-fillsGradient-buttonGradient

  // highlight-fillsGradient-centeredCircle
  try engine.block.setFloat(radialFill, property: "fill/gradient/radial/centerPointX", value: 0.5)
  try engine.block.setFloat(radialFill, property: "fill/gradient/radial/centerPointY", value: 0.5)
  try engine.block.setFloat(radialFill, property: "fill/gradient/radial/radius", value: 0.7)
  // highlight-fillsGradient-centeredCircle

  // highlight-fillsGradient-topLeftHighlight
  try engine.block.setFloat(buttonFill, property: "fill/gradient/radial/centerPointX", value: 0)
  try engine.block.setFloat(buttonFill, property: "fill/gradient/radial/centerPointY", value: 0)
  try engine.block.setFloat(buttonFill, property: "fill/gradient/radial/radius", value: 1.0)
  // highlight-fillsGradient-topLeftHighlight

  let buttonBlock = try createBlock(x: 20, y: 140)
  try engine.block.setFill(buttonBlock, fill: buttonFill)

  // =========================================================================
  // 7 - Radial Gradient (Vignette: light center to dark edge)
  // =========================================================================
  let vignetteFill = try engine.block.createFill(.radialGradient)
  try engine.block.setGradientColorStops(
    vignetteFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.9, g: 0.9, b: 0.9), stop: 0),
      GradientColorStop(color: .rgba(r: 0.1, g: 0.1, b: 0.1), stop: 1),
    ],
  )
  // highlight-fillsGradient-bottomRightVignette
  try engine.block.setFloat(vignetteFill, property: "fill/gradient/radial/centerPointX", value: 1)
  try engine.block.setFloat(vignetteFill, property: "fill/gradient/radial/centerPointY", value: 1)
  try engine.block.setFloat(vignetteFill, property: "fill/gradient/radial/radius", value: 1.5)
  // highlight-fillsGradient-bottomRightVignette

  let vignetteBlock = try createBlock(x: 160, y: 140)
  try engine.block.setFill(vignetteBlock, fill: vignetteFill)

  // =========================================================================
  // 8 - Conical Gradient (Color Wheel: red -> yellow -> green -> blue -> red)
  // =========================================================================
  // highlight-fillsGradient-createConical
  let conicalFill = try engine.block.createFill(.conicalGradient)
  // highlight-fillsGradient-createConical

  // highlight-fillsGradient-conicalGradient
  try engine.block.setGradientColorStops(
    conicalFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 1.0, g: 0.0, b: 0.0), stop: 0),
      GradientColorStop(color: .rgba(r: 1.0, g: 1.0, b: 0.0), stop: 0.25),
      GradientColorStop(color: .rgba(r: 0.0, g: 1.0, b: 0.0), stop: 0.5),
      GradientColorStop(color: .rgba(r: 0.0, g: 0.0, b: 1.0), stop: 0.75),
      GradientColorStop(color: .rgba(r: 1.0, g: 0.0, b: 0.0), stop: 1),
    ],
  )
  // highlight-fillsGradient-conicalGradient

  // highlight-fillsGradient-conicalPosition
  try engine.block.setFloat(conicalFill, property: "fill/gradient/conical/centerPointX", value: 0.5)
  try engine.block.setFloat(conicalFill, property: "fill/gradient/conical/centerPointY", value: 0.5)
  // highlight-fillsGradient-conicalPosition

  let conicalBlock = try createBlock(x: 300, y: 140)
  try engine.block.setFill(conicalBlock, fill: conicalFill)

  // =========================================================================
  // 9 - Conical Gradient (Spinner: blue -> transparent -> blue)
  // =========================================================================
  // highlight-fillsGradient-spinnerGradient
  let spinnerFill = try engine.block.createFill(.conicalGradient)
  try engine.block.setGradientColorStops(
    spinnerFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.2, g: 0.4, b: 0.8), stop: 0),
      GradientColorStop(color: .rgba(r: 0.2, g: 0.4, b: 0.8, a: 0), stop: 0.75),
      GradientColorStop(color: .rgba(r: 0.2, g: 0.4, b: 0.8), stop: 1),
    ],
  )
  try engine.block.setFloat(spinnerFill, property: "fill/gradient/conical/centerPointX", value: 0.5)
  try engine.block.setFloat(spinnerFill, property: "fill/gradient/conical/centerPointY", value: 0.5)
  // highlight-fillsGradient-spinnerGradient

  let spinnerBlock = try createBlock(x: 440, y: 140)
  try engine.block.setFill(spinnerBlock, fill: spinnerFill)

  // =========================================================================
  // 10 - CMYK Gradient (magenta-yellow to cyan-yellow)
  // =========================================================================
  let cmykFill = try engine.block.createFill(.linearGradient)
  // highlight-fillsGradient-colorSpaces
  try engine.block.setGradientColorStops(
    cmykFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .cmyk(c: 0.0, m: 1.0, y: 1.0, k: 0.0), stop: 0),
      GradientColorStop(color: .cmyk(c: 1.0, m: 0.0, y: 1.0, k: 0.0), stop: 1),
    ],
  )

  engine.editor.setSpotColor(name: "BrandPrimary", r: 0.2, g: 0.4, b: 0.8)
  try engine.block.setGradientColorStops(
    cmykFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .spot(name: "BrandPrimary"), stop: 0),
      GradientColorStop(color: .rgba(r: 1.0, g: 1.0, b: 1.0), stop: 1),
    ],
  )
  // highlight-fillsGradient-colorSpaces
  try engine.block.setFloat(cmykFill, property: "fill/gradient/linear/startPointX", value: 0)
  try engine.block.setFloat(cmykFill, property: "fill/gradient/linear/startPointY", value: 0.5)
  try engine.block.setFloat(cmykFill, property: "fill/gradient/linear/endPointX", value: 1)
  try engine.block.setFloat(cmykFill, property: "fill/gradient/linear/endPointY", value: 0.5)

  let cmykBlock = try createBlock(x: 580, y: 140)
  try engine.block.setFill(cmykBlock, fill: cmykFill)

  // 11 - Spot Color Gradient (BrandPrimary to BrandSecondary)
  engine.editor.setSpotColor(name: "BrandSecondary", r: 1.0, g: 0.6, b: 0.0)

  let spotFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    spotFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .spot(name: "BrandPrimary"), stop: 0),
      GradientColorStop(color: .spot(name: "BrandSecondary"), stop: 1),
    ],
  )
  try engine.block.setFloat(spotFill, property: "fill/gradient/linear/startPointX", value: 0)
  try engine.block.setFloat(spotFill, property: "fill/gradient/linear/startPointY", value: 0)
  try engine.block.setFloat(spotFill, property: "fill/gradient/linear/endPointX", value: 1)
  try engine.block.setFloat(spotFill, property: "fill/gradient/linear/endPointY", value: 1)

  let spotBlock = try createBlock(x: 20, y: 260)
  try engine.block.setFill(spotBlock, fill: spotFill)

  // =========================================================================
  // 12 - Transparency Overlay (transparent to black 70%)
  // =========================================================================
  // highlight-fillsGradient-overlayGradient
  let overlayFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    overlayFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 0), stop: 0),
      GradientColorStop(color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 0.7), stop: 1),
    ],
  )
  try engine.block.setFloat(overlayFill, property: "fill/gradient/linear/startPointX", value: 0.5)
  try engine.block.setFloat(overlayFill, property: "fill/gradient/linear/startPointY", value: 0)
  try engine.block.setFloat(overlayFill, property: "fill/gradient/linear/endPointX", value: 0.5)
  try engine.block.setFloat(overlayFill, property: "fill/gradient/linear/endPointY", value: 1)
  // highlight-fillsGradient-overlayGradient

  let overlayBlock = try createBlock(x: 160, y: 260)
  try engine.block.setFill(overlayBlock, fill: overlayFill)

  // =========================================================================
  // 13 - Duotone (purple to teal)
  // =========================================================================
  // highlight-fillsGradient-duotoneGradient
  let duotoneFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    duotoneFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.8, g: 0.2, b: 0.9), stop: 0),
      GradientColorStop(color: .rgba(r: 0.2, g: 0.9, b: 0.8), stop: 1),
    ],
  )
  try engine.block.setFloat(duotoneFill, property: "fill/gradient/linear/startPointX", value: 0)
  try engine.block.setFloat(duotoneFill, property: "fill/gradient/linear/startPointY", value: 0)
  try engine.block.setFloat(duotoneFill, property: "fill/gradient/linear/endPointX", value: 1)
  try engine.block.setFloat(duotoneFill, property: "fill/gradient/linear/endPointY", value: 1)
  // highlight-fillsGradient-duotoneGradient

  let duotoneBlock = try createBlock(x: 300, y: 260)
  try engine.block.setFill(duotoneBlock, fill: duotoneFill)

  // =========================================================================
  // 14 - Shared Gradient (red to blue applied to 2 blocks, then updated)
  // =========================================================================
  // highlight-fillsGradient-shareGradient
  let sharedBlock1 = try createBlock(x: 440, y: 260, width: 120, height: 45)
  let sharedBlock2 = try createBlock(x: 440, y: 315, width: 120, height: 45)

  let sharedGradient = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    sharedGradient,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 1, g: 0, b: 0), stop: 0),
      GradientColorStop(color: .rgba(r: 0, g: 0, b: 1), stop: 1),
    ],
  )
  try engine.block.setFloat(sharedGradient, property: "fill/gradient/linear/startPointX", value: 0)
  try engine.block.setFloat(sharedGradient, property: "fill/gradient/linear/startPointY", value: 0.5)
  try engine.block.setFloat(sharedGradient, property: "fill/gradient/linear/endPointX", value: 1)
  try engine.block.setFloat(sharedGradient, property: "fill/gradient/linear/endPointY", value: 0.5)

  try engine.block.setFill(sharedBlock1, fill: sharedGradient)
  try engine.block.setFill(sharedBlock2, fill: sharedGradient)

  try engine.block.setGradientColorStops(
    sharedGradient,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0, g: 1, b: 0), stop: 0),
      GradientColorStop(color: .rgba(r: 1, g: 1, b: 0), stop: 1),
    ],
  )
  // highlight-fillsGradient-shareGradient

  // =========================================================================
  // 15 - Inspect Gradient (get-fill and get-color-stops demos)
  // =========================================================================
  let inspectBlock = try createBlock(x: 580, y: 260)
  let inspectFill = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    inspectFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 0.6, g: 0.3, b: 0.7), stop: 0),
      GradientColorStop(color: .rgba(r: 0.3, g: 0.7, b: 0.6), stop: 1),
    ],
  )
  try engine.block.setFill(inspectBlock, fill: inspectFill)

  // highlight-fillsGradient-getFill
  let currentFill = try engine.block.getFill(inspectBlock)
  let fillType = try engine.block.getType(currentFill)
  print("Fill type:", fillType)
  // highlight-fillsGradient-getFill

  // highlight-fillsGradient-getColorStops
  let colorStops = try engine.block.getGradientColorStops(
    inspectFill,
    property: "fill/gradient/colors",
  )
  print("Color stops:", colorStops)
  // highlight-fillsGradient-getColorStops

  // highlight-fillsGradient-getLinearPosition
  let startX = try engine.block.getFloat(inspectFill, property: "fill/gradient/linear/startPointX")
  let startY = try engine.block.getFloat(inspectFill, property: "fill/gradient/linear/startPointY")
  let endX = try engine.block.getFloat(inspectFill, property: "fill/gradient/linear/endPointX")
  let endY = try engine.block.getFloat(inspectFill, property: "fill/gradient/linear/endPointY")
  print("Linear gradient position:", startX, startY, endX, endY)
  // highlight-fillsGradient-getLinearPosition

  try await engine.captureGuide(page, label: "hero")
}
