import Foundation
import IMGLYEngine

@MainActor
func editVideo(engine: Engine) async throws {
  // highlight-setupScene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  // highlight-setupScene

  // highlight-setPageDuration
  try engine.block.setDuration(page, duration: 20)
  // highlight-setPageDuration

  // highlight-assignVideoFill
  let video1 = try engine.block.create(.graphic)
  try engine.block.setShape(video1, shape: engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setString(
    videoFill,
    property: "fill/video/fileURI",
    // swiftlint:disable:next line_length
    value: "https://cdn.img.ly/assets/demo/v1/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4"
  )
  try engine.block.setFill(video1, fill: videoFill)

  let video2 = try engine.block.create(.graphic)
  try engine.block.setShape(video2, shape: engine.block.createShape(.rect))
  let videoFill2 = try engine.block.createFill(.video)
  try engine.block.setString(
    videoFill2,
    property: "fill/video/fileURI",
    value: "https://cdn.img.ly/assets/demo/v2/ly.img.video/videos/pexels-kampus-production-8154913.mp4"
  )
  try engine.block.setFill(video2, fill: videoFill2)
  // highlight-assignVideoFill

  // highlight-addToTrack
  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)
  try engine.block.appendChild(to: track, child: video1)
  try engine.block.appendChild(to: track, child: video2)
  try engine.block.fillParent(track)
  // highlight-addToTrack

  // highlight-setDuration
  try engine.block.setDuration(video1, duration: 15)
  // highlight-setDuration

  // highlight-trim
  // Make sure that the video is loaded before calling the trim APIs.
  try await engine.block.forceLoadAVResource(videoFill)
  try engine.block.setTrimOffset(videoFill, offset: 1)
  try engine.block.setTrimLength(videoFill, length: 10)
  // highlight-trim

  // highlight-looping
  try engine.block.setLooping(videoFill, looping: true)

  // highlight-mute-audio
  try engine.block.setMuted(videoFill, muted: true)

  // highlight-audio
  let audio = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: audio)
  try engine.block.setString(
    audio,
    property: "audio/fileURI",
    value: "https://cdn.img.ly/assets/demo/v1/ly.img.audio/audios/far_from_home.m4a"
  )
  // highlight-audio

  // highlight-audio-volume
  // Set the volume level to 70%.
  try engine.block.setVolume(audio, volume: 0.7)
  // highlight-audio-volume

  // highlight-timeOffset
  // Start the audio after two seconds of playback.
  try engine.block.setTimeOffset(audio, offset: 2)
  // highlight-timeOffset

  // highlight-audioDuration
  // Give the Audio block a duration of 7 seconds.
  try engine.block.setDuration(audio, duration: 7)
  // highlight-audioDuration

  // highlight-exportVideo
  // Export page as mp4 video.
  let mimeType: MIMEType = .mp4
  let exportTask = Task {
    for try await export in try await engine.block.exportVideo(page, mimeType: mimeType) {
      switch export {
      case let .progress(renderedFrames, encodedFrames, totalFrames):
        print("Rendered", renderedFrames, "frames and encoded", encodedFrames, "frames out of", totalFrames)
      case let .finished(video: videoData):
        return videoData
      }
    }
    return Blob()
  }
  let blob = try await exportTask.value
  // highlight-exportVideo
}
