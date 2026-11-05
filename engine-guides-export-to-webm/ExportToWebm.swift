import Foundation
import IMGLYEngine

@MainActor
func exportToWebm(engine: Engine) async throws {
  // Demo scaffolding: build a video scene with a single page and a video fill so
  // the exportVideo calls below have something to encode. In your app you would
  // start from a scene already loaded into the editor instead.
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 2)

  let baseURL = try engine.guidesBaseURL

  let video = try engine.block.create(.graphic)
  try engine.block.setShape(video, shape: engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(
    videoFill,
    property: "fill/video/fileURI",
    value: baseURL.appendingPathComponent(
      "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
    ),
  )
  try engine.block.setFill(video, fill: videoFill)
  try engine.block.appendChild(to: page, child: video)
  try engine.block.fillParent(video)

  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-exportToWebm-exportVideo
  let videoStream = try await engine.block.exportVideo(page, mimeType: .webm)
  for try await event in videoStream {
    switch event {
    case let .progress(_, encoded, total):
      print("Encoded \(encoded) of \(total) frames")
    case let .finished(video: blob):
      try blob.write(to: exportsDirectory.appendingPathComponent("video.webm"))
    }
  }
  // highlight-exportToWebm-exportVideo

  // highlight-exportToWebm-codecs
  let codecOptions = VideoExportOptions(
    videoBitrate: 4_000_000,
    videoCodec: .vp8,
    audioCodec: .vorbis,
  )
  let codecStream = try await engine.block.exportVideo(page, mimeType: .webm, options: codecOptions)
  for try await event in codecStream {
    if case let .finished(video: blob) = event {
      try blob.write(to: exportsDirectory.appendingPathComponent("video-vp8.webm"))
    }
  }
  // highlight-exportToWebm-codecs

  // highlight-exportToWebm-alpha
  // Shrink the video and hide the page background, so the area around the video is transparent.
  try engine.block.setFillEnabled(page, enabled: false)
  try engine.block.setWidth(video, value: 640)
  try engine.block.setHeight(video, value: 360)

  let alphaOptions = VideoExportOptions(videoCodec: .vp9, exportAlpha: true)
  let alphaStream = try await engine.block.exportVideo(page, mimeType: .webm, options: alphaOptions)
  for try await event in alphaStream {
    if case let .finished(video: blob) = event {
      try blob.write(to: exportsDirectory.appendingPathComponent("video-alpha.webm"))
    }
  }
  // highlight-exportToWebm-alpha
}
