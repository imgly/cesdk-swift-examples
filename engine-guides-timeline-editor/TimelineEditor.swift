import Foundation
import IMGLYEngine

@MainActor
func timelineEditor(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let primaryURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  let overlayURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-kampus-production-8154913.mp4",
  )
  let audioURL = baseURL.appendingPathComponent("ly.img.audio/audios/far_from_home.m4a")

  // highlight-timelineEditor-create-video-scene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 10)
  // highlight-timelineEditor-create-video-scene

  // highlight-timelineEditor-create-tracks
  let primaryTrack = try engine.block.create(.track)
  let overlayTrack = try engine.block.create(.track)
  let audioTrack = try engine.block.create(.track)

  try engine.block.appendChild(to: page, child: primaryTrack)
  try engine.block.appendChild(to: page, child: overlayTrack)
  try engine.block.appendChild(to: page, child: audioTrack)

  try engine.block.setBool(overlayTrack, property: "track/automaticallyManageBlockOffsets", value: false)
  // highlight-timelineEditor-create-tracks

  // highlight-timelineEditor-add-clips
  let primaryClip = try engine.block.create(.graphic)
  try engine.block.setShape(primaryClip, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(primaryClip, value: 0)
  try engine.block.setPositionY(primaryClip, value: 0)
  try engine.block.setWidth(primaryClip, value: 1280)
  try engine.block.setHeight(primaryClip, value: 720)

  let primaryFill = try engine.block.createFill(.video)
  try engine.block.setURL(primaryFill, property: "fill/video/fileURI", value: primaryURL)
  try engine.block.setFill(primaryClip, fill: primaryFill)
  try engine.block.appendChild(to: primaryTrack, child: primaryClip)

  let overlayClip = try engine.block.create(.graphic)
  try engine.block.setShape(overlayClip, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(overlayClip, value: 820)
  try engine.block.setPositionY(overlayClip, value: 80)
  try engine.block.setWidth(overlayClip, value: 360)
  try engine.block.setHeight(overlayClip, value: 220)

  let overlayFill = try engine.block.createFill(.video)
  try engine.block.setURL(overlayFill, property: "fill/video/fileURI", value: overlayURL)
  try engine.block.setFill(overlayClip, fill: overlayFill)
  try engine.block.appendChild(to: overlayTrack, child: overlayClip)

  let audioClip = try engine.block.create(.audio)
  try engine.block.setURL(audioClip, property: "audio/fileURI", value: audioURL)
  try engine.block.appendChild(to: audioTrack, child: audioClip)
  // highlight-timelineEditor-add-clips

  // highlight-timelineEditor-trim-and-position
  try await engine.block.forceLoadAVResource(primaryFill)
  try await engine.block.forceLoadAVResource(overlayFill)
  try await engine.block.forceLoadAVResource(audioClip)

  try engine.block.setDuration(primaryClip, duration: 8)
  try engine.block.setTrimOffset(primaryFill, offset: 2)
  try engine.block.setTrimLength(primaryFill, length: 8)
  try engine.block.setLooping(primaryFill, looping: false)
  try engine.block.setMuted(primaryFill, muted: true)

  try engine.block.setTimeOffset(overlayClip, offset: 3)
  try engine.block.setDuration(overlayClip, duration: 4)
  try engine.block.setTimeOffset(audioClip, offset: 0)
  try engine.block.setDuration(audioClip, duration: 10)
  // highlight-timelineEditor-trim-and-position

  // highlight-timelineEditor-playback
  try engine.block.setPlaybackTime(page, time: 3.5)
  let overlayVisible = try engine.block.isVisibleAtCurrentPlaybackTime(overlayClip)
  print("Overlay visible at 3.5s:", overlayVisible)

  try engine.block.setPlaying(page, enabled: true)
  print("Page is playing:", try engine.block.isPlaying(page))
  try engine.block.setPlaying(page, enabled: false)
  // highlight-timelineEditor-playback

  // highlight-timelineEditor-thumbnails
  var videoThumbnails: [VideoThumbnail] = []
  for try await thumbnail in engine.block.generateVideoThumbnailSequence(
    primaryFill,
    thumbnailHeight: 72,
    timeRange: 0.0 ... 8.0,
    numberOfFrames: 4,
  ) {
    videoThumbnails.append(thumbnail)
  }

  var audioChunks: [AudioThumbnail] = []
  for try await chunk in engine.block.generateAudioThumbnailSequence(
    audioClip,
    samplesPerChunk: 40,
    timeRange: 0.0 ... 10.0,
    numberOfSamples: 160,
    numberOfChannels: 2,
  ) {
    audioChunks.append(chunk)
  }
  print("Received \(videoThumbnails.count) video frames and \(audioChunks.count) waveform chunks")
  // highlight-timelineEditor-thumbnails

  // highlight-timelineEditor-export
  let exportsDirectory = FileManager.default.temporaryDirectory
  let exportStream = try await engine.block.exportVideo(page, mimeType: .mp4)
  for try await event in exportStream {
    switch event {
    case let .progress(renderedFrames, encodedFrames, totalFrames):
      print("Rendered \(renderedFrames) / encoded \(encodedFrames) of \(totalFrames) frames")
    case let .finished(video: blob):
      try blob.write(to: exportsDirectory.appendingPathComponent("timeline.mp4"))
    }
  }
  // highlight-timelineEditor-export
}
