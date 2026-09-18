import IMGLYEngine

@MainActor
func fillsColor(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-fillsColor-checkFillSupport
  guard try engine.block.supportsFill(page) else { return }
  // highlight-fillsColor-checkFillSupport

  // highlight-fillsColor-createFill
  let colorFill = try engine.block.createFill(.color)
  // highlight-fillsColor-createFill

  // highlight-fillsColor-defaultProperties
  let allFillProperties = try engine.block.findAllProperties(colorFill)
  print("Fill properties:", allFillProperties)
  // highlight-fillsColor-defaultProperties

  // highlight-fillsColor-applyFill
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block, value: 200)
  try engine.block.setHeight(block, value: 150)
  try engine.block.setPositionX(block, value: 50)
  try engine.block.setPositionY(block, value: 50)
  try engine.block.appendChild(to: page, child: block)

  try engine.block.setFill(block, fill: colorFill)
  // highlight-fillsColor-applyFill

  // highlight-fillsColor-setRgb
  try engine.block.setColor(
    colorFill,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.0, b: 0.0),
  )
  // highlight-fillsColor-setRgb

  // highlight-fillsColor-getFill
  let currentFill = try engine.block.getFill(block)
  let fillType = try engine.block.getType(currentFill)
  print("Fill type:", fillType)
  // highlight-fillsColor-getFill

  // highlight-fillsColor-getColor
  let currentColor: Color = try engine.block.getColor(colorFill, property: "fill/color/value")
  print("Current color:", currentColor)
  // highlight-fillsColor-getColor

  // highlight-fillsColor-setCmyk
  let cmykBlock = try engine.block.create(.graphic)
  try engine.block.setShape(cmykBlock, shape: engine.block.createShape(.ellipse))
  try engine.block.setWidth(cmykBlock, value: 150)
  try engine.block.setHeight(cmykBlock, value: 150)
  try engine.block.setPositionX(cmykBlock, value: 300)
  try engine.block.setPositionY(cmykBlock, value: 50)
  try engine.block.appendChild(to: page, child: cmykBlock)

  let cmykFill = try engine.block.createFill(.color)
  try engine.block.setFill(cmykBlock, fill: cmykFill)
  try engine.block.setColor(
    cmykFill,
    property: "fill/color/value",
    color: .cmyk(c: 0.0, m: 1.0, y: 0.0, k: 0.0),
  )
  // highlight-fillsColor-setCmyk

  // highlight-fillsColor-setSpot
  engine.editor.setSpotColor(name: "BrandRed", r: 0.9, g: 0.1, b: 0.1)

  let spotBlock = try engine.block.create(.graphic)
  try engine.block.setShape(spotBlock, shape: engine.block.createShape(.ellipse))
  try engine.block.setWidth(spotBlock, value: 150)
  try engine.block.setHeight(spotBlock, value: 150)
  try engine.block.setPositionX(spotBlock, value: 500)
  try engine.block.setPositionY(spotBlock, value: 50)
  try engine.block.appendChild(to: page, child: spotBlock)

  let spotFill = try engine.block.createFill(.color)
  try engine.block.setFill(spotBlock, fill: spotFill)
  try engine.block.setColor(
    spotFill,
    property: "fill/color/value",
    color: .spot(name: "BrandRed", externalReference: "Brand-Colors"),
  )
  // highlight-fillsColor-setSpot

  // highlight-fillsColor-toggleFill
  let toggleBlock = try engine.block.create(.graphic)
  try engine.block.setShape(toggleBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(toggleBlock, value: 150)
  try engine.block.setHeight(toggleBlock, value: 100)
  try engine.block.setPositionX(toggleBlock, value: 50)
  try engine.block.setPositionY(toggleBlock, value: 250)
  try engine.block.appendChild(to: page, child: toggleBlock)

  let toggleFill = try engine.block.createFill(.color)
  try engine.block.setFill(toggleBlock, fill: toggleFill)
  try engine.block.setColor(
    toggleFill,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.5, b: 0.0),
  )

  let isEnabled = try engine.block.isFillEnabled(toggleBlock)
  print("Fill enabled:", isEnabled)

  try engine.block.setFillEnabled(toggleBlock, enabled: false)
  try engine.block.setFillEnabled(toggleBlock, enabled: true)
  // highlight-fillsColor-toggleFill

  // highlight-fillsColor-shareFill
  let block1 = try engine.block.create(.graphic)
  try engine.block.setShape(block1, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block1, value: 100)
  try engine.block.setHeight(block1, value: 100)
  try engine.block.setPositionX(block1, value: 250)
  try engine.block.setPositionY(block1, value: 250)
  try engine.block.appendChild(to: page, child: block1)

  let block2 = try engine.block.create(.graphic)
  try engine.block.setShape(block2, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block2, value: 100)
  try engine.block.setHeight(block2, value: 100)
  try engine.block.setPositionX(block2, value: 370)
  try engine.block.setPositionY(block2, value: 250)
  try engine.block.appendChild(to: page, child: block2)

  let sharedFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    sharedFill,
    property: "fill/color/value",
    color: .rgba(r: 0.5, g: 0.0, b: 0.5),
  )

  try engine.block.setFill(block1, fill: sharedFill)
  try engine.block.setFill(block2, fill: sharedFill)

  try engine.block.setColor(
    sharedFill,
    property: "fill/color/value",
    color: .rgba(r: 0.0, g: 0.5, b: 0.5),
  )
  // highlight-fillsColor-shareFill

  // highlight-fillsColor-convertColor
  let rgbColor = Color.rgba(r: 1.0, g: 0.0, b: 0.0)
  let cmykColor = try engine.editor.convertColorToColorSpace(color: rgbColor, colorSpace: .cmyk)
  print("Converted CMYK color:", cmykColor)
  // highlight-fillsColor-convertColor

  // highlight-fillsColor-brandColors
  engine.editor.setSpotColor(name: "PrimaryBrand", r: 0.2, g: 0.4, b: 0.8)
  engine.editor.setSpotColor(name: "SecondaryBrand", r: 0.9, g: 0.5, b: 0.1)

  let brandBlock = try engine.block.create(.graphic)
  try engine.block.setShape(brandBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(brandBlock, value: 150)
  try engine.block.setHeight(brandBlock, value: 100)
  try engine.block.setPositionX(brandBlock, value: 500)
  try engine.block.setPositionY(brandBlock, value: 250)
  try engine.block.appendChild(to: page, child: brandBlock)

  let brandFill = try engine.block.createFill(.color)
  try engine.block.setFill(brandBlock, fill: brandFill)
  try engine.block.setColor(
    brandFill,
    property: "fill/color/value",
    color: .spot(name: "PrimaryBrand"),
  )
  // highlight-fillsColor-brandColors

  // highlight-fillsColor-transparency
  let transparentBlock = try engine.block.create(.graphic)
  try engine.block.setShape(transparentBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(transparentBlock, value: 150)
  try engine.block.setHeight(transparentBlock, value: 100)
  try engine.block.setPositionX(transparentBlock, value: 50)
  try engine.block.setPositionY(transparentBlock, value: 400)
  try engine.block.appendChild(to: page, child: transparentBlock)

  let transparentFill = try engine.block.createFill(.color)
  try engine.block.setFill(transparentBlock, fill: transparentFill)
  try engine.block.setColor(
    transparentFill,
    property: "fill/color/value",
    color: .rgba(r: 0.0, g: 0.8, b: 0.2, a: 0.5),
  )
  // highlight-fillsColor-transparency

  // highlight-fillsColor-printColors
  let printBlock = try engine.block.create(.graphic)
  try engine.block.setShape(printBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(printBlock, value: 150)
  try engine.block.setHeight(printBlock, value: 100)
  try engine.block.setPositionX(printBlock, value: 250)
  try engine.block.setPositionY(printBlock, value: 400)
  try engine.block.appendChild(to: page, child: printBlock)

  let printFill = try engine.block.createFill(.color)
  try engine.block.setFill(printBlock, fill: printFill)
  try engine.block.setColor(
    printFill,
    property: "fill/color/value",
    color: .cmyk(c: 0.0, m: 0.85, y: 1.0, k: 0.0),
  )
  // highlight-fillsColor-printColors

  try await engine.captureGuide(page, label: "hero")
}
