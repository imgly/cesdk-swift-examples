import Foundation
import IMGLYEngine

@MainActor
func createVideoProgrammatic(engine: Engine) async throws {
  // highlight-createVideoProgrammatic-create-scene
  let scene = try engine.scene.createVideo()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-createVideoProgrammatic-create-scene

  let baseURL = try engine.guidesBaseURL

  let introURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  let detailURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-kampus-production-8154913.mp4",
  )

  // highlight-createVideoProgrammatic-add-video-clips
  let introClip = try makeVideoClip(engine: engine, videoURL: introURL)
  let detailClip = try makeVideoClip(engine: engine, videoURL: detailURL)
  // highlight-createVideoProgrammatic-add-video-clips

  // highlight-createVideoProgrammatic-arrange-track
  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)
  try engine.block.appendChild(to: track, child: introClip.block)
  try engine.block.appendChild(to: track, child: detailClip.block)
  try engine.block.fillParent(track)
  // highlight-createVideoProgrammatic-arrange-track

  // highlight-createVideoProgrammatic-load-media-and-timing
  // Keep the guide export short; use the clip length your app needs.
  let sampleClipDurationSeconds = 2.0

  try await engine.block.forceLoadAVResource(introClip.fill)
  let introSource = try engine.block.getAVResourceTotalDuration(introClip.fill)
  let introDuration = min(sampleClipDurationSeconds, introSource)
  try engine.block.setDuration(introClip.block, duration: introDuration)

  try await engine.block.forceLoadAVResource(detailClip.fill)
  let detailSource = try engine.block.getAVResourceTotalDuration(detailClip.fill)
  let detailDuration = min(sampleClipDurationSeconds, detailSource)
  try engine.block.setDuration(detailClip.block, duration: detailDuration)

  let pageDuration = introDuration + detailDuration
  try engine.block.setDuration(page, duration: pageDuration)
  // highlight-createVideoProgrammatic-load-media-and-timing

  // highlight-createVideoProgrammatic-export-video
  // Export a compact preview file; use your delivery size and frame rate in production.
  let exportOptions = VideoExportOptions(
    framerate: 15,
    targetWidth: 640,
    targetHeight: 360,
  )
  let exportStream = try await engine.block.exportVideo(
    page,
    mimeType: .mp4,
    options: exportOptions,
  )
  var videoData: Blob?
  for try await event in exportStream {
    switch event {
    case let .progress(rendered, encoded, total):
      let percent = total > 0 ? Int(Double(encoded) / Double(total) * 100) : 0
      print("Export \(percent)% — encoded \(encoded)/\(total) (rendered \(rendered))")
    case let .finished(video: blob):
      videoData = blob
    }
  }
  guard let videoBytes = videoData else {
    throw NSError(
      domain: "ly.img.guide",
      code: 0,
      userInfo: [NSLocalizedDescriptionKey: "exportVideo finished without a video blob."],
    )
  }
  // highlight-createVideoProgrammatic-export-video

  // highlight-createVideoProgrammatic-write-file
  let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("programmatic-video.mp4")
  try videoBytes.write(to: outputURL)
  // highlight-createVideoProgrammatic-write-file

  assert(!videoBytes.isEmpty)
  let writtenSize = try outputURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
  assert(writtenSize > 0)
}

// highlight-createVideoProgrammatic-create-video-clip-helper
private struct VideoClip {
  let block: DesignBlockID
  let fill: DesignBlockID
}

@MainActor
private func makeVideoClip(
  engine: Engine,
  videoURL: URL,
) throws -> VideoClip {
  let clip = try engine.block.create(.graphic)
  try engine.block.setShape(clip, shape: engine.block.createShape(.rect))

  let videoFill = try engine.block.createFill(.video)
  // Video fills read their media source from this Engine property key.
  try engine.block.setURL(videoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(clip, fill: videoFill)

  return VideoClip(block: clip, fill: videoFill)
}

// highlight-createVideoProgrammatic-create-video-clip-helper

// highlight-createVideoProgrammatic-create-from-video
@MainActor
func createSingleSourceVideoScene(engine: Engine) async throws -> DesignBlockID {
  let videoURL = try engine.guidesBaseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  let scene = try await engine.scene.create(fromVideo: videoURL)

  return scene
}

// highlight-createVideoProgrammatic-create-from-video
