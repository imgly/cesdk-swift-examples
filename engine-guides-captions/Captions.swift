import Foundation
import IMGLYEngine

@MainActor
func editVideoCaptions(engine: Engine) async throws {
  // highlight-setupScene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.editor.setSettingBool("features/videoCaptionsEnabled", value: true)
  // highlight-setupScene

  // highlight-setPageDuration
  try engine.block.setDuration(page, duration: 20)
  // highlight-setPageDuration

  // highlight-createCaptions
  let caption1 = try engine.block.create(.caption)
  try engine.block.setString(caption1, property: "caption/text", value: "Caption text 1")
  let caption2 = try engine.block.create(.caption)
  try engine.block.setString(caption2, property: "caption/text", value: "Caption text 2")
  // highlight-createCaptions

  // highlight-addToTrack
  let captionTrack = try engine.block.create(.captionTrack)
  try engine.block.appendChild(to: page, child: captionTrack)
  try engine.block.appendChild(to: captionTrack, child: caption1)
  try engine.block.appendChild(to: captionTrack, child: caption2)
  // highlight-addToTrack

  // highlight-setDuration
  try engine.block.setDuration(caption1, duration: 3)
  try engine.block.setDuration(caption2, duration: 5)
  // highlight-setDuration

  // highlight-setTimeOffset
  try engine.block.setTimeOffset(caption1, offset: 0)
  try engine.block.setTimeOffset(caption2, offset: 3)
  // highlight-setTimeOffset

  // highlight-createCaptionsFromURI
  // Captions can also be loaded from a caption file, i.e., from SRT and VTT files.
  // The text and timing of the captions are read from the file.
  let captions = try await engine.block
    .createCaptionsFromURI(URL(string: "https://img.ly/static/examples/captions.srt")!)
  for caption in captions {
    try engine.block.appendChild(to: captionTrack, child: caption)
  }
  // highlight-createCaptionsFromURI

  // highlight-positionAndSize
  // The position and size are synced with all caption blocks in the scene so only needs to be set once.
  try engine.block.setPositionX(caption1, value: 0.05)
  try engine.block.setPositionXMode(caption1, mode: .percent)
  try engine.block.setPositionY(caption1, value: 0.8)
  try engine.block.setPositionYMode(caption1, mode: .percent)
  try engine.block.setHeight(caption1, value: 0.15)
  try engine.block.setHeightMode(caption1, mode: .percent)
  try engine.block.setWidth(caption1, value: 0.9)
  try engine.block.setWidthMode(caption1, mode: .percent)
  // highlight-positionAndSize

  // highlight-changeStyle
  // The style is synced with all caption blocks in the scene so only needs to be set once.
  try engine.block.setColor(caption1, property: "fill/solid/color", color: Color.rgba(r: 0.9, g: 0.9, b: 0.0, a: 1.0))
  try engine.block.setBool(caption1, property: "dropShadow/enabled", value: true)
  try engine.block.setColor(caption1, property: "dropShadow/color", color: Color.rgba(r: 0.0, g: 0.0, b: 0.0, a: 0.8))
  // highlight-changeStyle

  // highlight-exportVideo
  // Export page as mp4 video.
  let mimeType: MIMEType = .mp4
  let exportTask = Task {
    for try await export in try await engine.block.exportVideo(page, mimeType: mimeType) {
      switch export {
      case let .progress(renderedFrames, encodedFrames, totalFrames):
        print("Rendered", renderedFrames, "frames and encoded", encodedFrames, "frames out of", totalFrames)
      case let .finished(video: videoData):
        return videoData
      }
    }
    return Blob()
  }
  let blob = try await exportTask.value
  // highlight-exportVideo
}
