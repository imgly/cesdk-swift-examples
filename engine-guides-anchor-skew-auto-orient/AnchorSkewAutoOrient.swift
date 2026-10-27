import Foundation
import IMGLYEngine

struct AnchorSkewAutoOrientGuideResult {
  let centerAnchorX: Float
  let signSkew: Float
  let arrowAutoOrient: Bool
  let anchorErrorCode: EngineErrorCode?
  let autoOrientErrorCode: EngineErrorCode?
  let pngData: Data
}

@MainActor
func anchorSkewAutoOrient(engine: Engine) async throws -> AnchorSkewAutoOrientGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 5)

  // highlight-anchorSkewAutoOrient-createRect
  // Creates a rect graphic with a color fill on the page
  func createRect(x: Float, y: Float, width: Float, height: Float, color: Color) throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    let fill = try engine.block.createFill(.color)
    try engine.block.setColor(fill, property: "fill/color/value", color: color)
    try engine.block.setFill(block, fill: fill)
    try engine.block.setWidth(block, value: width)
    try engine.block.setHeight(block, value: height)
    try engine.block.setPositionX(block, value: x)
    try engine.block.setPositionY(block, value: y)
    try engine.block.appendChild(to: page, child: block)
    try engine.block.setDuration(block, duration: 5)
    return block
  }
  // highlight-anchorSkewAutoOrient-createRect

  // highlight-anchorSkewAutoOrient-anchor
  let cornerSquare = try createRect(x: 300, y: 200, width: 160, height: 160, color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1))
  let centerSquare = try createRect(x: 700, y: 200, width: 160, height: 160, color: .rgba(r: 0.9, g: 0.3, b: 0.4, a: 1))
  // Without an anchor, a rotation track turns a block about its center, so
  // the left square sets its anchor to its top-left corner
  try engine.block.setFloat(cornerSquare, property: "transform/anchor/x", value: 0)
  try engine.block.setFloat(cornerSquare, property: "transform/anchor/y", value: 0)
  try engine.block.setFloat(centerSquare, property: "transform/anchor/x", value: 80)
  try engine.block.setFloat(centerSquare, property: "transform/anchor/y", value: 80)
  for square in [cornerSquare, centerSquare] {
    try engine.block.setKeyframes(square, property: "rotation", keyframes: [
      Keyframe(time: 0, value: .float(0)),
      Keyframe(time: 1, value: .float(Float.pi / 2)),
    ])
  }
  let centerAnchorX = try engine.block.getFloat(centerSquare, property: "transform/anchor/x")
  print(centerAnchorX) // 80.0
  // highlight-anchorSkewAutoOrient-anchor

  // highlight-anchorSkewAutoOrient-hasAnchor
  // An anchor set to 0 is still an anchor
  print(try engine.block.hasTransformAnchor(cornerSquare)) // true
  // highlight-anchorSkewAutoOrient-hasAnchor

  // highlight-anchorSkewAutoOrient-skew
  let sign = try createRect(x: 1150, y: 200, width: 240, height: 160, color: .rgba(r: 0.95, g: 0.7, b: 0.1, a: 1))
  try engine.block.setFloat(sign, property: "transform/skew", value: 20)
  try engine.block.setFloat(sign, property: "transform/skewAxis", value: 0)
  // highlight-anchorSkewAutoOrient-skew

  // highlight-anchorSkewAutoOrient-animateSkew
  // The anchor sits at the bottom center, so the base of the blade stays put
  let blade = try createRect(x: 1600, y: 600, width: 40, height: 300, color: .rgba(r: 0.2, g: 0.7, b: 0.3, a: 1))
  try engine.block.setFloat(blade, property: "transform/anchor/x", value: 20)
  try engine.block.setFloat(blade, property: "transform/anchor/y", value: 300)
  try engine.block.setKeyframes(blade, property: "transform/skew", keyframes: [
    Keyframe(time: 0, value: .float(-20)),
    Keyframe(time: 0.5, value: .float(20)),
    Keyframe(time: 1, value: .float(-20)),
  ])
  // highlight-anchorSkewAutoOrient-animateSkew

  // highlight-anchorSkewAutoOrient-autoOrient
  let arrow = try createRect(x: 300, y: 800, width: 160, height: 40, color: .rgba(r: 0.5, g: 0.2, b: 0.8, a: 1))
  try engine.block.setFloat(arrow, property: "transform/anchor/x", value: 80)
  try engine.block.setFloat(arrow, property: "transform/anchor/y", value: 20)
  try engine.block.setVec2(arrow, property: "position", value: [300, 800])
  try engine.block.setKeyframes(arrow, property: "position", keyframes: [
    Keyframe(time: 0, value: .vec2([300, 800]), spatialOut: [300, -300], spatialIn: [-300, -300]),
    Keyframe(time: 1, value: .vec2([1300, 800])),
  ])
  try engine.block.setBool(arrow, property: "transform/autoOrient", value: true)
  let arrowAutoOrient = try engine.block.getBool(arrow, property: "transform/autoOrient")
  print(arrowAutoOrient) // true
  // highlight-anchorSkewAutoOrient-autoOrient

  // highlight-anchorSkewAutoOrient-errors
  var anchorErrorCode: EngineErrorCode?
  do {
    // A page has no anchor and no skew
    try engine.block.setFloat(page, property: "transform/anchor/x", value: 10)
  } catch let error as EngineError {
    anchorErrorCode = error.catalogCode
    print(anchorErrorCode == .blockTypeCannotHaveAnchorOrSkew) // true
  }
  var autoOrientErrorCode: EngineErrorCode?
  do {
    try engine.block.setBool(page, property: "transform/autoOrient", value: true)
  } catch let error as EngineError {
    autoOrientErrorCode = error.catalogCode
    print(autoOrientErrorCode == .blockTypeCannotAutoOrient) // true
  }
  // highlight-anchorSkewAutoOrient-errors

  // highlight-anchorSkewAutoOrient-export
  // Export the frame at 1.5 seconds, while the arrow climbs its path
  try engine.block.setPlaybackTime(page, time: 1.5)
  let pngData = try await engine.block.export(page, mimeType: .png)
  // highlight-anchorSkewAutoOrient-export

  try await engine.captureGuide(data: pngData, label: "hero", mimeType: .png)

  return try AnchorSkewAutoOrientGuideResult(
    centerAnchorX: centerAnchorX,
    signSkew: engine.block.getFloat(sign, property: "transform/skew"),
    arrowAutoOrient: arrowAutoOrient,
    anchorErrorCode: anchorErrorCode,
    autoOrientErrorCode: autoOrientErrorCode,
    pngData: pngData,
  )
}
