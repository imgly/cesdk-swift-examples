import Foundation
import IMGLYEngine

@MainActor
func createAudioLoop(engine: Engine) async throws {
  // highlight-createAudioLoop-setup
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 30)
  // highlight-createAudioLoop-setup

  let baseURL = try engine.guidesBaseURL
  let audioURL = baseURL.appendingPathComponent("ly.img.audio/audios/far_from_home.m4a")

  // highlight-createAudioLoop-createAudioBlock
  // Create an audio block and set the audio source
  let audioBlock = try engine.block.create(.audio)
  try engine.block.setURL(audioBlock, property: "audio/fileURI", value: audioURL)
  // highlight-createAudioLoop-createAudioBlock

  // highlight-createAudioLoop-loadAudioResource
  // Load the audio resource to access metadata
  try await engine.block.forceLoadAVResource(audioBlock)

  // Get the total audio duration from the loaded resource
  let audioDuration = try engine.block.getDouble(audioBlock, property: "audio/totalDuration")
  print("Audio duration: \(String(format: "%.2f", audioDuration)) seconds")
  // highlight-createAudioLoop-loadAudioResource

  // highlight-createAudioLoop-enableLooping
  // Enable looping: a 5-second audio with a 15-second duration loops three times
  let loopingAudio = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: loopingAudio)
  try engine.block.setTimeOffset(loopingAudio, offset: 0)
  try engine.block.setLooping(loopingAudio, looping: true)
  try engine.block.setDuration(loopingAudio, duration: 15)
  // highlight-createAudioLoop-enableLooping

  // highlight-createAudioLoop-queryLoopingState
  // Check whether looping is enabled on the block
  let isLooping = try engine.block.isLooping(loopingAudio)
  print("Is looping: \(isLooping)")
  // highlight-createAudioLoop-queryLoopingState

  // highlight-createAudioLoop-nonLoopingAudio
  // Disable looping: the audio plays once and leaves silence for the remaining duration
  let nonLoopingAudio = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: nonLoopingAudio)
  try engine.block.setTimeOffset(nonLoopingAudio, offset: 16)
  try engine.block.setLooping(nonLoopingAudio, looping: false)
  try engine.block.setDuration(nonLoopingAudio, duration: 12)
  // highlight-createAudioLoop-nonLoopingAudio

  // highlight-createAudioLoop-loopingWithTrim
  // Combine trim settings with looping to repeat a short segment
  // A 2-second segment (1.0s–3.0s) with an 8-second duration loops four times
  let trimmedLoopAudio = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: trimmedLoopAudio)
  try engine.block.setTimeOffset(trimmedLoopAudio, offset: 29)
  try engine.block.setTrimOffset(trimmedLoopAudio, offset: 1.0)
  try engine.block.setTrimLength(trimmedLoopAudio, length: 2.0)
  try engine.block.setLooping(trimmedLoopAudio, looping: true)
  try engine.block.setDuration(trimmedLoopAudio, duration: 8.0)
  // highlight-createAudioLoop-loopingWithTrim

  // Remove the original unparented audio block
  try engine.block.destroy(audioBlock)

  // highlight-createAudioLoop-export
  // Save the scene to a string for storage or later rendering
  let sceneString = try await engine.scene.saveToString()
  print("Scene saved (\(sceneString.count) characters)")
  // highlight-createAudioLoop-export

  _ = audioDuration
  _ = isLooping
  _ = nonLoopingAudio
  _ = trimmedLoopAudio
  _ = sceneString
}
