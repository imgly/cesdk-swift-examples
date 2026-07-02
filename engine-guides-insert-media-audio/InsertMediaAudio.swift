import Foundation
import IMGLYEngine

@MainActor
func insertMediaAudio(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.setDuration(page, duration: 30)

  let baseURL = try engine.guidesBaseURL

  // highlight-insertMediaAudio-createAudioBlock
  // Create an audio block, point it at an audio file, and append it to a page.
  let audioBlock = try engine.block.create(.audio)
  try engine.block.setURL(
    audioBlock,
    property: "audio/fileURI",
    value: baseURL.appendingPathComponent("ly.img.audio/audios/far_from_home.m4a"),
  )
  try engine.block.appendChild(to: page, child: audioBlock)
  // highlight-insertMediaAudio-createAudioBlock

  // highlight-insertMediaAudio-configureTimeline
  // Wait for the audio resource to load before reading metadata such as duration.
  try await engine.block.forceLoadAVResource(audioBlock)

  // Start playback at the beginning of the timeline and clamp the duration to
  // the page length or the source file, whichever is shorter.
  let totalDuration = try engine.block.getAVResourceTotalDuration(audioBlock)
  try engine.block.setTimeOffset(audioBlock, offset: 0)
  try engine.block.setDuration(audioBlock, duration: min(totalDuration, 30))
  // highlight-insertMediaAudio-configureTimeline

  // highlight-insertMediaAudio-adjustVolume
  // Set the audio level. Volume is a Float ranging from 0.0 (silent) to 1.0 (full).
  try engine.block.setVolume(audioBlock, volume: 0.8)
  let currentVolume = try engine.block.getVolume(audioBlock)
  print(String(format: "Audio volume: %.0f%%", currentVolume * 100))
  // highlight-insertMediaAudio-adjustVolume

  // highlight-insertMediaAudio-muteAudio
  // Silence the block without changing the configured volume, then read the state back.
  try engine.block.setMuted(audioBlock, muted: true)
  let muted = try engine.block.isMuted(audioBlock)
  print("Audio muted: \(muted)")
  // highlight-insertMediaAudio-muteAudio

  // highlight-insertMediaAudio-loopAudio
  // Enable looping so the source repeats until the block's timeline duration ends.
  try engine.block.setLooping(audioBlock, looping: true)
  let looping = try engine.block.isLooping(audioBlock)
  print("Audio looping: \(looping)")
  // highlight-insertMediaAudio-loopAudio

  // highlight-insertMediaAudio-findAudioBlocks
  // Iterate every audio block in the scene and read its current configuration.
  let audioBlocks = try engine.block.find(byType: .audio)
  for block in audioBlocks {
    let uri = try engine.block.getString(block, property: "audio/fileURI")
    let offset = try engine.block.getTimeOffset(block)
    let duration = try engine.block.getDuration(block)
    let volume = try engine.block.getVolume(block)
    print(String(format: "Audio %u — offset %.1fs, duration %.1fs, volume %.0f%%, uri %@",
                 block, offset, duration, volume * 100, uri))
  }
  // highlight-insertMediaAudio-findAudioBlocks

  // highlight-insertMediaAudio-removeAudio
  // Destroy the block to remove it from the scene and free its resources.
  try engine.block.destroy(audioBlock)
  // highlight-insertMediaAudio-removeAudio
}
