import Foundation
import IMGLYEngine

struct MotionPathsGuideResult {
  let ballPosition: SIMD2<Float>
  let keyframeCount: Int
  let firstSpatialOut: SIMD2<Float>?
  let valueKindErrorCode: EngineErrorCode?
  let tangentErrorCode: EngineErrorCode?
  let pngData: Data
}

@MainActor
func motionPaths(engine: Engine) async throws -> MotionPathsGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 5)

  // highlight-motionPaths-createCircle
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
  // highlight-motionPaths-createCircle

  // highlight-motionPaths-curvedPath
  // Both tangents of a segment sit on its first keyframe. `spatialOut` is
  // relative to this keyframe's value, `spatialIn` to the next one's.
  let ball = try createCircle(size: 80, color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1))
  try engine.block.setVec2(ball, property: "position", value: [200, 800])
  try engine.block.setKeyframes(ball, property: "position", keyframes: [
    Keyframe(time: 0, value: .vec2([200, 800]), spatialOut: [0, -400], spatialIn: [-400, 0]),
    Keyframe(time: 0.5, value: .vec2([920, 300]), spatialOut: [400, 0], spatialIn: [0, -400]),
    Keyframe(time: 1, value: .vec2([1640, 800])),
  ])
  let ballPosition = try engine.block.getVec2(ball, property: "position")
  print(ballPosition) // SIMD2<Float>(200.0, 800.0)
  // highlight-motionPaths-curvedPath

  // highlight-motionPaths-straightPath
  let dot = try createCircle(size: 40, color: .rgba(r: 0.9, g: 0.3, b: 0.4, a: 1))
  try engine.block.setVec2(dot, property: "position", value: [200, 980])
  try engine.block.setKeyframes(dot, property: "position", keyframes: [
    Keyframe(time: 0, value: .vec2([200, 980])),
    Keyframe(time: 1, value: .vec2([1680, 980])),
  ])
  // highlight-motionPaths-straightPath

  // highlight-motionPaths-readBack
  let keyframes = try engine.block.getKeyframes(ball, property: "position")
  print(keyframes.count, keyframes[0].spatialOut as Any) // 3 Optional(SIMD2<Float>(0.0, -400.0))
  // highlight-motionPaths-readBack

  // highlight-motionPaths-axisOverride
  // The `position/y` track replaces the y-axis of the `position` track
  let hopper = try createCircle(size: 60, color: .rgba(r: 0.2, g: 0.7, b: 0.3, a: 1))
  try engine.block.setKeyframes(hopper, property: "position", keyframes: [
    Keyframe(time: 0, value: .vec2([200, 100])),
    Keyframe(time: 1, value: .vec2([1660, 100])),
  ])
  try engine.block.setKeyframes(hopper, property: "position/y", keyframes: [
    Keyframe(time: 0, value: .float(160)),
    Keyframe(time: 0.25, value: .float(40)),
    Keyframe(time: 0.5, value: .float(160)),
    Keyframe(time: 0.75, value: .float(40)),
    Keyframe(time: 1, value: .float(160)),
  ])
  // highlight-motionPaths-axisOverride

  // highlight-motionPaths-errors
  var valueKindErrorCode: EngineErrorCode?
  do {
    // A motion path takes vec2 values only
    try engine.block.setKeyframes(ball, property: "position", keyframes: [Keyframe(time: 0, value: .float(0))])
  } catch let error as EngineError {
    valueKindErrorCode = error.catalogCode
    print(valueKindErrorCode == .blockKeyframesValueKindMismatch) // true
  }
  var tangentErrorCode: EngineErrorCode?
  do {
    // A single axis takes no spatial tangents
    try engine.block.setKeyframes(ball, property: "position/x", keyframes: [
      Keyframe(time: 0, value: .float(0), spatialOut: [10, 0]),
    ])
  } catch let error as EngineError {
    tangentErrorCode = error.catalogCode
    print(tangentErrorCode == .blockKeyframesSpatialTangentUnsupported) // true
  }
  // highlight-motionPaths-errors

  // highlight-motionPaths-export
  // Export the frame at 1.25 seconds, while the ball climbs its path
  try engine.block.setPlaybackTime(page, time: 1.25)
  let pngData = try await engine.block.export(page, mimeType: .png)
  print(!pngData.isEmpty) // true
  // highlight-motionPaths-export

  try await engine.captureGuide(data: pngData, label: "hero", mimeType: .png)

  return MotionPathsGuideResult(
    ballPosition: ballPosition,
    keyframeCount: keyframes.count,
    firstSpatialOut: keyframes[0].spatialOut,
    valueKindErrorCode: valueKindErrorCode,
    tangentErrorCode: tangentErrorCode,
    pngData: pngData,
  )
}
