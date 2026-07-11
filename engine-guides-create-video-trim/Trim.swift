import Foundation
import IMGLYEngine

@MainActor
func trim(engine: Engine) async throws {
  // highlight-trim-setupScene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 60)
  // highlight-trim-setupScene

  let baseURL = try engine.guidesBaseURL

  // highlight-trim-makeVideoBlock
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )

  func makeVideoBlock() async throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    let fill = try engine.block.createFill(.video)
    try engine.block.setURL(fill, property: "fill/video/fileURI", value: videoURL)
    try engine.block.setFill(block, fill: fill)
    try engine.block.appendChild(to: page, child: block)
    try await engine.block.forceLoadAVResource(fill)
    try engine.block.setDuration(block, duration: 10)
    return block
  }
  // highlight-trim-makeVideoBlock

  // highlight-trim-sourceDuration
  let videoBlock = try await makeVideoBlock()
  let videoFill = try engine.block.getFill(videoBlock)
  let sourceDuration = try engine.block.getAVResourceTotalDuration(videoFill)
  print("Source media duration: \(sourceDuration)s")
  // highlight-trim-sourceDuration

  // highlight-trim-checkSupport
  let canTrim = try engine.block.supportsTrim(videoFill)
  print("Video fill supports trimming: \(canTrim)")
  // highlight-trim-checkSupport

  // highlight-trim-applyTrim
  try engine.block.setTrimOffset(videoFill, offset: 2.0)
  try engine.block.setTrimLength(videoFill, length: 5.0)
  // highlight-trim-applyTrim

  // highlight-trim-readTrimValues
  let trimOffset = try engine.block.getTrimOffset(videoFill)
  let trimLength = try engine.block.getTrimLength(videoFill)
  print("Playing \(trimLength)s starting at \(trimOffset)s into the source")
  // highlight-trim-readTrimValues

  // highlight-trim-withDuration
  let durationBlock = try await makeVideoBlock()
  let durationFill = try engine.block.getFill(durationBlock)
  try engine.block.setLooping(durationFill, looping: false)
  try engine.block.setTrimOffset(durationFill, offset: 3.0)
  try engine.block.setTrimLength(durationFill, length: 5.0)
  if try engine.block.supportsDuration(durationBlock) {
    try engine.block.setDuration(durationBlock, duration: 5.0)
  }
  // highlight-trim-withDuration

  // highlight-trim-withLooping
  let loopBlock = try await makeVideoBlock()
  let loopFill = try engine.block.getFill(loopBlock)
  try engine.block.setLooping(loopFill, looping: true)
  try engine.block.setTrimOffset(loopFill, offset: 5.0)
  try engine.block.setTrimLength(loopFill, length: 3.0)
  try engine.block.setDuration(loopBlock, duration: 9.0)
  print("Looping enabled: \(try engine.block.isLooping(loopFill))")
  // highlight-trim-withLooping

  // highlight-trim-frameAccurate
  let frameBlock = try await makeVideoBlock()
  let frameFill = try engine.block.getFill(frameBlock)
  // Supply the frame rate from your media pipeline; iOS does not expose
  // source frame rate through the Engine API.
  let knownFrameRate = 30.0
  let startFrame = 60
  let frameCount = 150
  try engine.block.setTrimOffset(frameFill, offset: Double(startFrame) / knownFrameRate)
  try engine.block.setTrimLength(frameFill, length: Double(frameCount) / knownFrameRate)
  // highlight-trim-frameAccurate

  // highlight-trim-batchVideos
  let trimmableFills = try engine.block.find(byType: .graphic)
    .map { try engine.block.getFill($0) }
    .filter { try engine.block.supportsTrim($0) }
  for fill in trimmableFills {
    try await engine.block.forceLoadAVResource(fill)
    if try engine.block.getAVResourceTotalDuration(fill) >= 4.0 {
      try engine.block.setTrimOffset(fill, offset: 1.0)
      try engine.block.setTrimLength(fill, length: 3.0)
    }
  }
  // highlight-trim-batchVideos

  // highlight-trim-audio
  let audioBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: audioBlock)
  let audioURL = baseURL.appendingPathComponent("ly.img.audio/audios/far_from_home.m4a")
  try engine.block.setURL(audioBlock, property: "audio/fileURI", value: audioURL)
  try await engine.block.forceLoadAVResource(audioBlock)
  try engine.block.setTrimOffset(audioBlock, offset: 1.0)
  try engine.block.setTrimLength(audioBlock, length: 8.0)
  try engine.block.setTimeOffset(audioBlock, offset: 2.0)
  try engine.block.setDuration(audioBlock, duration: 8.0)
  try engine.block.setVolume(audioBlock, volume: 0.7)
  // highlight-trim-audio
}
