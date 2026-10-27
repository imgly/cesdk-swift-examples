import Foundation
import IMGLYEngine

struct TimeRemapGuideResult {
  let normalRemapEnabled: Bool
  let reversedStaticRemap: Float
  let remapIsAnimatable: Bool
  let errorCode: EngineErrorCode?
  let pngData: Data
}

@MainActor
func timeRemap(engine: Engine) async throws -> TimeRemapGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 5)

  // highlight-timeRemap-createLane
  // Creates a lane: a composition group with a line and a ball that crosses
  // the page in 5 seconds of the group's own clock
  func createLane(y: Float, color: Color) throws -> DesignBlockID {
    let line = try engine.block.create(.graphic)
    try engine.block.setShape(line, shape: engine.block.createShape(.rect))
    let lineFill = try engine.block.createFill(.color)
    try engine.block.setColor(lineFill, property: "fill/color/value", color: .rgba(r: 0.85, g: 0.85, b: 0.85, a: 1))
    try engine.block.setFill(line, fill: lineFill)
    try engine.block.setWidth(line, value: 1680)
    try engine.block.setHeight(line, value: 6)
    try engine.block.setPositionX(line, value: 120)
    try engine.block.setPositionY(line, value: y + 37)
    try engine.block.appendChild(to: page, child: line)
    try engine.block.setDuration(line, duration: 5)

    let ball = try engine.block.create(.graphic)
    try engine.block.setShape(ball, shape: engine.block.createShape(.ellipse))
    let ballFill = try engine.block.createFill(.color)
    try engine.block.setColor(ballFill, property: "fill/color/value", color: color)
    try engine.block.setFill(ball, fill: ballFill)
    try engine.block.setWidth(ball, value: 80)
    try engine.block.setHeight(ball, value: 80)
    try engine.block.setPositionY(ball, value: y)
    try engine.block.appendChild(to: page, child: ball)
    try engine.block.setDuration(ball, duration: 5)
    try engine.block.setKeyframes(ball, property: "position/x", keyframes: [
      Keyframe(time: 0, value: .float(120)),
      Keyframe(time: 1, value: .float(1720)),
    ])

    let lane = try engine.block.group([line, ball])
    try engine.block.setDuration(lane, duration: 5)
    // A composition group gives its children their own clock
    try engine.block.setBool(lane, property: "group/composition", value: true)
    return lane
  }
  // highlight-timeRemap-createLane

  // highlight-timeRemap-lanes
  let normal = try createLane(y: 150, color: .rgba(r: 0.6, g: 0.6, b: 0.6, a: 1))
  let frozen = try createLane(y: 400, color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1))
  let reversed = try createLane(y: 650, color: .rgba(r: 0.9, g: 0.3, b: 0.4, a: 1))
  let pingPong = try createLane(y: 900, color: .rgba(r: 0.2, g: 0.7, b: 0.3, a: 1))
  let normalRemapEnabled = try engine.block.getBool(normal, property: "playback/timeRemapEnabled")
  print(normalRemapEnabled) // false
  // highlight-timeRemap-lanes

  // highlight-timeRemap-freeze
  // A static remap holds the children at 2.5 seconds of their own time
  try engine.block.setBool(frozen, property: "playback/timeRemapEnabled", value: true)
  try engine.block.setFloat(frozen, property: "playback/timeRemap", value: 2.5)
  // highlight-timeRemap-freeze

  // highlight-timeRemap-reverse
  // The track values are times on the children's clock, in seconds. They
  // stay below 5, because a clock at a child's end hides the child.
  try engine.block.setBool(reversed, property: "playback/timeRemapEnabled", value: true)
  try engine.block.setKeyframes(reversed, property: "playback/timeRemap", keyframes: [
    Keyframe(time: 0, value: .float(4.99)),
    Keyframe(time: 1, value: .float(0)),
  ])
  // highlight-timeRemap-reverse

  // highlight-timeRemap-pingPong
  try engine.block.setBool(pingPong, property: "playback/timeRemapEnabled", value: true)
  try engine.block.setKeyframes(pingPong, property: "playback/timeRemap", keyframes: [
    Keyframe(time: 0, value: .float(0), easing: .preset(.easeInOut)),
    Keyframe(time: 0.5, value: .float(4.99), easing: .preset(.easeInOut)),
    Keyframe(time: 1, value: .float(0)),
  ])
  // highlight-timeRemap-pingPong

  // highlight-timeRemap-readBack
  // The track leaves the static remap unchanged
  let reversedStaticRemap = try engine.block.getFloat(reversed, property: "playback/timeRemap")
  let remapIsAnimatable = try engine.block.isPropertyAnimatable(reversed, property: "playback/timeRemap")
  print(reversedStaticRemap, remapIsAnimatable) // 0.0 true
  // highlight-timeRemap-readBack

  // highlight-timeRemap-errors
  var errorCode: EngineErrorCode?
  do {
    // Only a group has a time remap
    if let ball = try engine.block.getChildren(normal).last {
      try engine.block.setFloat(ball, property: "playback/timeRemap", value: 1)
    }
  } catch let error as EngineError {
    errorCode = error.catalogCode
    print(errorCode == .editorBlockNoTimeRemapSupport) // true
  }
  // highlight-timeRemap-errors

  // highlight-timeRemap-export
  // Export the frame at 1.5 seconds
  try engine.block.setPlaybackTime(page, time: 1.5)
  let pngData = try await engine.block.export(page, mimeType: .png)
  print(!pngData.isEmpty) // true
  // highlight-timeRemap-export

  try await engine.captureGuide(data: pngData, label: "hero", mimeType: .png)

  return TimeRemapGuideResult(
    normalRemapEnabled: normalRemapEnabled,
    reversedStaticRemap: reversedStaticRemap,
    remapIsAnimatable: remapIsAnimatable,
    errorCode: errorCode,
    pngData: pngData,
  )
}
