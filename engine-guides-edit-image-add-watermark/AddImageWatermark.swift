import Foundation
import IMGLYEngine

@MainActor
func addImageWatermark(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-addImageWatermark-setup
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  try await engine.scene.create(fromImage: imageURL)

  guard let page = try engine.scene.getCurrentPage() else {
    fatalError("Expected create(fromImage:) to create a page.")
  }
  let pageWidth = try engine.block.getWidth(page)
  let pageHeight = try engine.block.getHeight(page)
  // highlight-addImageWatermark-setup

  // highlight-addImageWatermark-createTextWatermark
  let textWatermark = try engine.block.create(.text)

  try engine.block.replaceText(textWatermark, text: "All rights reserved")
  try engine.block.setHeightMode(textWatermark, mode: .auto)
  try engine.block.setWidth(textWatermark, value: pageWidth * 0.55)
  try engine.block.appendChild(to: page, child: textWatermark)
  // highlight-addImageWatermark-createTextWatermark

  // highlight-addImageWatermark-styleTextWatermark
  try engine.block.setTextFontSize(textWatermark, fontSize: 28)
  try engine.block.setTextColor(textWatermark, color: .rgba(r: 1, g: 1, b: 1, a: 1))
  try engine.block.setTextHorizontalAlignment(textWatermark, alignment: .left)
  try engine.block.setOpacity(textWatermark, value: 0.7)
  // highlight-addImageWatermark-styleTextWatermark

  try await engine.captureGuide(page, label: "after-text")

  // highlight-addImageWatermark-createLogoWatermark
  let logoWatermark = try engine.block.create(.graphic)
  try engine.block.setShape(logoWatermark, shape: engine.block.createShape(.rect))

  let logoFill = try engine.block.createFill(.image)
  let logoURL = baseURL.appendingPathComponent(
    "ly.img.sticker/images/3Dstickers/3d_stickers_megaphone.png",
  )
  try engine.block.setURL(logoFill, property: "fill/image/imageFileURI", value: logoURL)
  try engine.block.setFill(logoWatermark, fill: logoFill)
  try engine.block.setContentFillMode(logoWatermark, mode: .contain)
  try engine.block.appendChild(to: page, child: logoWatermark)
  // highlight-addImageWatermark-createLogoWatermark

  // highlight-addImageWatermark-sizeLogoWatermark
  let logoSize = pageWidth * 0.14

  try engine.block.setWidth(logoWatermark, value: logoSize)
  try engine.block.setHeight(logoWatermark, value: logoSize)
  try engine.block.setOpacity(logoWatermark, value: 0.62)
  // highlight-addImageWatermark-sizeLogoWatermark

  // highlight-addImageWatermark-positionWatermarks
  let spacing: Float = 18
  let bottomPadding: Float = 36
  let textWidth = try engine.block.getFrameWidth(textWatermark)
  let textHeight = try engine.block.getFrameHeight(textWatermark)
  let totalWatermarkWidth = logoSize + spacing + textWidth
  let startX = (pageWidth - totalWatermarkWidth) / 2
  let centerY = pageHeight - bottomPadding - max(logoSize, textHeight) / 2
  let logoY = centerY - logoSize / 2
  let textY = centerY - textHeight / 2

  try engine.block.setPositionX(logoWatermark, value: startX)
  try engine.block.setPositionY(logoWatermark, value: logoY)
  try engine.block.setPositionX(textWatermark, value: startX + logoSize + spacing)
  try engine.block.setPositionY(textWatermark, value: textY)
  // highlight-addImageWatermark-positionWatermarks

  try await engine.captureGuide(page, label: "after-position")

  // highlight-addImageWatermark-addDropShadow
  for watermark in [textWatermark, logoWatermark] {
    guard try engine.block.supportsDropShadow(watermark) else { continue }
    try engine.block.setDropShadowEnabled(watermark, enabled: true)
    try engine.block.setDropShadowColor(watermark, color: .rgba(r: 0, g: 0, b: 0, a: 0.55))
    try engine.block.setDropShadowOffsetX(watermark, offsetX: 3)
    try engine.block.setDropShadowOffsetY(watermark, offsetY: 3)
    try engine.block.setDropShadowBlurRadiusX(watermark, blurRadiusX: 6)
    try engine.block.setDropShadowBlurRadiusY(watermark, blurRadiusY: 6)
  }
  // highlight-addImageWatermark-addDropShadow

  try await engine.captureGuide(page, label: "hero")

  // highlight-addImageWatermark-exportWatermarked
  let exportedPNG = try await engine.block.export(page, mimeType: .png)
  let exportedJPEG = try await engine.block.export(
    page,
    mimeType: .jpeg,
    options: ExportOptions(jpegQuality: 0.86),
  )
  let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
  try exportedPNG.write(to: tempDir.appendingPathComponent("watermarked.png"))
  try exportedJPEG.write(to: tempDir.appendingPathComponent("watermarked.jpg"))
  // highlight-addImageWatermark-exportWatermarked
}
