import Foundation
import IMGLYEngine

struct TransformParentGuideResult {
  let pivot: DesignBlockID
  let page: DesignBlockID
  let planetTransformParent: DesignBlockID?
  let moonOpacity: Float
  let moonParent: DesignBlockID?
  let planetX: Float
  let planetY: Float
  let labelTransformParent: DesignBlockID?
  let cycleErrorCode: EngineErrorCode?
  let unsupportedErrorCode: EngineErrorCode?
  let pngData: Data
}

@MainActor
func transformParent(engine: Engine) async throws -> TransformParentGuideResult {
  let scene = try engine.scene.create()
  // At 72 DPI one point is one pixel, so the 36 pt label draws at 36 px.
  try engine.scene.setDesignUnit(.px)
  try engine.block.setFloat(scene, property: "scene/dpi", value: 72)
  try engine.block.setFloat(scene, property: "scene/pixelScaleFactor", value: 1)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 5)

  // highlight-transformParent-createCircle
  // Creates a circle graphic of the given size and color on the page
  func createCircle(size: Float, color: Color) throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.ellipse))
    let fill = try engine.block.createFill(.color)
    try engine.block.setColor(fill, property: "fill/color/value", color: color)
    try engine.block.setFill(block, fill: fill)
    try engine.block.setWidth(block, value: size)
    try engine.block.setHeight(block, value: size)
    try engine.block.appendChild(to: page, child: block)
    try engine.block.setDuration(block, duration: 5)
    return block
  }
  // highlight-transformParent-createCircle

  // highlight-transformParent-hiddenParent
  let pivot = try createCircle(size: 20, color: .rgba(r: 0, g: 0, b: 0, a: 1))
  try engine.block.setPositionX(pivot, value: 950)
  try engine.block.setPositionY(pivot, value: 530)
  try engine.block.setFloat(pivot, property: "transform/anchor/x", value: 10)
  try engine.block.setFloat(pivot, property: "transform/anchor/y", value: 10)
  try engine.block.setKeyframes(pivot, property: "rotation", keyframes: [
    Keyframe(time: 0, value: .float(0)),
    Keyframe(time: 1, value: .float(2 * Float.pi)),
  ])
  try engine.block.setVisible(pivot, visible: false)
  // highlight-transformParent-hiddenParent

  // highlight-transformParent-link
  let planet = try createCircle(size: 120, color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1))
  try engine.block.setTransformParent(planet, parent: pivot)
  let planetTransformParent = try engine.block.getTransformParent(planet)
  print(planetTransformParent == pivot) // true
  // The position is now an offset from the pivot's top-left corner,
  // in the pivot's turning space
  try engine.block.setPositionX(planet, value: 300)
  try engine.block.setPositionY(planet, value: -50)
  // highlight-transformParent-link

  // highlight-transformParent-chain
  // The planet spins twice about its center while it circles the pivot
  try engine.block.setFloat(planet, property: "transform/anchor/x", value: 60)
  try engine.block.setFloat(planet, property: "transform/anchor/y", value: 60)
  try engine.block.setKeyframes(planet, property: "rotation", keyframes: [
    Keyframe(time: 0, value: .float(0)),
    Keyframe(time: 1, value: .float(4 * Float.pi)),
  ])

  // The moon follows the planet, which follows the pivot
  let moon = try createCircle(size: 40, color: .rgba(r: 0.85, g: 0.85, b: 0.8, a: 1))
  try engine.block.setTransformParent(moon, parent: planet)
  try engine.block.setPositionX(moon, value: 160)
  try engine.block.setPositionY(moon, value: 40)

  // A text label follows the planet, too
  let label = try engine.block.create(.text)
  try engine.block.replaceText(label, text: "Planet")
  try engine.block.setTextFontSize(label, fontSize: 36)
  try engine.block.setWidthMode(label, mode: .auto)
  try engine.block.setHeightMode(label, mode: .auto)
  try engine.block.appendChild(to: page, child: label)
  try engine.block.setTransformParent(label, parent: planet)
  try engine.block.setPositionX(label, value: 0)
  try engine.block.setPositionY(label, value: 140)
  // highlight-transformParent-chain

  // highlight-transformParent-transformOnly
  try engine.block.setOpacity(planet, value: 0.5)
  let moonOpacity = try engine.block.getOpacity(moon)
  let moonParent = try engine.block.getParent(moon)
  print(moonOpacity, moonParent == page) // 1.0 true
  // highlight-transformParent-transformOnly

  // highlight-transformParent-readPosition
  // A quarter of the way through, the pivot has turned by 90 degrees
  try engine.block.setPlaybackTime(page, time: 1.25)
  let planetX = try engine.block.getGlobalBoundingBoxX(planet)
  let planetY = try engine.block.getGlobalBoundingBoxY(planet)
  print(planetX, planetY) // 900.0 830.0
  // highlight-transformParent-readPosition

  // highlight-transformParent-unlink
  // The label's position is read in page space again, so place it there
  try engine.block.setTransformParent(label, parent: nil)
  let labelTransformParent = try engine.block.getTransformParent(label)
  print(labelTransformParent == nil) // true
  try engine.block.setPositionX(label, value: 80)
  try engine.block.setPositionY(label, value: 80)
  // highlight-transformParent-unlink

  // highlight-transformParent-errors
  var cycleErrorCode: EngineErrorCode?
  do {
    // The pivot cannot follow a block that follows it
    try engine.block.setTransformParent(pivot, parent: moon)
  } catch let error as EngineError {
    cycleErrorCode = error.catalogCode
    print(cycleErrorCode == .blockTransformParentCycle) // true
  }
  var unsupportedErrorCode: EngineErrorCode?
  do {
    // Only graphic and text blocks take part in a link
    try engine.block.setTransformParent(planet, parent: page)
  } catch let error as EngineError {
    unsupportedErrorCode = error.catalogCode
    print(unsupportedErrorCode == .blockTransformParentUnsupported) // true
  }
  // highlight-transformParent-errors

  // highlight-transformParent-export
  // The playback time is still 1.25 seconds, so the frame shows the planet below the pivot
  let pngData = try await engine.block.export(page, mimeType: .png)
  // highlight-transformParent-export

  try await engine.captureGuide(data: pngData, label: "hero", mimeType: .png)

  return TransformParentGuideResult(
    pivot: pivot,
    page: page,
    planetTransformParent: planetTransformParent,
    moonOpacity: moonOpacity,
    moonParent: moonParent,
    planetX: planetX,
    planetY: planetY,
    labelTransformParent: labelTransformParent,
    cycleErrorCode: cycleErrorCode,
    unsupportedErrorCode: unsupportedErrorCode,
    pngData: pngData,
  )
}
