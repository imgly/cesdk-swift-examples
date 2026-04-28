import Foundation
import IMGLYEngine

@MainActor
func positionAndAlign(engine: Engine) async throws {
  // highlight-positionAndAlign-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let imageURI = "https://img.ly/static/ubq_samples/sample_1.jpg"
  // highlight-positionAndAlign-setup

  // highlight-positionAndAlign-absolutePosition
  // Block 1: Absolute positioning at specific coordinates (in design units).
  let block1 = try engine.block.create(.graphic)
  try engine.block.setShape(block1, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block1, value: 150)
  try engine.block.setHeight(block1, value: 100)
  let fill1 = try engine.block.createFill(.image)
  try engine.block.setString(fill1, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(block1, fill: fill1)
  try engine.block.appendChild(to: page, child: block1)

  try engine.block.setPositionX(block1, value: 50)
  try engine.block.setPositionY(block1, value: 50)

  // Query the current position.
  let x1 = try engine.block.getPositionX(block1)
  let y1 = try engine.block.getPositionY(block1)
  print("Block 1 position: (\(x1), \(y1))")
  // highlight-positionAndAlign-absolutePosition

  // highlight-positionAndAlign-percentPosition
  // Block 2: Percentage-based positioning relative to the parent's size.
  let block2 = try engine.block.create(.graphic)
  try engine.block.setShape(block2, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block2, value: 150)
  try engine.block.setHeight(block2, value: 100)
  let fill2 = try engine.block.createFill(.image)
  try engine.block.setString(fill2, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(block2, fill: fill2)
  try engine.block.appendChild(to: page, child: block2)

  // Switch position modes to .percent and use fractional values where
  // 1.0 represents 100% of the parent's size.
  try engine.block.setPositionXMode(block2, mode: .percent)
  try engine.block.setPositionYMode(block2, mode: .percent)
  try engine.block.setPositionX(block2, value: 0.5) // 50% from left
  try engine.block.setPositionY(block2, value: 0.5) // 50% from top

  // Query the position mode.
  let xMode = try engine.block.getPositionXMode(block2)
  let yMode = try engine.block.getPositionYMode(block2)
  print("Block 2 position modes: X=\(xMode), Y=\(yMode)")
  // highlight-positionAndAlign-percentPosition

  // highlight-positionAndAlign-checkAlignable
  // Build a small set of blocks for alignment.
  var alignBlocks: [DesignBlockID] = []
  let alignPositions: [(Float, Float)] = [(100, 100), (250, 150), (180, 250), (350, 200)]
  for (x, y) in alignPositions {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setWidth(block, value: 100)
    try engine.block.setHeight(block, value: 80)
    let fill = try engine.block.createFill(.image)
    try engine.block.setString(fill, property: "fill/image/imageFileURI", value: imageURI)
    try engine.block.setFill(block, fill: fill)
    try engine.block.appendChild(to: page, child: block)
    try engine.block.setPositionX(block, value: x)
    try engine.block.setPositionY(block, value: y)
    alignBlocks.append(block)
  }

  // Confirm the blocks support alignment before calling alignment APIs.
  let canAlign = try engine.block.isAlignable(alignBlocks)
  print("Can align blocks: \(canAlign)")
  // highlight-positionAndAlign-checkAlignable

  // highlight-positionAndAlign-alignHorizontal
  // Align the blocks to the left edge of their combined bounding box.
  if canAlign {
    try engine.block.alignHorizontally(alignBlocks, alignment: .left)
  }
  // highlight-positionAndAlign-alignHorizontal

  // highlight-positionAndAlign-alignSingleBlock
  // Passing a single block aligns it to its parent rather than to a group
  // bounding box. This is convenient for centering an element on a page.
  let singleBlock = try engine.block.create(.graphic)
  try engine.block.setShape(singleBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(singleBlock, value: 150)
  try engine.block.setHeight(singleBlock, value: 100)
  let singleFill = try engine.block.createFill(.image)
  try engine.block.setString(singleFill, property: "fill/image/imageFileURI", value: imageURI)
  try engine.block.setFill(singleBlock, fill: singleFill)
  try engine.block.appendChild(to: page, child: singleBlock)
  try engine.block.setPositionX(singleBlock, value: 500)
  try engine.block.setPositionY(singleBlock, value: 300)

  if try engine.block.isAlignable([singleBlock]) {
    try engine.block.alignHorizontally([singleBlock], alignment: .center)
    try engine.block.alignVertically([singleBlock], alignment: .center)
  }
  // highlight-positionAndAlign-alignSingleBlock

  // highlight-positionAndAlign-checkDistributable
  // Build another row of blocks at uneven horizontal positions for distribution.
  var distributeBlocks: [DesignBlockID] = []
  let xPositions: [Float] = [50, 180, 400, 650]
  for x in xPositions {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setWidth(block, value: 100)
    try engine.block.setHeight(block, value: 80)
    let fill = try engine.block.createFill(.image)
    try engine.block.setString(fill, property: "fill/image/imageFileURI", value: imageURI)
    try engine.block.setFill(block, fill: fill)
    try engine.block.appendChild(to: page, child: block)
    try engine.block.setPositionX(block, value: x)
    try engine.block.setPositionY(block, value: 200)
    distributeBlocks.append(block)
  }

  // Confirm the blocks support distribution before calling distribution APIs.
  let canDistribute = try engine.block.isDistributable(distributeBlocks)
  print("Can distribute blocks: \(canDistribute)")
  // highlight-positionAndAlign-checkDistributable

  // highlight-positionAndAlign-distributeHorizontal
  // Distribute blocks horizontally so the space between them is even.
  // The first and last blocks remain in place.
  if canDistribute {
    try engine.block.distributeHorizontally(distributeBlocks)
  }
  // highlight-positionAndAlign-distributeHorizontal

  // highlight-positionAndAlign-distributeVertical
  // Build a column of blocks at uneven vertical positions for vertical
  // distribution.
  var verticalBlocks: [DesignBlockID] = []
  let yPositions: [Float] = [50, 150, 350, 500]
  for y in yPositions {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setWidth(block, value: 100)
    try engine.block.setHeight(block, value: 80)
    let fill = try engine.block.createFill(.image)
    try engine.block.setString(fill, property: "fill/image/imageFileURI", value: imageURI)
    try engine.block.setFill(block, fill: fill)
    try engine.block.appendChild(to: page, child: block)
    try engine.block.setPositionX(block, value: 600)
    try engine.block.setPositionY(block, value: y)
    verticalBlocks.append(block)
  }

  if try engine.block.isDistributable(verticalBlocks) {
    try engine.block.distributeVertically(verticalBlocks)
  }
  // highlight-positionAndAlign-distributeVertical

  // highlight-positionAndAlign-snappingThreshold
  // Configure the position snapping threshold (in pixels). Higher values
  // make snapping activate from further away.
  try engine.editor.setSettingFloat("positionSnappingThreshold", value: 10)

  // Configure the rotation snapping threshold (in radians).
  try engine.editor.setSettingFloat("rotationSnappingThreshold", value: 5 * .pi / 180)
  // highlight-positionAndAlign-snappingThreshold

  // highlight-positionAndAlign-snappingColors
  // Customize snapping guide colors. `snappingGuideColor` controls the
  // position snapping lines and `rotationSnappingGuideColor` controls the
  // rotation guides.
  try engine.editor.setSettingColor(
    "snappingGuideColor",
    color: .rgba(r: 0.2, g: 0.6, b: 1.0, a: 1.0),
  )
  try engine.editor.setSettingColor(
    "rotationSnappingGuideColor",
    color: .rgba(r: 1.0, g: 0.4, b: 0.2, a: 1.0),
  )
  // highlight-positionAndAlign-snappingColors
}
