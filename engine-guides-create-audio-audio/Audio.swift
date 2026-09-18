import Foundation
import IMGLYEngine

@MainActor
func audio(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1080)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.setDuration(page, duration: 30.0)

  let baseURL = try engine.guidesBaseURL

  // highlight-audio-create
  let audioBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: audioBlock)
  try engine.block.setURL(
    audioBlock,
    property: "audio/fileURI",
    value: baseURL.appendingPathComponent("ly.img.audio/audios/far_from_home.m4a"),
  )
  try await engine.block.forceLoadAVResource(audioBlock)
  let sourceDuration = try engine.block.getAVResourceTotalDuration(audioBlock)
  print("Audio source duration: \(sourceDuration) seconds")
  // highlight-audio-create

  // highlight-audio-videoFillSetup
  let videoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(videoBlock, shape: try engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(
    videoFill,
    property: "fill/video/fileURI",
    value: baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4"),
  )
  try engine.block.setFill(videoBlock, fill: videoFill)
  try engine.block.appendChild(to: page, child: videoBlock)
  try await engine.block.forceLoadAVResource(videoFill)
  // highlight-audio-videoFillSetup

  // highlight-audio-extract
  let extractedAudio = try engine.block.createAudioFromVideo(
    videoFill,
    trackIndex: 0,
    options: AudioFromVideoOptions(keepTrimSettings: true, muteOriginalVideo: true),
  )
  try engine.block.appendChild(to: page, child: extractedAudio)
  // highlight-audio-extract

  // highlight-audio-extractAll
  let allExtractedAudio = try engine.block.createAudiosFromVideo(
    videoFill,
    options: AudioFromVideoOptions(keepTrimSettings: true, muteOriginalVideo: false),
  )
  print("Extracted \(allExtractedAudio.count) audio track(s) from video")
  // Append each extracted block to the scene hierarchy in your app where you want it to play.
  // highlight-audio-extractAll

  // highlight-audio-trackInfo
  let trackCount = try engine.block.getAudioTrackCountFromVideo(videoFill)
  print("Video contains \(trackCount) audio track(s)")
  let tracks = try engine.block.getAudioInfoFromVideo(videoFill)
  for (listPosition, info) in tracks.enumerated() {
    print("Track at list position \(listPosition):")
    print("  codec: \(info.audioCodec)")
    print("  channels: \(info.channels)")
    print("  sample rate: \(info.sampleRate) Hz")
    print("  duration: \(info.audioDuration) s")
    print("  language: \(info.language)")
    print("  trackName: \(info.trackName)")
    print("  container trackIndex: \(info.trackIndex)")
  }
  // highlight-audio-trackInfo

  // highlight-audio-playback
  try engine.block.setPlaying(page, enabled: true)
  let isScenePlaying = try engine.block.isPlaying(page)
  print("Scene playing: \(isScenePlaying)")
  try engine.block.setPlaybackTime(page, time: 3.0)

  try engine.block.setVolume(audioBlock, volume: 0.8)
  try engine.block.setMuted(audioBlock, muted: false)
  try engine.block.setPlaybackSpeed(audioBlock, speed: 1.0)
  try engine.block.setPlaying(page, enabled: false)
  // highlight-audio-playback

  // highlight-audio-soloPlayback
  try engine.block.setSoloPlaybackEnabled(audioBlock, enabled: true)
  try engine.block.setPlaying(page, enabled: true)
  // ... preview the audio block in isolation ...
  try engine.block.setPlaying(page, enabled: false)
  try engine.block.setSoloPlaybackEnabled(audioBlock, enabled: false)
  // highlight-audio-soloPlayback

  // highlight-audio-timing
  try engine.block.setTimeOffset(audioBlock, offset: 2.0)
  try engine.block.setDuration(audioBlock, duration: 10.0)
  // highlight-audio-timing

  // highlight-audio-waveform
  let waveformStream = engine.block.generateAudioThumbnailSequence(
    audioBlock,
    samplesPerChunk: 3,
    timeRange: 0.0 ... 10.0,
    numberOfSamples: 9,
    numberOfChannels: 2,
  )
  for try await thumbnail in waveformStream {
    print("Chunk \(thumbnail.chunkIndex) → \(thumbnail.samples.count) samples")
  }
  // highlight-audio-waveform

  // highlight-audio-trim
  try engine.block.setTrimOffset(audioBlock, offset: 5.0)
  try engine.block.setTrimLength(audioBlock, length: 4.0)
  try engine.block.setLooping(audioBlock, looping: true)
  // highlight-audio-trim

  // highlight-audio-export
  let exportBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: exportBlock)
  let audioBuffer = engine.editor.createBuffer()
  try engine.editor.setBufferLength(url: audioBuffer, length: 96000)
  try engine.block.setURL(exportBlock, property: "audio/fileURI", value: audioBuffer)

  let exportStream = try await engine.block.exportAudio(
    exportBlock,
    mimeType: .wav,
    options: AudioExportOptions(skipEncoding: true),
  )
  for try await event in exportStream {
    switch event {
    case let .progress(rendered, encoded, total):
      print("Export progress: \(rendered)/\(total) rendered, \(encoded) encoded")
    case let .finished(audio):
      print("Exported \(audio.count) bytes of audio data")
    }
  }
  // highlight-audio-export
}
