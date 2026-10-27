import Foundation
import IMGLYEngine

struct CompositionGroupsGuideResult {
  let normalIsComposition: Bool
  let fastSpeed: Float
  let plainIsComposition: Bool
  let errorCode: EngineErrorCode?
  let pngData: Data
}

@MainActor
func compositionGroups(engine: Engine) async throws -> CompositionGroupsGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 6)

  // highlight-compositionGroups-createLane
  // Creates a lane: a group with a line and a ball that crosses the page in
  // 4 seconds of its own time
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
    // Long enough for every lane clock, so the line stays visible
    try engine.block.setDuration(line, duration: 12)

    let ball = try engine.block.create(.graphic)
    try engine.block.setShape(ball, shape: engine.block.createShape(.ellipse))
    let ballFill = try engine.block.createFill(.color)
    try engine.block.setColor(ballFill, property: "fill/color/value", color: color)
    try engine.block.setFill(ball, fill: ballFill)
    try engine.block.setWidth(ball, value: 80)
    try engine.block.setHeight(ball, value: 80)
    try engine.block.setPositionY(ball, value: y)
    try engine.block.appendChild(to: page, child: ball)
    try engine.block.setDuration(ball, duration: 4)
    try engine.block.setKeyframes(ball, property: "position/x", keyframes: [
      Keyframe(time: 0, value: .float(120)),
      Keyframe(time: 1, value: .float(1720)),
    ])

    let lane = try engine.block.group([line, ball])
    try engine.block.setDuration(lane, duration: 6)
    return lane
  }
  // highlight-compositionGroups-createLane

  // highlight-compositionGroups-composition
  // The first lane is a composition group. Its children run on the group's
  // own clock, which starts when the group starts on the page.
  let normal = try createLane(y: 150, color: .rgba(r: 0.6, g: 0.6, b: 0.6, a: 1))
  try engine.block.setBool(normal, property: "group/composition", value: true)
  let normalIsComposition = try engine.block.getBool(normal, property: "group/composition")
  print(normalIsComposition) // true
  // highlight-compositionGroups-composition

  // highlight-compositionGroups-speed
  // At speed 2, the children see 2 seconds for every second of the page
  let fast = try createLane(y: 400, color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1))
  try engine.block.setBool(fast, property: "group/composition", value: true)
  try engine.block.setPlaybackSpeed(fast, speed: 2)
  let fastSpeed = try engine.block.getPlaybackSpeed(fast)
  print(fastSpeed) // 2.0
  // highlight-compositionGroups-speed

  // highlight-compositionGroups-offset
  // The group starts 1 second into the page, and its children start with it
  let late = try createLane(y: 650, color: .rgba(r: 0.9, g: 0.3, b: 0.4, a: 1))
  try engine.block.setBool(late, property: "group/composition", value: true)
  try engine.block.setTimeOffset(late, offset: 1)
  try engine.block.setDuration(late, duration: 5)
  // highlight-compositionGroups-offset

  // highlight-compositionGroups-plainGroup
  // Without composition, the speed of a group has no effect
  let plain = try createLane(y: 900, color: .rgba(r: 0.2, g: 0.7, b: 0.3, a: 1))
  try engine.block.setPlaybackSpeed(plain, speed: 2)
  let plainIsComposition = try engine.block.getBool(plain, property: "group/composition")
  print(plainIsComposition) // false
  // highlight-compositionGroups-plainGroup

  // highlight-compositionGroups-errors
  var errorCode: EngineErrorCode?
  do {
    // A group runs at 0.25 times the page speed or faster
    try engine.block.setPlaybackSpeed(normal, speed: 0.1)
  } catch let error as EngineError {
    errorCode = error.catalogCode
    print(errorCode == .editorPlaybackSpeedTooLow) // true
  }
  // highlight-compositionGroups-errors

  // highlight-compositionGroups-export
  // Export the frame at 1.5 seconds
  try engine.block.setPlaybackTime(page, time: 1.5)
  let pngData = try await engine.block.export(page, mimeType: .png)
  print(!pngData.isEmpty) // true
  // highlight-compositionGroups-export

  try await engine.captureGuide(data: pngData, label: "hero", mimeType: .png)

  return CompositionGroupsGuideResult(
    normalIsComposition: normalIsComposition,
    fastSpeed: fastSpeed,
    plainIsComposition: plainIsComposition,
    errorCode: errorCode,
    pngData: pngData,
  )
}
