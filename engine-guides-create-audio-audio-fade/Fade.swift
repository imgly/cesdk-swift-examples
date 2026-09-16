import Foundation
import IMGLYEngine

@MainActor
func fadeAudio(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 30)

  let baseURL = try engine.guidesBaseURL
  let audioURL = baseURL.appendingPathComponent("ly.img.audio/audios/dance_harder.m4a")
  let videoURL = baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4")

  // highlight-fadeAudio-create-audio
  // Create an audio block, load its resource, and give it a duration on the timeline.
  let audioBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: audioBlock)
  try engine.block.setURL(audioBlock, property: "audio/fileURI", value: audioURL)
  try await engine.block.forceLoadAVResource(audioBlock)

  try engine.block.setTimeOffset(audioBlock, offset: 0)
  try engine.block.setDuration(audioBlock, duration: 12)
  try engine.block.setVolume(audioBlock, volume: 0.8)
  // highlight-fadeAudio-create-audio

  // highlight-fadeAudio-fade-in
  // Ramp up from silence over the first 3 seconds of the clip.
  try engine.block.setAudioFadeIn(audioBlock, duration: 3.0)
  // highlight-fadeAudio-fade-in

  // highlight-fadeAudio-fade-out
  // Ramp down to silence over the last 2 seconds of the clip.
  try engine.block.setAudioFadeOut(audioBlock, duration: 2.0)
  // highlight-fadeAudio-fade-out

  // highlight-fadeAudio-easing
  // A second clip that eases in and out instead of ramping linearly.
  let easedAudio = try engine.block.duplicate(audioBlock)
  try engine.block.appendChild(to: page, child: easedAudio)
  try engine.block.setTimeOffset(easedAudio, offset: 14)
  try engine.block.setDuration(easedAudio, duration: 12)
  try engine.block.setAudioFadeIn(easedAudio, duration: 3.0, easing: .easeInOut)
  try engine.block.setAudioFadeOut(easedAudio, duration: 3.0, easing: .easeOut)
  // highlight-fadeAudio-easing

  // Build a video block whose fill carries the embedded audio.
  let videoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(videoBlock, shape: engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(videoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(videoBlock, fill: videoFill)
  try engine.block.appendChild(to: page, child: videoBlock)
  try engine.block.fillParent(videoBlock)
  try await engine.block.forceLoadAVResource(videoFill)
  try engine.block.setDuration(videoBlock, duration: 10)

  // highlight-fadeAudio-video-fill
  // Video audio lives on the video fill, so resolve the fill first — exactly as with `setVolume`.
  let fill = try engine.block.getFill(videoBlock)
  try engine.block.setAudioFadeIn(fill, duration: 1.5)
  try engine.block.setAudioFadeOut(fill, duration: 1.5, easing: .easeOut)
  // highlight-fadeAudio-video-fill

  // highlight-fadeAudio-read-fades
  // Read the configuration back through the block properties to drive UI controls.
  let fadeInDuration = try engine.block.getDouble(audioBlock, property: "playback/fadeIn/duration")
  let fadeInEasing = try engine.block.getEnum(audioBlock, property: "playback/fadeIn/easing")
  let fadeOutDuration = try engine.block.getDouble(audioBlock, property: "playback/fadeOut/duration")
  let fadeOutEasing = try engine.block.getEnum(audioBlock, property: "playback/fadeOut/easing")

  print("Fade in: \(fadeInDuration)s (\(fadeInEasing))")
  print("Fade out: \(fadeOutDuration)s (\(fadeOutEasing))")
  // highlight-fadeAudio-read-fades

  // highlight-fadeAudio-remove-fade
  // A duration of 0 removes a fade again.
  try engine.block.setAudioFadeOut(audioBlock, duration: 0)
  let removedFadeOut = try engine.block.getDouble(audioBlock, property: "playback/fadeOut/duration")
  print("Fade out after removal: \(removedFadeOut)s")
  // highlight-fadeAudio-remove-fade
}
