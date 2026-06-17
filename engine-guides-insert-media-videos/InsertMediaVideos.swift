import Foundation
import IMGLYEngine

@MainActor
func insertMediaVideos(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.setDuration(page, duration: 30)

  let baseURL = try engine.guidesBaseURL
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )

  // highlight-insertMediaVideos-createVideoBlock
  let videoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(videoBlock, shape: engine.block.createShape(.rect))

  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(videoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(videoBlock, fill: videoFill)

  try engine.block.appendChild(to: page, child: videoBlock)
  // highlight-insertMediaVideos-createVideoBlock

  // highlight-insertMediaVideos-positionAndSize
  // Place an 800x450 frame at the center of the 1920x1080 page.
  try engine.block.setWidth(videoBlock, value: 800)
  try engine.block.setHeight(videoBlock, value: 450)
  try engine.block.setPositionX(videoBlock, value: 560)
  try engine.block.setPositionY(videoBlock, value: 315)
  // highlight-insertMediaVideos-positionAndSize

  // highlight-insertMediaVideos-configureTrim
  try await engine.block.forceLoadAVResource(videoFill)
  let totalDuration = try engine.block.getAVResourceTotalDuration(videoFill)
  let trimOffset = 2.0
  let trimLength = min(5.0, totalDuration - trimOffset)
  try engine.block.setTrimOffset(videoFill, offset: trimOffset)
  try engine.block.setTrimLength(videoFill, length: trimLength)
  try engine.block.setDuration(videoBlock, duration: trimLength)
  // highlight-insertMediaVideos-configureTrim

  // highlight-insertMediaVideos-findVideoBlocks
  let graphicBlocks = try engine.block.find(byType: .graphic)
  for block in graphicBlocks {
    let fill = try engine.block.getFill(block)
    guard try engine.block.getType(fill) == FillType.video.rawValue else { continue }
    let uri = try engine.block.getString(fill, property: "fill/video/fileURI")
    let offset = try engine.block.getTrimOffset(fill)
    let length = try engine.block.getTrimLength(fill)
    print(String(format: "Video %u — trim %.2fs..+%.2fs, uri %@", block, offset, length, uri))
  }
  // highlight-insertMediaVideos-findVideoBlocks

  // highlight-insertMediaVideos-removeVideo
  try engine.block.destroy(videoBlock)
  // highlight-insertMediaVideos-removeVideo
}
