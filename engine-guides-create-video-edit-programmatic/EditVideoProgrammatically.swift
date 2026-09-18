import Foundation
import IMGLYEngine

@MainActor
func editVideoProgrammatically(engine: Engine) async throws {
  // highlight-editVideoProgrammatically-create-video-scene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 4.0)
  // highlight-editVideoProgrammatically-create-video-scene

  let baseURL = try engine.guidesBaseURL

  // highlight-editVideoProgrammatically-add-clips
  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)
  try engine.block.fillParent(track)

  let firstClip = try engine.block.create(.graphic)
  try engine.block.setShape(firstClip, shape: engine.block.createShape(.rect))
  let firstVideoFill = try engine.block.createFill(.video)
  try engine.block.setURL(
    firstVideoFill,
    property: "fill/video/fileURI",
    value: baseURL.appendingPathComponent(
      "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
    ),
  )
  try engine.block.setFill(firstClip, fill: firstVideoFill)
  try engine.block.setContentFillMode(firstClip, mode: .cover)

  let secondClipURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-kampus-production-8154913.mp4",
  )
  let secondClip = try engine.block.create(.graphic)
  try engine.block.setShape(secondClip, shape: engine.block.createShape(.rect))
  let secondVideoFill = try engine.block.createFill(.video)
  try engine.block.setURL(secondVideoFill, property: "fill/video/fileURI", value: secondClipURL)
  try engine.block.setFill(secondClip, fill: secondVideoFill)
  try engine.block.setContentFillMode(secondClip, mode: .cover)

  try engine.block.appendChild(to: track, child: firstClip)
  try engine.block.appendChild(to: track, child: secondClip)
  // highlight-editVideoProgrammatically-add-clips

  // highlight-editVideoProgrammatically-change-timing-trim
  try await engine.block.forceLoadAVResource(firstVideoFill)
  try await engine.block.forceLoadAVResource(secondVideoFill)

  try engine.block.setDuration(firstClip, duration: 2.0)
  try engine.block.setDuration(secondClip, duration: 2.0)
  try engine.block.setTrimOffset(firstVideoFill, offset: 1.0)
  try engine.block.setTrimLength(firstVideoFill, length: 2.0)
  // highlight-editVideoProgrammatically-change-timing-trim

  // highlight-editVideoProgrammatically-split-clip
  let secondSegment = try engine.block.split(
    secondClip,
    atTime: 1.0,
    options: SplitOptions(selectNewBlock: false),
  )
  // highlight-editVideoProgrammatically-split-clip

  // highlight-editVideoProgrammatically-timed-overlay
  let overlay = try engine.block.create(.graphic)
  try engine.block.setShape(overlay, shape: engine.block.createShape(.rect))
  let overlayFill = try engine.block.createFill(.color)
  try engine.block.setFill(overlay, fill: overlayFill)
  try engine.block.setColor(
    overlayFill,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.82, b: 0.1, a: 0.85),
  )
  try engine.block.setWidth(overlay, value: 1280)
  try engine.block.setHeight(overlay, value: 72)
  try engine.block.setPositionY(overlay, value: 648)
  try engine.block.setTimeOffset(overlay, offset: 1.25)
  try engine.block.setDuration(overlay, duration: 1.5)
  try engine.block.appendChild(to: page, child: overlay)
  // highlight-editVideoProgrammatically-timed-overlay

  // highlight-editVideoProgrammatically-export-video
  let mimeType: MIMEType = .mp4
  let options = VideoExportOptions(
    videoBitrate: 8_000_000,
    audioBitrate: 128_000,
    framerate: 30,
    targetWidth: 1280,
    targetHeight: 720,
  )
  let exportTask = Task {
    for try await export in try await engine.block.exportVideo(page, mimeType: mimeType, options: options) {
      switch export {
      case let .progress(renderedFrames, _, totalFrames):
        print("Rendered", renderedFrames, "of", totalFrames, "frames")
      case let .finished(video: videoData):
        return videoData
      }
    }
    return Blob()
  }
  let editedVideo = try await exportTask.value
  precondition(editedVideo.count > 0)
  // highlight-editVideoProgrammatically-export-video

  // Keep references alive past their highlight blocks so SwiftLint doesn't
  // flag them — the rendered guide never shows these lines.
  _ = scene
  _ = secondSegment
}
