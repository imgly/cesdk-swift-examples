import Foundation
import IMGLYEngine

@MainActor
func motionBlur(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 2)

  // highlight-motionBlur-animateBlock
  // A square that crosses the page in one second. Motion blur needs motion.
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let fill = try engine.block.createFill(.color)
  try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.9, g: 0.2, b: 0.4, a: 1))
  try engine.block.setFill(block, fill: fill)
  try engine.block.setWidth(block, value: 300)
  try engine.block.setHeight(block, value: 300)
  try engine.block.setPositionY(block, value: 390)
  try engine.block.appendChild(to: page, child: block)
  try engine.block.setDuration(block, duration: 2)

  try engine.block.setKeyframes(block, property: "position/x", keyframes: [
    Keyframe(time: 0, value: .float(100)),
    Keyframe(time: 0.5, value: .float(1520)),
    Keyframe(time: 1, value: .float(100)),
  ])
  // highlight-motionBlur-animateBlock

  // highlight-motionBlur-enable
  // Blur the block while it moves
  try engine.block.setBool(block, property: "motionBlur/enabled", value: true)
  print(try engine.block.getBool(block, property: "motionBlur/enabled")) // true
  // highlight-motionBlur-enable

  // highlight-motionBlur-checkSupport
  // Graphic, text and caption blocks have the property. Pages do not.
  let blockHasMotionBlur = try engine.block.findAllProperties(block).contains("motionBlur/enabled")
  let pageHasMotionBlur = try engine.block.findAllProperties(page).contains("motionBlur/enabled")
  print(blockHasMotionBlur, pageHasMotionBlur) // true false
  // highlight-motionBlur-checkSupport

  // highlight-motionBlur-shutter
  // The scene holds the shutter for all blocks with motion blur.
  // 360 degrees keeps the shutter open for one full frame.
  try engine.block.setFloat(scene, property: "motionBlur/shutterAngle", value: 360)
  // -180 degrees, half the angle, centers the shutter on the frame time
  try engine.block.setFloat(scene, property: "motionBlur/shutterPhase", value: -180)
  // highlight-motionBlur-shutter

  // highlight-motionBlur-samples
  // More samples give a smoother trail and take longer to render
  try engine.block.setInt(scene, property: "motionBlur/samples", value: 32)
  print(try engine.block.getInt(scene, property: "motionBlur/samples")) // 32
  // highlight-motionBlur-samples

  // highlight-motionBlur-frameRate
  // One frame of the scene frame rate is the span the shutter angle refers to
  try engine.block.setFloat(scene, property: "scene/frameRate", value: 30)
  // highlight-motionBlur-frameRate

  // highlight-motionBlur-previewSetting
  // The preview draws the motion blur by default.
  // Set the value to false to show the blocks sharp while editing.
  try engine.editor.setSettingBool("features/previewMotionBlurEnabled", value: false)
  print(try engine.editor.getSettingBool("features/previewMotionBlurEnabled")) // false
  // highlight-motionBlur-previewSetting

  // highlight-motionBlur-errors
  do {
    try engine.block.setInt(scene, property: "motionBlur/samples", value: 100)
  } catch let error as EngineError {
    print(error.catalogCode == .blockMotionBlurValueOutOfRange) // true
  }
  // highlight-motionBlur-errors

  // highlight-motionBlur-exportVideo
  // Image export draws no motion blur. Export a video to see it in a file.
  let stream = try await engine.block.exportVideo(page, mimeType: .mp4)
  for try await event in stream {
    if case let .finished(video: video) = event {
      try video.write(to: FileManager.default.temporaryDirectory.appendingPathComponent("motion-blur.mp4"))
    }
  }
  // highlight-motionBlur-exportVideo
}
