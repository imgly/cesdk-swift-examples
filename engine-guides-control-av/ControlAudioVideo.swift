import Foundation
import IMGLYEngine

// swiftlint:disable for_where

@MainActor
func controlAudioVideo(engine: Engine) async throws {
  // Setup a minimal video scene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)

  // Create a video block and track
  let videoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(videoBlock, shape: try engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setString(
    videoFill,
    property: "fill/video/fileURI",
    // swiftlint:disable:next line_length
    value: "https://cdn.img.ly/assets/demo/v1/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  try engine.block.setFill(videoBlock, fill: videoFill)
  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)
  try engine.block.appendChild(to: track, child: videoBlock)
  try engine.block.fillParent(track)

  // Create an audio block
  let audio = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: audio)
  try engine.block.setString(
    audio,
    property: "audio/fileURI",
    value: "https://cdn.img.ly/assets/demo/v1/ly.img.audio/audios/far_from_home.m4a",
  )

  // Time Offset and Duration
  try engine.block.supportsTimeOffset(audio)
  try engine.block.setTimeOffset(audio, offset: 2)
  try engine.block.getTimeOffset(audio) /* Returns 2 */

  try engine.block.supportsDuration(page)
  try engine.block.setDuration(page, duration: 10)
  try engine.block.getDuration(page) /* Returns 10 */

  // Duration of the page can be that of a block
  try engine.block.supportsPageDurationSource(page, id: videoBlock)
  try engine.block.setPageDurationSource(page, id: videoBlock)
  try engine.block.isPageDurationSource(videoBlock)
  try engine.block.getDuration(page) /* Returns duration plus offset of the block */

  // Duration of the page can be the maximum end time of all page child blocks
  try engine.block.removePageDurationSource(page)
  try engine.block.getDuration(page) /* Returns the maximum end time of all page child blocks */

  // Trim
  try engine.block.supportsTrim(videoFill)
  try engine.block.setTrimOffset(videoFill, offset: 1)
  try engine.block.getTrimOffset(videoFill) /* Returns 1 */
  try engine.block.setTrimLength(videoFill, length: 5)
  try engine.block.getTrimLength(videoFill) /* Returns 5 */

  // Playback Control
  try engine.block.setPlaying(page, enabled: true)
  try engine.block.isPlaying(page)

  try engine.block.setSoloPlaybackEnabled(videoFill, enabled: true)
  try engine.block.isSoloPlaybackEnabled(videoFill)

  try engine.block.supportsPlaybackTime(page)
  try engine.block.setPlaybackTime(page, time: 1)
  try engine.block.getPlaybackTime(page)
  try engine.block.isVisibleAtCurrentPlaybackTime(videoBlock)

  try engine.block.supportsPlaybackControl(videoFill)
  try engine.block.setLooping(videoFill, looping: true)
  try engine.block.isLooping(videoFill)
  try engine.block.setMuted(videoFill, muted: true)
  try engine.block.isMuted(videoFill)
  try engine.block.setVolume(videoFill, volume: 0.5) /* 50% volume */
  try engine.block.getVolume(videoFill)

  // Playback Speed
  try engine.block.setPlaybackSpeed(videoFill, speed: 0.5) /* Half speed */
  let currentSpeed = try engine.block.getPlaybackSpeed(videoFill) /* 0.5 */
  try engine.block.setPlaybackSpeed(videoFill, speed: 2.0) /* Double speed */
  try engine.block.setPlaybackSpeed(videoFill, speed: 1.0) /* Normal speed */

  // Resource Control
  try await engine.block.forceLoadAVResource(videoFill)
  try engine.block.unstable_isAVResourceLoaded(videoFill)
  try engine.block.getAVResourceTotalDuration(videoFill)
  try engine.block.getVideoWidth(videoFill)
  try engine.block.getVideoHeight(videoFill)

  // Thumbnail Previews
  let videoThumbnailTask = Task {
    for try await thumbnail in engine.block.generateVideoThumbnailSequence(
      videoFill, /* video fill or page */
      thumbnailHeight: 128, /* width will be calculated from aspect ratio */
      timeRange: 0.5 ... 9.5, /* inclusive time range in seconds */
      numberOfFrames: 10, /* number of thumbnails to generate */
    ) {
      if Task.isCancelled { break }

      // Use the thumbnail...
    }
  }
  let audioThumbnailTask = Task {
    for try await thumbnail in engine.block.generateAudioThumbnailSequence(
      audio,
      samplesPerChunk: 20,
      timeRange: 0.5 ... 9.5,
      numberOfSamples: 10 * 20,
      numberOfChannels: 2,
    ) {
      if Task.isCancelled { break }

      // Draw wave pattern...
    }
  }

  // Piping a native camera stream into the engine
  var pixelBuffer: CVPixelBuffer?
  CVPixelBufferCreate(kCFAllocatorDefault, 600, 400, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)

  let pixelStreamFill = try engine.block.createFill(.pixelStream)
  try engine.block.setNativePixelBuffer(pixelStreamFill, buffer: pixelBuffer!)
  _ = videoThumbnailTask
  _ = audioThumbnailTask
}
