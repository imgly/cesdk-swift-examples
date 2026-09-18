import Foundation
import IMGLYEngine

@MainActor
func editStickers(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // Demo scaffolding: build a scene that already contains a sticker so the
  // edit sections below have something to act on. The recipe mirrors the
  // Create Stickers guide — a graphic block, a rect shape, an image fill,
  // and the `"sticker"` kind tag.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 450)
  try engine.block.setHeight(page, value: 250)
  try engine.block.appendChild(to: scene, child: page)

  let sticker = try engine.block.create(.graphic)
  try engine.block.setShape(sticker, shape: try engine.block.createShape(.rect))
  let stickerFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    stickerFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent(
      "ly.img.sticker/images/emoticons/imgly_sticker_emoticons_grin.svg",
    ),
  )
  try engine.block.setFill(sticker, fill: stickerFill)
  if try engine.block.supportsContentFillMode(sticker) {
    try engine.block.setContentFillMode(sticker, mode: .contain)
  }
  try engine.block.setKind(sticker, kind: "sticker")
  try engine.block.setWidth(sticker, value: 120)
  try engine.block.setHeight(sticker, value: 120)
  try engine.block.setPositionX(sticker, value: 50)
  try engine.block.setPositionY(sticker, value: 65)
  try engine.block.appendChild(to: page, child: sticker)

  // highlight-editStickers-replaceImage
  let fill = try engine.block.getFill(sticker)
  try engine.block.setURL(
    fill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent(
      "ly.img.sticker/images/emoticons/imgly_sticker_emoticons_blush.svg",
    ),
  )
  // highlight-editStickers-replaceImage

  // highlight-editStickers-transform
  try engine.block.setPositionX(sticker, value: 50)
  try engine.block.setPositionY(sticker, value: 65)
  try engine.block.setWidth(sticker, value: 120)
  try engine.block.setHeight(sticker, value: 120)
  try engine.block.setRotation(sticker, radians: .pi / 12)
  try engine.block.setFlipHorizontal(sticker, flip: false)
  // highlight-editStickers-transform

  // highlight-editStickers-contentFillMode
  if try engine.block.supportsContentFillMode(sticker) {
    try engine.block.setContentFillMode(sticker, mode: .cover)
  }
  // highlight-editStickers-contentFillMode

  // Reset to the recommended .contain mode for the rest of the demo.
  if try engine.block.supportsContentFillMode(sticker) {
    try engine.block.setContentFillMode(sticker, mode: .contain)
  }

  // highlight-editStickers-opacity
  try engine.block.setOpacity(sticker, value: 1.0)
  // highlight-editStickers-opacity

  // highlight-editStickers-dropShadow
  try engine.block.setDropShadowEnabled(sticker, enabled: true)
  try engine.block.setDropShadowColor(sticker, color: .rgba(r: 0, g: 0, b: 0, a: 0.4))
  try engine.block.setDropShadowOffsetX(sticker, offsetX: 4)
  try engine.block.setDropShadowOffsetY(sticker, offsetY: 4)
  try engine.block.setDropShadowBlurRadiusX(sticker, blurRadiusX: 6)
  try engine.block.setDropShadowBlurRadiusY(sticker, blurRadiusY: 6)
  // highlight-editStickers-dropShadow

  // highlight-editStickers-duplicate
  let copy = try engine.block.duplicate(sticker)
  try engine.block.setPositionX(copy, value: 280)
  try engine.block.setPositionY(copy, value: 65)
  // highlight-editStickers-duplicate

  try await engine.captureGuide(page, label: "hero")

  // highlight-editStickers-stroke
  try engine.block.setStrokeEnabled(sticker, enabled: true)
  try engine.block.setStrokeColor(sticker, color: .rgba(r: 1, g: 1, b: 1, a: 1))
  try engine.block.setStrokeWidth(sticker, width: 4)
  // highlight-editStickers-stroke

  // highlight-editStickers-blur
  let blur = try engine.block.createBlur(.uniform)
  try engine.block.setBlur(sticker, blurID: blur)
  try engine.block.setBlurEnabled(sticker, enabled: true)
  // highlight-editStickers-blur

  // highlight-editStickers-effects
  let tiltShift = try engine.block.createEffect(.tiltShift)
  try engine.block.appendEffect(sticker, effectID: tiltShift)
  // highlight-editStickers-effects
}
