import Foundation
import IMGLYEngine

@MainActor
func insertMediaShapesOrStickers(engine: Engine) async throws {
  // Demo scaffolding: a scene with an 800x600 page that hosts the demo grid.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // Demo scaffolding: shared block dimensions for the 3x3 grid the hero shows.
  let blockWidth: Float = 160
  let blockHeight: Float = 140

  // Demo scaffolding: resolve sample assets against the bundled asset base URL
  // and point `basePath` at it so the sticker source's relative references load.
  let baseURL = try engine.guidesBaseURL
  try engine.editor.setSettingString("basePath", value: baseURL.absoluteString)

  // highlight-checkShapeSupport
  // Graphic blocks support shapes.
  let testBlock = try engine.block.create(.graphic)
  let supportsShape = try engine.block.supportsShape(testBlock)
  print("Graphic block supports shapes: \(supportsShape)")

  // Text blocks do not.
  let textBlock = try engine.block.create(.text)
  let textSupportsShape = try engine.block.supportsShape(textBlock)
  print("Text block supports shapes: \(textSupportsShape)")
  try engine.block.destroy(textBlock)
  try engine.block.destroy(testBlock)
  // highlight-checkShapeSupport

  // highlight-createRectangle
  // Create a graphic block, attach a rect shape, then apply a solid color fill.
  let rectBlock = try engine.block.create(.graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(rectBlock, shape: rectShape)

  let rectFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    rectFill,
    property: "fill/color/value",
    color: .rgba(r: 0.2, g: 0.5, b: 0.9, a: 1.0),
  )
  try engine.block.setFill(rectBlock, fill: rectFill)

  try engine.block.setWidth(rectBlock, value: blockWidth)
  try engine.block.setHeight(rectBlock, value: blockHeight)
  try engine.block.appendChild(to: page, child: rectBlock)
  // highlight-createRectangle

  // highlight-createRoundedRectangle
  // A rounded rectangle is a rect shape with non-zero corner radii.
  let roundedBlock = try engine.block.create(.graphic)
  let roundedShape = try engine.block.createShape(.rect)
  try engine.block.setShape(roundedBlock, shape: roundedShape)

  try engine.block.setFloat(roundedShape, property: "shape/rect/cornerRadiusTL", value: 20)
  try engine.block.setFloat(roundedShape, property: "shape/rect/cornerRadiusTR", value: 20)
  try engine.block.setFloat(roundedShape, property: "shape/rect/cornerRadiusBL", value: 20)
  try engine.block.setFloat(roundedShape, property: "shape/rect/cornerRadiusBR", value: 20)

  let roundedFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    roundedFill,
    property: "fill/color/value",
    color: .rgba(r: 0.9, g: 0.4, b: 0.2, a: 1.0),
  )
  try engine.block.setFill(roundedBlock, fill: roundedFill)

  try engine.block.setWidth(roundedBlock, value: blockWidth)
  try engine.block.setHeight(roundedBlock, value: blockHeight)
  try engine.block.appendChild(to: page, child: roundedBlock)
  // highlight-createRoundedRectangle

  // highlight-createEllipse
  // An ellipse with equal width and height renders as a circle.
  let ellipseBlock = try engine.block.create(.graphic)
  let ellipseShape = try engine.block.createShape(.ellipse)
  try engine.block.setShape(ellipseBlock, shape: ellipseShape)

  let ellipseFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    ellipseFill,
    property: "fill/color/value",
    color: .rgba(r: 0.3, g: 0.8, b: 0.4, a: 1.0),
  )
  try engine.block.setFill(ellipseBlock, fill: ellipseFill)

  try engine.block.setWidth(ellipseBlock, value: blockWidth)
  try engine.block.setHeight(ellipseBlock, value: blockHeight)
  try engine.block.appendChild(to: page, child: ellipseBlock)
  // highlight-createEllipse

  // highlight-createStar
  // A 5-point star. `shape/star/innerDiameter` is normalized 0.0–1.0.
  let starBlock = try engine.block.create(.graphic)
  let starShape = try engine.block.createShape(.star)
  try engine.block.setShape(starBlock, shape: starShape)

  try engine.block.setInt(starShape, property: "shape/star/points", value: 5)
  try engine.block.setFloat(starShape, property: "shape/star/innerDiameter", value: 0.4)

  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    starFill,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.8, b: 0.0, a: 1.0),
  )
  try engine.block.setFill(starBlock, fill: starFill)

  try engine.block.setWidth(starBlock, value: blockWidth)
  try engine.block.setHeight(starBlock, value: blockHeight)
  try engine.block.appendChild(to: page, child: starBlock)
  // highlight-createStar

  // highlight-createPolygon
  // A regular hexagon: 6 sides.
  let polygonBlock = try engine.block.create(.graphic)
  let polygonShape = try engine.block.createShape(.polygon)
  try engine.block.setShape(polygonBlock, shape: polygonShape)

  try engine.block.setInt(polygonShape, property: "shape/polygon/sides", value: 6)

  let polygonFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    polygonFill,
    property: "fill/color/value",
    color: .rgba(r: 0.6, g: 0.2, b: 0.8, a: 1.0),
  )
  try engine.block.setFill(polygonBlock, fill: polygonFill)

  try engine.block.setWidth(polygonBlock, value: blockWidth)
  try engine.block.setHeight(polygonBlock, value: blockHeight)
  try engine.block.appendChild(to: page, child: polygonBlock)
  // highlight-createPolygon

  // highlight-createLine
  // Attaching a line shape promotes the parent's fill into its stroke
  // automatically — `setStrokeEnabled(true)` here is explicit.
  let lineBlock = try engine.block.create(.graphic)
  let lineShape = try engine.block.createShape(.line)
  try engine.block.setShape(lineBlock, shape: lineShape)

  try engine.block.setStrokeEnabled(lineBlock, enabled: true)
  try engine.block.setStrokeWidth(lineBlock, width: 6)
  try engine.block.setStrokeColor(
    lineBlock,
    color: .rgba(r: 0.9, g: 0.2, b: 0.5, a: 1.0),
  )

  try engine.block.setWidth(lineBlock, value: blockWidth)
  try engine.block.setHeight(lineBlock, value: 6)
  try engine.block.appendChild(to: page, child: lineBlock)
  // highlight-createLine

  // highlight-createVectorPath
  // Custom shapes are defined by an SVG path. Coordinates scale with the block.
  let vectorPathBlock = try engine.block.create(.graphic)
  let vectorPathShape = try engine.block.createShape(.vectorPath)
  try engine.block.setShape(vectorPathBlock, shape: vectorPathShape)

  let trianglePath = "M 50,0 L 100,100 L 0,100 Z"
  try engine.block.setString(
    vectorPathShape,
    property: "shape/vector_path/path",
    value: trianglePath,
  )

  let vectorPathFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    vectorPathFill,
    property: "fill/color/value",
    color: .rgba(r: 0.2, g: 0.7, b: 0.7, a: 1.0),
  )
  try engine.block.setFill(vectorPathBlock, fill: vectorPathFill)

  try engine.block.setWidth(vectorPathBlock, value: blockWidth)
  try engine.block.setHeight(vectorPathBlock, value: blockHeight)
  try engine.block.appendChild(to: page, child: vectorPathBlock)
  // highlight-createVectorPath

  // highlight-discoverShapeProperties
  let starProperties = try engine.block.findAllProperties(starShape)
  print("Star shape properties: \(starProperties)")
  // highlight-discoverShapeProperties

  // highlight-stickerManualConstruction
  // A sticker is a graphic block with a rect shape and an image fill.
  let stickerBlock = try engine.block.create(.graphic)
  let stickerShape = try engine.block.createShape(.rect)
  try engine.block.setShape(stickerBlock, shape: stickerShape)

  let stickerFill = try engine.block.createFill(.image)
  let stickerURL = baseURL.appendingPathComponent(
    "ly.img.sticker/images/emoticons/imgly_sticker_emoticons_grin.svg",
  )
  try engine.block.setURL(stickerFill, property: "fill/image/imageFileURI", value: stickerURL)
  try engine.block.setFill(stickerBlock, fill: stickerFill)

  // Preserve the sticker's aspect ratio inside the block bounds.
  if try engine.block.supportsContentFillMode(stickerBlock) {
    try engine.block.setContentFillMode(stickerBlock, mode: .contain)
  }

  // Tag the block as a sticker so the editor categorizes it correctly.
  try engine.block.setKind(stickerBlock, kind: "sticker")

  try engine.block.setWidth(stickerBlock, value: blockWidth)
  try engine.block.setHeight(stickerBlock, value: blockHeight)
  try engine.block.appendChild(to: page, child: stickerBlock)
  // highlight-stickerManualConstruction

  // highlight-queryStickers
  // Register the sticker asset source by loading its content.json. The
  // returned ID matches the `id` field in the JSON (here, `ly.img.sticker`).
  let stickerSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("ly.img.sticker/content.json"),
  )

  // Query the first page of stickers. `query` accepts a fuzzy search string;
  // `groups` narrows the result to a single category.
  let stickerResults = try await engine.asset.findAssets(
    sourceID: stickerSourceID,
    query: .init(
      query: nil,
      page: 0,
      groups: ["emoticons"],
      perPage: 5,
    ),
  )
  print("Stickers in emoticons category: \(stickerResults.total)")
  // highlight-queryStickers

  // highlight-applySticker
  // `apply(sourceID:assetResult:)` creates a graphic block from the asset's
  // metadata, attaches it to the current page, and returns its handle — there
  // is no need to call `appendChild` again.
  if let firstSticker = stickerResults.assets.first,
     let stickerFromLibrary = try await engine.asset.apply(
       sourceID: stickerSourceID,
       assetResult: firstSticker,
     ) {
    // The default content fill mode for an applied block is `.crop`. Switch to
    // `.contain` so the sticker preserves its aspect ratio inside the cell.
    if try engine.block.supportsContentFillMode(stickerFromLibrary) {
      try engine.block.setContentFillMode(stickerFromLibrary, mode: .contain)
    }
    try engine.block.setWidth(stickerFromLibrary, value: blockWidth)
    try engine.block.setHeight(stickerFromLibrary, value: blockHeight)
  }
  // highlight-applySticker

  // Demo scaffolding: collect every block in creation order and place them in
  // the 3x3 grid the hero shows.
  let columns = 3
  let spacingX: Float = 30
  let spacingY: Float = 30
  let gridStartX: Float = 130
  let gridStartY: Float = 60
  let shapeBlocks = [
    rectBlock, roundedBlock, ellipseBlock,
    starBlock, polygonBlock, lineBlock,
    vectorPathBlock,
  ]
  let stickerBlocks = try engine.block.find(byKind: "sticker")
  let slots = shapeBlocks + stickerBlocks
  for (index, block) in slots.enumerated() {
    let col = index % columns
    let row = index / columns
    try engine.block.setPositionX(block, value: gridStartX + Float(col) * (blockWidth + spacingX))
    try engine.block.setPositionY(block, value: gridStartY + Float(row) * (blockHeight + spacingY))
  }

  try await engine.captureGuide(page, label: "hero")
}
