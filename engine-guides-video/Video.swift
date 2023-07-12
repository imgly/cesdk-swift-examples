import Foundation
import IMGLYEngine

@MainActor
func editVideo(engine: Engine) async throws {
  // highlight-setupScene
  let scene = try engine.scene.createVideo()
  let stack = try engine.block.find(byType: .stack).first!

  let page1 = try engine.block.create(.page)
  let page2 = try engine.block.create(.page)
  try engine.block.appendChild(to: stack, child: page1)
  try engine.block.appendChild(to: stack, child: page2)

  try engine.block.setWidth(page1, value: 1280)
  try engine.block.setHeight(page1, value: 720)
  try engine.block.setWidth(page2, value: 1280)
  try engine.block.setHeight(page2, value: 720)
  // highlight-setupScene

  // highlight-setPageDuration
  // Show the first page for 4 seconds and the second page for 20 seconds.
  try engine.block.setDuration(page1, duration: 4)
  try engine.block.setDuration(page2, duration: 20)
  // highlight-setPageDuration

  // highlight-assignVideoFill
  let rectShape = try engine.block.create(.rectShape)
  try engine.block.destroy(try engine.block.getFill(rectShape))
  let videoFill = try engine.block.createFill("video")
  try engine.block.setFill(rectShape, fill: videoFill)

  try engine.block.setString(
    videoFill,
    property: "fill/video/fileURI",
    // swiftlint:disable:next line_length
    value: "https://cdn.img.ly/assets/demo/v1/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4"
  )

  try engine.block.appendChild(to: page2, child: rectShape)
  try engine.block.setPositionX(rectShape, value: 0)
  try engine.block.setPositionY(rectShape, value: 0)
  try engine.block.setWidth(rectShape, value: try engine.block.getWidth(page2))
  try engine.block.setHeight(rectShape, value: try engine.block.getHeight(page2))
  // highlight-assignVideoFill

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
  try engine.block.appendChild(to: scene, child: audio)
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
  // Export scene as mp4 video.
  let mimeType: MIMEType = .mp4
  let exportTask = Task {
    for try await export in try await engine.block.exportVideo(scene, mimeType: mimeType) {
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
