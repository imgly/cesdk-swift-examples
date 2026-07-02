import Foundation
import IMGLYEngine

@MainActor
func fillsVideo(engine: Engine) async throws {
  // Demo scaffolding: a scene with a page and a graphic block to receive the video fill.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block, value: 500)
  try engine.block.setHeight(block, value: 500)
  try engine.block.setPositionX(block, value: 150)
  try engine.block.setPositionY(block, value: 50)
  try engine.block.appendChild(to: page, child: block)

  let baseURL = try engine.guidesBaseURL
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )

  // highlight-fillsVideo-checkSupport
  let canHaveFill = try engine.block.supportsFill(block)
  print("Block supports fills: \(canHaveFill)")
  // highlight-fillsVideo-checkSupport

  // highlight-fillsVideo-createVideoFill
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(
    videoFill,
    property: "fill/video/fileURI",
    value: videoURL,
  )
  try engine.block.setFill(block, fill: videoFill)
  // highlight-fillsVideo-createVideoFill

  // highlight-fillsVideo-getCurrentFill
  let currentFill = try engine.block.getFill(block)
  let fillType = try engine.block.getType(currentFill)
  print("Fill type: \(fillType)")
  // highlight-fillsVideo-getCurrentFill

  // highlight-fillsVideo-coverMode
  try engine.block.setContentFillMode(block, mode: .cover)
  // highlight-fillsVideo-coverMode

  try await engine.block.forceLoadAVResource(videoFill)

  // Set playback time so captures show video content rather than the black first frame.
  try engine.block.setPlaybackTime(page, time: 2)

  try await engine.captureGuide(page, label: "after-cover")

  // highlight-fillsVideo-containMode
  try engine.block.setContentFillMode(block, mode: .contain)
  // highlight-fillsVideo-containMode

  try await engine.captureGuide(page, label: "after-contain")

  // highlight-fillsVideo-cropMode
  try engine.block.setContentFillMode(block, mode: .crop)
  try engine.block.setCropScaleRatio(block, scaleRatio: 1.5)
  try engine.block.setCropTranslationX(block, translationX: 0.25)
  // highlight-fillsVideo-cropMode

  // highlight-fillsVideo-getFillMode
  let currentMode = try engine.block.getContentFillMode(block)
  print("Current fill mode: \(currentMode)")
  // highlight-fillsVideo-getFillMode

  // highlight-fillsVideo-forceLoad
  try await engine.block.forceLoadAVResource(videoFill)
  let totalDuration = try engine.block.getAVResourceTotalDuration(videoFill)
  print("Video total duration: \(totalDuration) seconds")
  // highlight-fillsVideo-forceLoad

  // highlight-fillsVideo-sourceSet
  try engine.block.setSourceSet(
    videoFill,
    property: "fill/video/sourceSet",
    sourceSet: [
      Source(
        uri: baseURL.appendingPathComponent(
          "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
        ),
        width: 640,
        height: 360,
      ),
      Source(
        uri: baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4"),
        width: 1280,
        height: 720,
      ),
    ],
  )
  // highlight-fillsVideo-sourceSet

  // highlight-fillsVideo-getSourceSet
  let sourceSet = try engine.block.getSourceSet(videoFill, property: "fill/video/sourceSet")
  print("Source set entries: \(sourceSet.count)")
  // highlight-fillsVideo-getSourceSet

  // highlight-fillsVideo-shapeFill
  let ellipseBlock = try engine.block.create(.graphic)
  try engine.block.setShape(ellipseBlock, shape: engine.block.createShape(.ellipse))
  try engine.block.setWidth(ellipseBlock, value: 200)
  try engine.block.setHeight(ellipseBlock, value: 200)
  try engine.block.setPositionX(ellipseBlock, value: 550)
  try engine.block.setPositionY(ellipseBlock, value: 50)
  try engine.block.appendChild(to: page, child: ellipseBlock)

  let ellipseVideoFill = try engine.block.createFill(.video)
  try engine.block.setURL(ellipseVideoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(ellipseBlock, fill: ellipseVideoFill)
  // highlight-fillsVideo-shapeFill

  // highlight-fillsVideo-opacity
  try engine.block.setOpacity(block, value: 0.7)
  // highlight-fillsVideo-opacity

  // highlight-fillsVideo-sharedFill
  let sharedFill = try engine.block.createFill(.video)
  try engine.block.setURL(sharedFill, property: "fill/video/fileURI", value: videoURL)

  let sharedBlock1 = try engine.block.create(.graphic)
  try engine.block.setShape(sharedBlock1, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(sharedBlock1, value: 200)
  try engine.block.setHeight(sharedBlock1, value: 150)
  try engine.block.setPositionX(sharedBlock1, value: 50)
  try engine.block.setPositionY(sharedBlock1, value: 400)
  try engine.block.appendChild(to: page, child: sharedBlock1)
  try engine.block.setFill(sharedBlock1, fill: sharedFill)

  let sharedBlock2 = try engine.block.create(.graphic)
  try engine.block.setShape(sharedBlock2, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(sharedBlock2, value: 200)
  try engine.block.setHeight(sharedBlock2, value: 150)
  try engine.block.setPositionX(sharedBlock2, value: 300)
  try engine.block.setPositionY(sharedBlock2, value: 400)
  try engine.block.appendChild(to: page, child: sharedBlock2)
  try engine.block.setFill(sharedBlock2, fill: sharedFill)

  print("Two blocks share one video fill instance")
  // highlight-fillsVideo-sharedFill

  // Reset the source set back to the single video so the hero shows consistent video content.
  try engine.block.setSourceSet(
    videoFill,
    property: "fill/video/sourceSet",
    sourceSet: [Source(uri: videoURL, width: 720, height: 1280)],
  )
  try engine.block.setContentFillMode(block, mode: .cover)
  try engine.block.setContentFillMode(ellipseBlock, mode: .contain)
  try engine.block.setOpacity(block, value: 1)
  try await engine.captureGuide(page, label: "hero")
}
