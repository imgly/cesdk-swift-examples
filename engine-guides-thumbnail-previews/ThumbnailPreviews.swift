import CoreGraphics
import Foundation
import IMGLYEngine
import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

@MainActor
func thumbnailPreviews(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  let audioURL = baseURL.appendingPathComponent("ly.img.audio/audios/far_from_home.m4a")

  // Demo scaffolding: a ten-second video page carrying one video clip and one
  // audio clip, so every sequence below previews real media. In your app you
  // start from a scene the user is already editing.
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 10)

  let videoTrack = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: videoTrack)

  let clip = try engine.block.create(.graphic)
  try engine.block.setShape(clip, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(clip, value: 1280)
  try engine.block.setHeight(clip, value: 720)

  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(videoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(clip, fill: videoFill)
  try engine.block.appendChild(to: videoTrack, child: clip)

  let audioTrack = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: audioTrack)

  let audioClip = try engine.block.create(.audio)
  try engine.block.setURL(audioClip, property: "audio/fileURI", value: audioURL)
  try engine.block.appendChild(to: audioTrack, child: audioClip)

  // Loading the media up front stops the first request from returning before
  // the resource is ready.
  try await engine.block.forceLoadAVResource(videoFill)
  try await engine.block.forceLoadAVResource(audioClip)
  try engine.block.setDuration(clip, duration: 8)
  try engine.block.setDuration(audioClip, duration: 10)

  // highlight-tpios-filmstrip
  let frameCount = 8
  var filmstrip = [CGImage?](repeating: nil, count: frameCount)

  for try await frame in engine.block.generateVideoThumbnailSequence(
    videoFill,
    thumbnailHeight: 72,
    timeRange: 0 ... 8,
    numberOfFrames: frameCount,
  ) {
    // Frames arrive one at a time and carry their own position, so write each
    // one to the slot it reports instead of appending in arrival order.
    guard filmstrip.indices.contains(frame.frameIndex) else { continue }
    filmstrip[frame.frameIndex] = frame.image
  }
  // highlight-tpios-filmstrip

  // highlight-tpios-image
  guard let firstFrame = filmstrip[0] else {
    fatalError("Expected the filmstrip to start at frame 0.")
  }
  // `VideoThumbnail` carries no size of its own — read it off the `CGImage`.
  print("Frame 0 is \(firstFrame.width)x\(firstFrame.height) pixels")

  // SwiftUI renders a `CGImage` directly, on every Apple platform.
  let preview = Image(decorative: firstFrame, scale: 1)

  #if canImport(UIKit)
    // A UIKit view takes the same `CGImage` wrapped in a `UIImage`.
    let uiPreview = UIImage(cgImage: firstFrame)
    print("UIKit preview size: \(uiPreview.size)")
  #endif
  // highlight-tpios-image
  _ = preview

  // highlight-tpios-storyboard
  var storyboard = [Int: CGImage]()

  for try await frame in engine.block.generateVideoThumbnailSequence(
    page,
    thumbnailHeight: 108,
    timeRange: 0 ... 10,
    numberOfFrames: 5,
  ) {
    storyboard[frame.frameIndex] = frame.image
  }
  print("Storyboard holds \(storyboard.count) composed frames")
  // highlight-tpios-storyboard

  // highlight-tpios-waveform
  let samplesPerChunk = 64
  let numberOfSamples = 200
  let numberOfChannels = 2
  var waveform = [Float]()
  var receivedChunks = 0

  for try await chunk in engine.block.generateAudioThumbnailSequence(
    audioClip,
    samplesPerChunk: samplesPerChunk,
    timeRange: 0 ... 10,
    numberOfSamples: numberOfSamples,
    numberOfChannels: numberOfChannels,
  ) {
    receivedChunks += 1
    // Stereo samples are interleaved, left channel first. Step by the channel
    // count to read one channel; the values are already a 0...1 envelope.
    for index in stride(from: 0, to: chunk.samples.count, by: numberOfChannels) {
      waveform.append(chunk.samples[index])
    }
  }

  // The engine sends exactly this many chunks, and the last one may be short.
  let expectedChunks = Int(ceil(Double(numberOfSamples) / Double(samplesPerChunk)))
  print("Waveform: \(waveform.count) bars in \(receivedChunks) of \(expectedChunks) chunks")
  // highlight-tpios-waveform

  // highlight-tpios-single-frame
  var posterFrame: CGImage?

  for try await frame in engine.block.generateVideoThumbnailSequence(
    page,
    thumbnailHeight: 256,
    timeRange: 2 ... 2,
    numberOfFrames: 1,
  ) {
    posterFrame = frame.image
  }
  print("Poster frame: \(posterFrame?.width ?? 0)x\(posterFrame?.height ?? 0)")
  // highlight-tpios-single-frame

  // highlight-tpios-cancel
  // There is no cancel method. Leaving the loop drops the stream's iterator,
  // which cancels the request on the engine's next tick.
  var scrubbed = [CGImage]()

  for try await frame in engine.block.generateVideoThumbnailSequence(
    videoFill,
    thumbnailHeight: 72,
    timeRange: 0 ... 8,
    numberOfFrames: 64,
  ) {
    scrubbed.append(frame.image)
    if scrubbed.count == 4 {
      break
    }
  }

  // In a view, own the iteration in a `Task` — SwiftUI's `.task(id:)` does this
  // for you — so replacing or dismissing the view cancels the request it made.
  let storyboardTask = Task { @MainActor in
    var received = 0
    for try await _ in engine.block.generateVideoThumbnailSequence(
      page,
      thumbnailHeight: 108,
      timeRange: 0 ... 10,
      numberOfFrames: 40,
    ) {
      try Task.checkCancellation()
      received += 1
    }
    return received
  }
  storyboardTask.cancel()

  let deliveredBeforeCancel = (try? await storyboardTask.value) ?? 0
  print("Stopped after \(scrubbed.count) frames; cancelled task saw \(deliveredBeforeCancel)")
  // highlight-tpios-cancel
}
