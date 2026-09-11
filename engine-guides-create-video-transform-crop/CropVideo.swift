import Foundation
import IMGLYEngine

@MainActor
func cropVideo(engine: Engine) async throws {
  // Demo scaffolding: a video scene with a single video block that fills the page.
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.setDuration(page, duration: 5)

  let videoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(videoBlock, shape: engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  let videoURL = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.75.0" +
    "/assets/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4"
  try engine.block.setString(videoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(videoBlock, fill: videoFill)

  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)
  try engine.block.appendChild(to: track, child: videoBlock)
  try engine.block.fillParent(track)

  // Decode at least one video frame before exporting snapshots.
  try await engine.block.forceLoadAVResource(videoFill)

  // highlight-cropVideo-checkSupport
  let canCrop = try engine.block.supportsCrop(videoBlock)
  // highlight-cropVideo-checkSupport
  _ = canCrop

  // highlight-cropVideo-scale
  // Center-crop: scale both axes uniformly while keeping the content centered.
  try engine.block.setCropScaleRatio(videoBlock, scaleRatio: 1.5)
  // highlight-cropVideo-scale

  try await engine.captureGuide(page, label: "after-scale")

  // highlight-cropVideo-scaleAxis
  // Or scale each axis independently. Unequal values stretch the content.
  try engine.block.setCropScaleX(videoBlock, scaleX: 1.5)
  try engine.block.setCropScaleY(videoBlock, scaleY: 2.0)
  // highlight-cropVideo-scaleAxis

  // highlight-cropVideo-translate
  // Pan the content within the frame. Values are normalized fractions of the
  // frame dimensions: 0.25 moves the content one quarter of the frame to the right.
  try engine.block.setCropTranslationX(videoBlock, translationX: 0.25)
  try engine.block.setCropTranslationY(videoBlock, translationY: -0.1)
  // highlight-cropVideo-translate

  try await engine.captureGuide(page, label: "after-translate")

  // highlight-cropVideo-rotate
  // Rotate the content within the crop frame. Rotation is in radians.
  try engine.block.setCropRotation(videoBlock, rotation: .pi / 6)
  // highlight-cropVideo-rotate

  // highlight-cropVideo-getValues
  let scaleRatio = try engine.block.getCropScaleRatio(videoBlock)
  let scaleX = try engine.block.getCropScaleX(videoBlock)
  let scaleY = try engine.block.getCropScaleY(videoBlock)
  let rotation = try engine.block.getCropRotation(videoBlock)
  let offsetX = try engine.block.getCropTranslationX(videoBlock)
  let offsetY = try engine.block.getCropTranslationY(videoBlock)
  // highlight-cropVideo-getValues
  _ = (scaleRatio, scaleX, scaleY, rotation, offsetX, offsetY)

  // highlight-cropVideo-fillFrame
  // After translating or rotating you can re-fill the frame to remove letterboxing.
  try engine.block.adjustCropToFillFrame(videoBlock, minScaleRatio: 1.0)
  // highlight-cropVideo-fillFrame

  // highlight-cropVideo-flip
  // Mirror the content along the vertical axis.
  try engine.block.flipCropHorizontal(videoBlock)
  // highlight-cropVideo-flip

  try await engine.captureGuide(page, label: "hero")

  // highlight-cropVideo-lockAspect
  try engine.block.setCropAspectRatioLocked(videoBlock, locked: true)
  let isLocked = try engine.block.isCropAspectRatioLocked(videoBlock)
  // highlight-cropVideo-lockAspect
  _ = isLocked

  // highlight-cropVideo-reset
  // Reset every crop transform back to its starting state.
  try engine.block.resetCrop(videoBlock)
  // highlight-cropVideo-reset
}
