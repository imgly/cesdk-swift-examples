import Foundation
import IMGLYEngine

@MainActor
func masksAndMattes(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1500)
  try engine.block.setHeight(page, value: 500)
  try engine.block.appendChild(to: scene, child: page)

  // A 400 by 400 square graphic at a given x position
  func addSquare(x: Float, fill: DesignBlockID) throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setFill(block, fill: fill)
    try engine.block.setWidth(block, value: 400)
    try engine.block.setHeight(block, value: 400)
    try engine.block.setPositionX(block, value: x)
    try engine.block.setPositionY(block, value: 50)
    try engine.block.appendChild(to: page, child: block)
    return block
  }

  // highlight-masksAndMattes-createMask
  let purple = try engine.block.createFill(.color)
  try engine.block.setColor(purple, property: "fill/color/value", color: .rgba(r: 0.5, g: 0.2, b: 0.9, a: 1))
  let ringBlock = try addSquare(x: 50, fill: purple)

  print(try engine.block.supportsMasks(ringBlock)) // true
  print(try engine.block.supportsMasks(page)) // false

  // The ellipse fills the frame of the masked block
  let outerMask = try engine.block.createMask()
  try engine.block.setShape(outerMask, shape: engine.block.createShape(.ellipse))
  try engine.block.appendMask(ringBlock, maskID: outerMask)
  // highlight-masksAndMattes-createMask

  // highlight-masksAndMattes-maskProperties
  // Soften the edge by 20 units and let 80% of the block show through
  try engine.block.setFloat(outerMask, property: "mask/feather", value: 20)
  try engine.block.setFloat(outerMask, property: "mask/opacity", value: 0.8)
  // highlight-masksAndMattes-maskProperties

  // highlight-masksAndMattes-combineMasks
  // Shrink a second ellipse by 100 units and subtract it to cut a ring
  let innerMask = try engine.block.createMask()
  try engine.block.setShape(innerMask, shape: engine.block.createShape(.ellipse))
  try engine.block.setFloat(innerMask, property: "mask/expansion", value: -100)
  try engine.block.setEnum(innerMask, property: "mask/mode", value: "Subtract")
  try engine.block.appendMask(ringBlock, maskID: innerMask)
  // highlight-masksAndMattes-combineMasks

  // highlight-masksAndMattes-invertMask
  let teal = try engine.block.createFill(.color)
  try engine.block.setColor(teal, property: "fill/color/value", color: .rgba(r: 0, g: 0.6, b: 0.6, a: 1))
  let starBlock = try addSquare(x: 550, fill: teal)

  // An inverted mask keeps the area outside its shape: a star-shaped hole
  let starMask = try engine.block.createMask()
  try engine.block.setShape(starMask, shape: engine.block.createShape(.star))
  try engine.block.setBool(starMask, property: "mask/inverted", value: true)
  try engine.block.appendMask(starBlock, maskID: starMask)
  // highlight-masksAndMattes-invertMask

  // highlight-masksAndMattes-manageMasks
  print(try engine.block.getMasks(ringBlock)) // [outerMask, innerMask]

  // Removing a mask does not destroy it
  try engine.block.removeMask(ringBlock, index: 1)
  print(engine.block.isValid(innerMask)) // true

  // Insert it again after the outer mask
  try engine.block.insertMask(ringBlock, maskID: innerMask, index: 1)
  // highlight-masksAndMattes-manageMasks

  // highlight-masksAndMattes-setMatte
  let orange = try engine.block.createFill(.color)
  try engine.block.setColor(orange, property: "fill/color/value", color: .rgba(r: 1, g: 0.5, b: 0, a: 1))
  let target = try addSquare(x: 1050, fill: orange)

  // The matte source: a gradient from white at the top to black at the bottom
  let gradient = try engine.block.createFill(.linearGradient)
  try engine.block.setGradientColorStops(
    gradient,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .rgba(r: 1, g: 1, b: 1, a: 1), stop: 0),
      GradientColorStop(color: .rgba(r: 0, g: 0, b: 0, a: 1), stop: 1),
    ],
  )
  let source = try addSquare(x: 1050, fill: gradient)

  // The target shows where the source is bright. The source is not drawn.
  try engine.block.setMatte(target, source: source, mode: .luma)
  // highlight-masksAndMattes-setMatte

  // highlight-masksAndMattes-readMatte
  let matte = try engine.block.getMatte(target)
  print(matte == BlockMatte(source: source, mode: .luma)) // true
  print(try engine.block.getMatte(ringBlock) == nil) // true
  // highlight-masksAndMattes-readMatte

  // highlight-masksAndMattes-matteRules
  do {
    // A block cannot use itself as its matte source
    try engine.block.setMatte(target, source: target)
  } catch let error as EngineError {
    print(error.catalogCode == .blockMatteSourceInvalid) // true
  }
  // highlight-masksAndMattes-matteRules

  // highlight-masksAndMattes-export
  let png = try await engine.block.export(page, mimeType: .png)

  // SVG export ignores the mask opacity and feather, and draws the matted block whole
  let svg = try await engine.block.export(page, mimeType: .svg)
  print("Exported \(png.count) PNG bytes and \(svg.count) SVG bytes")
  // highlight-masksAndMattes-export
}
