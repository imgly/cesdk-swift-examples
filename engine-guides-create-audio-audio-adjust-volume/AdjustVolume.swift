import Foundation
import IMGLYEngine

@MainActor
func adjustVolume(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 20)

  let audioURI = URL(
    string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.1/assets/ly.img.audio/audios/dance_harder.m4a",
  )!

  // highlight-adjustVolume-create-audio
  // Create an audio block and load the audio file.
  let audioBlock = try engine.block.create(.audio)
  try engine.block.setString(audioBlock, property: "audio/fileURI", value: audioURI.absoluteString)

  // Wait for the audio resource to load before adjusting volume or querying state.
  try await engine.block.forceLoadAVResource(audioBlock)
  // highlight-adjustVolume-create-audio

  // highlight-adjustVolume-set-volume
  // Set volume to 80% (0.8 on a 0.0-1.0 scale).
  let fullVolumeAudio = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: fullVolumeAudio)
  try engine.block.setTimeOffset(fullVolumeAudio, offset: 0)
  try engine.block.setVolume(fullVolumeAudio, volume: 0.8)
  // highlight-adjustVolume-set-volume

  // highlight-adjustVolume-set-low-volume
  // Set volume to 30% for background music.
  let lowVolumeAudio = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: lowVolumeAudio)
  try engine.block.setTimeOffset(lowVolumeAudio, offset: 5)
  try engine.block.setVolume(lowVolumeAudio, volume: 0.3)
  // highlight-adjustVolume-set-low-volume

  // highlight-adjustVolume-mute-audio
  // Mute an audio block. The volume setting is preserved so unmuting restores playback at the same level.
  let mutedAudio = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: mutedAudio)
  try engine.block.setTimeOffset(mutedAudio, offset: 10)
  try engine.block.setVolume(mutedAudio, volume: 1.0)
  try engine.block.setMuted(mutedAudio, muted: true)
  // highlight-adjustVolume-mute-audio

  // highlight-adjustVolume-query-volume
  // Query current volume and mute states.
  let currentVolume = try engine.block.getVolume(fullVolumeAudio)
  let lowVolume = try engine.block.getVolume(lowVolumeAudio)
  let isMuted = try engine.block.isMuted(mutedAudio)
  let isForceMuted = try engine.block.isForceMuted(mutedAudio)

  print(String(format: "Full volume audio: %.0f%%", currentVolume * 100))
  print(String(format: "Low volume audio: %.0f%%", lowVolume * 100))
  print("Muted audio — isMuted: \(isMuted), isForceMuted: \(isForceMuted)")
  // highlight-adjustVolume-query-volume

  // highlight-adjustVolume-volume-slider
  // Map a slider value (0-100) to the normalized 0.0-1.0 volume range.
  let sliderValue: Float = 75
  let volume = sliderValue / 100
  try engine.block.setVolume(fullVolumeAudio, volume: volume)
  // highlight-adjustVolume-volume-slider

  // highlight-adjustVolume-mute-toggle
  // Toggle mute state and react to a force-muted block (e.g. video fill playing above 3.0x).
  let currentlyMuted = try engine.block.isMuted(mutedAudio)
  try engine.block.setMuted(mutedAudio, muted: !currentlyMuted)

  if try engine.block.isForceMuted(mutedAudio) {
    // Show a distinct "force muted" indicator in the UI.
  }
  // highlight-adjustVolume-mute-toggle

  // Remove the original audio block; only the duplicates are part of the scene.
  try engine.block.destroy(audioBlock)
}
