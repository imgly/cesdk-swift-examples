import Foundation
import IMGLYEngine

// swiftlint:disable cyclomatic_complexity

@MainActor
func exportToMp4(engine: Engine) async throws {
  // Demo scaffolding: build a video scene with a single page and a video fill so
  // the exportVideo calls below have something to encode. In your app you would
  // start from a scene already loaded into the editor instead.
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 5)

  let video = try engine.block.create(.graphic)
  try engine.block.setShape(video, shape: engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setString(
    videoFill,
    property: "fill/video/fileURI",
    // swiftlint:disable:next line_length
    value: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.1-rc.0/assets/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  try engine.block.setFill(video, fill: videoFill)
  try engine.block.appendChild(to: page, child: video)
  try engine.block.fillParent(video)

  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-exportToMp4-exportVideo
  let videoStream = try await engine.block.exportVideo(page, mimeType: .mp4)
  for try await event in videoStream {
    if case let .finished(video: blob) = event {
      try blob.write(to: exportsDirectory.appendingPathComponent("video.mp4"))
    }
  }
  // highlight-exportToMp4-exportVideo

  // highlight-exportToMp4-progress
  let progressStream = try await engine.block.exportVideo(page, mimeType: .mp4)
  for try await event in progressStream {
    switch event {
    case let .progress(rendered, encoded, total):
      let percent = total > 0 ? Int(Double(encoded) / Double(total) * 100) : 0
      print("Export \(percent)% — encoded \(encoded)/\(total) (rendered \(rendered))")
    case let .finished(video: blob):
      try blob.write(to: exportsDirectory.appendingPathComponent("progress.mp4"))
    }
  }
  // highlight-exportToMp4-progress

  // highlight-exportToMp4-cancel
  let exportTask = Task { () -> Blob in
    let stream = try await engine.block.exportVideo(page, mimeType: .mp4)
    for try await event in stream {
      try Task.checkCancellation()
      if case let .finished(video: blob) = event {
        return blob
      }
    }
    throw CancellationError()
  }
  // Call exportTask.cancel() from another task to abort the export.
  let exportedBlob = try await exportTask.value
  try exportedBlob.write(to: exportsDirectory.appendingPathComponent("cancellable.mp4"))
  // highlight-exportToMp4-cancel

  // highlight-exportToMp4-resolution
  let resolutionOptions = VideoExportOptions(
    framerate: 30,
    targetWidth: 1920,
    targetHeight: 1080,
  )
  let resolutionStream = try await engine.block.exportVideo(page, mimeType: .mp4, options: resolutionOptions)
  for try await event in resolutionStream {
    if case let .finished(video: blob) = event {
      try blob.write(to: exportsDirectory.appendingPathComponent("video-1080p.mp4"))
    }
  }
  // highlight-exportToMp4-resolution

  // highlight-exportToMp4-quality
  let qualityOptions = VideoExportOptions(
    h264Profile: .high,
    h264Level: 52,
    videoBitrate: 8_000_000,
  )
  let qualityStream = try await engine.block.exportVideo(page, mimeType: .mp4, options: qualityOptions)
  for try await event in qualityStream {
    if case let .finished(video: blob) = event {
      try blob.write(to: exportsDirectory.appendingPathComponent("video-high.mp4"))
    }
  }
  // highlight-exportToMp4-quality

  // highlight-exportToMp4-partial
  let partialOptions = VideoExportOptions(
    timeOffset: 1,
    duration: 2,
  )
  let partialStream = try await engine.block.exportVideo(page, mimeType: .mp4, options: partialOptions)
  for try await event in partialStream {
    if case let .finished(video: blob) = event {
      try blob.write(to: exportsDirectory.appendingPathComponent("video-clip.mp4"))
    }
  }
  // highlight-exportToMp4-partial
}

// swiftlint:enable cyclomatic_complexity
