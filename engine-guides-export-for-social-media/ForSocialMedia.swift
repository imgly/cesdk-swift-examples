import Foundation
import IMGLYEngine

@MainActor
func forSocialMedia(engine: Engine) async throws {
  // highlight-forSocialMedia-createScene
  let scene = try engine.scene.createVideo()
  try engine.scene.setDesignUnit(.px)
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1080)
  try engine.block.setHeight(page, value: 1920)
  // highlight-forSocialMedia-createScene

  // highlight-forSocialMedia-addVideo
  let videoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(videoBlock, shape: engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setString(
    videoFill,
    property: "fill/video/fileURI",
    // swiftlint:disable:next line_length
    value: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.1-rc.0/assets/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  try engine.block.setFill(videoBlock, fill: videoFill)
  try engine.block.appendChild(to: page, child: videoBlock)
  try engine.block.fillParent(videoBlock)
  try await engine.block.forceLoadAVResource(videoFill)
  // highlight-forSocialMedia-addVideo

  // highlight-forSocialMedia-exportOptions
  let options = VideoExportOptions(
    videoBitrate: 8_000_000, // 8 Mbps
    framerate: 30,
    targetWidth: 1080,
    targetHeight: 1920,
  )
  // highlight-forSocialMedia-exportOptions

  // highlight-forSocialMedia-exportVideo
  var exportedVideo: Blob?
  for try await event in try await engine.block.exportVideo(
    page,
    mimeType: .mp4,
    options: options,
  ) {
    switch event {
    // highlight-forSocialMedia-progress
    case let .progress(renderedFrames, encodedFrames, totalFrames):
      let percent = totalFrames == 0 ? 0 : Int((Double(encodedFrames) / Double(totalFrames)) * 100)
      print("Export \(percent)% – rendered \(renderedFrames), encoded \(encodedFrames) of \(totalFrames)")
    // highlight-forSocialMedia-progress
    case let .finished(video: blob):
      exportedVideo = blob
    }
  }
  guard let videoData = exportedVideo else { return }
  // highlight-forSocialMedia-exportVideo

  // highlight-forSocialMedia-saveFile
  let outputURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("vertical-video-1080x1920.mp4")
  try videoData.write(to: outputURL)
  // highlight-forSocialMedia-saveFile
}
