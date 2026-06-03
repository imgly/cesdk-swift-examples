import Foundation
import IMGLYEngine

@MainActor
func createAudioAdjustSpeed(engine: Engine) async throws {
  // highlight-createAudioAdjustSpeed-setup
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  // highlight-createAudioAdjustSpeed-setup

  // highlight-createAudioAdjustSpeed-createAudio
  let audioBlock = try engine.block.create(.audio)
  try engine.block.setString(
    audioBlock,
    property: "audio/fileURI",
    value: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.0/assets/ly.img.audio/audios/far_from_home.m4a",
  )
  // Wait for the audio resource to load so duration and speed APIs work correctly.
  try await engine.block.forceLoadAVResource(audioBlock)
  // highlight-createAudioAdjustSpeed-createAudio

  // highlight-createAudioAdjustSpeed-setSlowMotion
  // Slow Motion Audio (0.5x — half speed, doubles duration).
  let slowAudioBlock = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: slowAudioBlock)
  try engine.block.setTimeOffset(slowAudioBlock, offset: 0)
  try engine.block.setPlaybackSpeed(slowAudioBlock, speed: 0.5)
  // highlight-createAudioAdjustSpeed-setSlowMotion

  // highlight-createAudioAdjustSpeed-setNormalSpeed
  // Normal Speed Audio (1.0x — original playback rate).
  let normalAudioBlock = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: normalAudioBlock)
  try engine.block.setTimeOffset(normalAudioBlock, offset: 5)
  try engine.block.setPlaybackSpeed(normalAudioBlock, speed: 1.0)

  // Query current speed to verify the change.
  let currentSpeed = try engine.block.getPlaybackSpeed(normalAudioBlock)
  print("Normal speed block set to: \(currentSpeed)x")
  // highlight-createAudioAdjustSpeed-setNormalSpeed

  // highlight-createAudioAdjustSpeed-setMaximumSpeed
  // Maximum Speed Audio (3.0x — triple speed, reduces duration to 1/3).
  let maxSpeedAudioBlock = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: maxSpeedAudioBlock)
  try engine.block.setTimeOffset(maxSpeedAudioBlock, offset: 10)
  try engine.block.setPlaybackSpeed(maxSpeedAudioBlock, speed: 3.0)
  // highlight-createAudioAdjustSpeed-setMaximumSpeed

  // highlight-createAudioAdjustSpeed-speedAndDuration
  // Log duration changes to demonstrate the speed-duration relationship.
  let slowDuration = try engine.block.getDuration(slowAudioBlock)
  let normalDuration = try engine.block.getDuration(normalAudioBlock)
  let maxDuration = try engine.block.getDuration(maxSpeedAudioBlock)

  print(String(format: "Slow motion (0.5x) duration: %.2fs", slowDuration))
  print(String(format: "Normal speed (1.0x) duration: %.2fs", normalDuration))
  print(String(format: "Maximum speed (3.0x) duration: %.2fs", maxDuration))
  // highlight-createAudioAdjustSpeed-speedAndDuration

  // Remove the original audio block (we only need the duplicates).
  try engine.block.destroy(audioBlock)

  // highlight-createAudioAdjustSpeed-export
  let sceneContent = try await engine.scene.saveToString()
  // highlight-createAudioAdjustSpeed-export

  _ = sceneContent
}
