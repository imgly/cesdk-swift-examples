import Foundation
import IMGLYEngine

@MainActor
func addWatermark(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-addWatermark-createScene
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  try await engine.scene.create(fromVideo: videoURL)

  guard let page = try engine.scene.getCurrentPage() else {
    fatalError("Expected create(fromVideo:) to create a page.")
  }
  let pageWidth = try engine.block.getWidth(page)
  let pageHeight = try engine.block.getHeight(page)
  let videoDuration = try engine.block.getDuration(page)
  // highlight-addWatermark-createScene

  // highlight-addWatermark-createTextWatermark
  let textWatermark = try engine.block.create(.text)

  try engine.block.setWidthMode(textWatermark, mode: .auto)
  try engine.block.setHeightMode(textWatermark, mode: .auto)
  try engine.block.replaceText(textWatermark, text: "All rights reserved")

  let textPadding: Float = 20
  try engine.block.setPositionX(textWatermark, value: textPadding)
  try engine.block.setPositionY(textWatermark, value: pageHeight - textPadding - 24)
  // highlight-addWatermark-createTextWatermark

  // highlight-addWatermark-styleTextWatermark
  try engine.block.setTextFontSize(textWatermark, fontSize: 8)
  try engine.block.setTextColor(textWatermark, color: .rgba(r: 1, g: 1, b: 1, a: 1))
  try engine.block.setTextHorizontalAlignment(textWatermark, alignment: .left)
  try engine.block.setOpacity(textWatermark, value: 0.7)
  // highlight-addWatermark-styleTextWatermark

  // highlight-addWatermark-textDropShadow
  try engine.block.setDropShadowEnabled(textWatermark, enabled: true)
  try engine.block.setDropShadowColor(textWatermark, color: .rgba(r: 0, g: 0, b: 0, a: 0.8))
  try engine.block.setDropShadowOffsetX(textWatermark, offsetX: 2)
  try engine.block.setDropShadowOffsetY(textWatermark, offsetY: 2)
  try engine.block.setDropShadowBlurRadiusX(textWatermark, blurRadiusX: 4)
  try engine.block.setDropShadowBlurRadiusY(textWatermark, blurRadiusY: 4)
  // highlight-addWatermark-textDropShadow

  // highlight-addWatermark-textTimeline
  try engine.block.setDuration(textWatermark, duration: videoDuration)
  try engine.block.setTimeOffset(textWatermark, offset: 0)
  try engine.block.appendChild(to: page, child: textWatermark)
  // highlight-addWatermark-textTimeline

  try await engine.captureGuide(page, label: "after-text-watermark")

  // highlight-addWatermark-createImageWatermark
  let logoWatermark = try engine.block.create(.graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(logoWatermark, shape: rectShape)

  let imageFill = try engine.block.createFill(.image)
  let logoURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: logoURL)
  try engine.block.setFill(logoWatermark, fill: imageFill)
  try engine.block.setContentFillMode(logoWatermark, mode: .contain)
  // highlight-addWatermark-createImageWatermark

  // highlight-addWatermark-positionImageWatermark
  let logoSize: Float = 80
  let logoPadding: Float = 20
  try engine.block.setWidth(logoWatermark, value: logoSize)
  try engine.block.setHeight(logoWatermark, value: logoSize)
  try engine.block.setPositionX(logoWatermark, value: pageWidth - logoSize - logoPadding)
  try engine.block.setPositionY(logoWatermark, value: logoPadding)
  // highlight-addWatermark-positionImageWatermark

  // highlight-addWatermark-imageOpacityBlend
  try engine.block.setOpacity(logoWatermark, value: 0.6)
  try engine.block.setBlendMode(logoWatermark, mode: .normal)
  // highlight-addWatermark-imageOpacityBlend

  // highlight-addWatermark-imageTimeline
  try engine.block.setDuration(logoWatermark, duration: videoDuration)
  try engine.block.setTimeOffset(logoWatermark, offset: 0)
  try engine.block.appendChild(to: page, child: logoWatermark)
  // highlight-addWatermark-imageTimeline

  // Demo scaffolding: advance the playhead to the middle of the clip so the
  // hero capture lands on a representative video frame.
  try engine.block.setPlaybackTime(page, time: videoDuration / 2)
  try await engine.captureGuide(page, label: "hero")
}
