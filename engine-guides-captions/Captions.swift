import Foundation
import IMGLYEngine

@MainActor
func addCaptions(engine: Engine) async throws {
  // highlight-addCaptions-setupScene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.editor.setSettingBool("features/videoCaptionsEnabled", value: true)
  // highlight-addCaptions-setupScene

  // highlight-addCaptions-setPageDuration
  try engine.block.setDuration(page, duration: 20)
  // highlight-addCaptions-setPageDuration

  let baseURL = try engine.guidesBaseURL

  // highlight-addCaptions-addVideo
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
  try engine.block.setDuration(video, duration: 20)

  let videoTrack = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: videoTrack)
  try engine.block.appendChild(to: videoTrack, child: video)
  try engine.block.fillParent(videoTrack)
  // highlight-addCaptions-addVideo

  // Decode at least one video frame before exporting page snapshots so the
  // hero capture shows real footage rather than the default black poster.
  try await engine.block.forceLoadAVResource(videoFill)

  // highlight-addCaptions-createCaptionTrack
  let captionTrack = try engine.block.create(.captionTrack)
  try engine.block.appendChild(to: page, child: captionTrack)
  // highlight-addCaptions-createCaptionTrack

  // highlight-addCaptions-manageOffsets
  let manageOffsetsAutomatically = false
  try engine.block.setBool(
    captionTrack,
    property: "track/automaticallyManageBlockOffsets",
    value: manageOffsetsAutomatically,
  )
  // highlight-addCaptions-manageOffsets

  // highlight-addCaptions-createCaptions
  let caption1 = try engine.block.create(.caption)
  try engine.block.setString(caption1, property: "caption/text", value: "Caption text 1")
  let caption2 = try engine.block.create(.caption)
  try engine.block.setString(caption2, property: "caption/text", value: "Caption text 2")
  try engine.block.appendChild(to: captionTrack, child: caption1)
  try engine.block.appendChild(to: captionTrack, child: caption2)
  // highlight-addCaptions-createCaptions

  // highlight-addCaptions-setTiming
  try engine.block.setDuration(caption1, duration: 3)
  try engine.block.setDuration(caption2, duration: 5)

  try engine.block.setTimeOffset(caption1, offset: 0)
  try engine.block.setTimeOffset(caption2, offset: 3)
  // highlight-addCaptions-setTiming

  // highlight-addCaptions-importCaptions
  // Captions can also be loaded from SRT or VTT files. The text and timing of
  // each caption are read from the file. Point the URL at your own subtitle
  // file; here we write a short SRT to a temporary file for demonstration.
  let srtContents = """
  1
  00:00:08,000 --> 00:00:11,000
  Imported from an SRT file

  2
  00:00:11,000 --> 00:00:14,000
  with its own text and timing.
  """
  let srtURL = FileManager.default.temporaryDirectory.appendingPathComponent("captions.srt")
  try srtContents.write(to: srtURL, atomically: true, encoding: .utf8)

  let captions = try await engine.block.createCaptionsFromURI(srtURL)
  for caption in captions {
    try engine.block.appendChild(to: captionTrack, child: caption)
  }
  // highlight-addCaptions-importCaptions

  // highlight-addCaptions-positionSize
  // Position and size sync only with caption blocks under the same caption track,
  // so configure them once on a single caption.
  try engine.block.setPositionX(caption1, value: 0.05)
  try engine.block.setPositionXMode(caption1, mode: .percent)
  try engine.block.setPositionY(caption1, value: 0.8)
  try engine.block.setPositionYMode(caption1, mode: .percent)
  try engine.block.setHeight(caption1, value: 0.15)
  try engine.block.setHeightMode(caption1, mode: .percent)
  try engine.block.setWidth(caption1, value: 0.9)
  try engine.block.setWidthMode(caption1, mode: .percent)
  // highlight-addCaptions-positionSize

  // highlight-addCaptions-styleCaptions
  // Style properties also sync only with caption blocks under the same caption
  // track. Set text color, drop shadow, and background with dedicated styling
  // setters, then use property-keyed setters for automatic font sizing.
  try engine.block.setTextColor(caption1, color: Color.rgba(r: 0.9, g: 0.9, b: 0.0, a: 1.0))
  try engine.block.setDropShadowEnabled(caption1, enabled: true)
  try engine.block.setDropShadowColor(caption1, color: Color.rgba(r: 0.0, g: 0.0, b: 0.0, a: 0.8))
  try engine.block.setBackgroundColorEnabled(caption1, enabled: true)
  try engine.block.setBackgroundColor(caption1, r: 0.0, g: 0.0, b: 0.0, a: 0.7)
  try engine.block.setBool(caption1, property: "caption/automaticFontSizeEnabled", value: true)
  try engine.block.setFloat(caption1, property: "caption/minAutomaticFontSize", value: 24)
  try engine.block.setFloat(caption1, property: "caption/maxAutomaticFontSize", value: 72)
  // highlight-addCaptions-styleCaptions

  try await engine.captureGuide(page, label: "hero")

  // highlight-addCaptions-addAnimation
  let fadeInAnimation = try engine.block.createAnimation(.fade)
  try engine.block.setDuration(fadeInAnimation, duration: 0.3)
  try engine.block.setInAnimation(caption1, animation: fadeInAnimation)
  // highlight-addCaptions-addAnimation

  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-addCaptions-exportVideo
  // Exporting the page as MP4 burns the caption text into every rendered frame.
  let videoStream = try await engine.block.exportVideo(page, mimeType: .mp4)
  for try await event in videoStream {
    switch event {
    case let .progress(renderedFrames, encodedFrames, totalFrames):
      print("Rendered", renderedFrames, "frames and encoded", encodedFrames, "frames out of", totalFrames)
    case let .finished(video: blob):
      try blob.write(to: exportsDirectory.appendingPathComponent("captions.mp4"))
    }
  }
  // highlight-addCaptions-exportVideo
}
