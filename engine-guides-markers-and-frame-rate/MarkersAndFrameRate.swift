import Foundation
import IMGLYEngine

struct MarkersAndFrameRateGuideResult {
  let defaultFrameRate: Float
  let frameRate: Float
  let markerNames: [String]
  let playbackTimeAtBeat: Double
  let markerCountAfterRemove: Int
  let frameRateErrorCode: EngineErrorCode?
  let markerTimeErrorCode: EngineErrorCode?
  let markerIndexErrorCode: EngineErrorCode?
  let pngData: Data
}

@MainActor
func markersAndFrameRate(engine: Engine) async throws -> MarkersAndFrameRateGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 10)

  // highlight-markersAndFrameRate-createBall
  // Creates a ball that crosses the page in 10 seconds
  func createBall() throws {
    let ball = try engine.block.create(.graphic)
    try engine.block.setShape(ball, shape: engine.block.createShape(.ellipse))
    let fill = try engine.block.createFill(.color)
    try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1))
    try engine.block.setFill(ball, fill: fill)
    try engine.block.setWidth(ball, value: 160)
    try engine.block.setHeight(ball, value: 160)
    try engine.block.setPositionY(ball, value: 460)
    try engine.block.appendChild(to: page, child: ball)
    try engine.block.setDuration(ball, duration: 10)
    try engine.block.setKeyframes(ball, property: "position/x", keyframes: [
      Keyframe(time: 0, value: .float(100)),
      Keyframe(time: 1, value: .float(1660)),
    ])
  }
  // highlight-markersAndFrameRate-createBall

  // highlight-markersAndFrameRate-ball
  // A ball crosses the page over the 10 seconds of the page
  try createBall()
  // highlight-markersAndFrameRate-ball

  // highlight-markersAndFrameRate-frameRate
  // 30 frames per second by default
  let defaultFrameRate = try engine.block.getFloat(scene, property: "scene/frameRate")
  try engine.block.setFloat(scene, property: "scene/frameRate", value: 25)
  let frameRate = try engine.block.getFloat(scene, property: "scene/frameRate")
  print(defaultFrameRate, frameRate) // 30.0 25.0
  // highlight-markersAndFrameRate-frameRate

  // highlight-markersAndFrameRate-addMarkers
  // A marker has a name, a start time and a duration in seconds.
  // A duration of 0 marks a point.
  try engine.scene.addMarker(name: "intro", time: 0, duration: 2.5)
  try engine.scene.addMarker(name: "beat", time: 4)
  try engine.scene.addMarker(name: "beat", time: 6)
  try engine.scene.addMarker(name: "outro", time: 8, duration: 2)
  // highlight-markersAndFrameRate-addMarkers

  // highlight-markersAndFrameRate-readMarkers
  let markers = try engine.scene.getMarkers()
  let markerNames = markers.map(\.name)
  print(markerNames) // ["intro", "beat", "beat", "outro"]
  // highlight-markersAndFrameRate-readMarkers

  // highlight-markersAndFrameRate-seek
  // Jump to the first marker named "beat"
  if let beat = markers.first(where: { $0.name == "beat" }) {
    try engine.block.setPlaybackTime(page, time: beat.time)
  }
  let playbackTimeAtBeat = try engine.block.getPlaybackTime(page)
  print(playbackTimeAtBeat) // 4.0
  // highlight-markersAndFrameRate-seek

  // highlight-markersAndFrameRate-removeMarker
  // Remove the second "beat" by its index in the list
  try engine.scene.removeMarker(at: 2)
  let markerCountAfterRemove = try engine.scene.getMarkers().count
  print(markerCountAfterRemove) // 3
  // highlight-markersAndFrameRate-removeMarker

  // highlight-markersAndFrameRate-errors
  var frameRateErrorCode: EngineErrorCode?
  do {
    // A frame rate is greater than 0 and at most 240
    try engine.block.setFloat(scene, property: "scene/frameRate", value: 0)
  } catch let error as EngineError {
    frameRateErrorCode = error.catalogCode
    print(frameRateErrorCode == .sceneFrameRateOutOfRange) // true
  }
  var markerTimeErrorCode: EngineErrorCode?
  do {
    try engine.scene.addMarker(name: "before", time: -1)
  } catch let error as EngineError {
    markerTimeErrorCode = error.catalogCode
    print(markerTimeErrorCode == .sceneMarkerInvalidTime) // true
  }
  var markerIndexErrorCode: EngineErrorCode?
  do {
    try engine.scene.removeMarker(at: 10)
  } catch let error as EngineError {
    markerIndexErrorCode = error.catalogCode
    print(markerIndexErrorCode == .sceneMarkerIndexOutOfRange) // true
  }
  // highlight-markersAndFrameRate-errors

  // highlight-markersAndFrameRate-export
  // The playback time is at the "beat" marker, 4 seconds into the page
  let pngData = try await engine.block.export(page, mimeType: .png)
  print(!pngData.isEmpty) // true
  // highlight-markersAndFrameRate-export

  try await engine.captureGuide(data: pngData, label: "hero", mimeType: .png)

  return MarkersAndFrameRateGuideResult(
    defaultFrameRate: defaultFrameRate,
    frameRate: frameRate,
    markerNames: markerNames,
    playbackTimeAtBeat: playbackTimeAtBeat,
    markerCountAfterRemove: markerCountAfterRemove,
    frameRateErrorCode: frameRateErrorCode,
    markerTimeErrorCode: markerTimeErrorCode,
    markerIndexErrorCode: markerIndexErrorCode,
    pngData: pngData,
  )
}
