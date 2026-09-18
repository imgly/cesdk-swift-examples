import Foundation
import IMGLYEngine

@MainActor
func createStickers(engine: Engine) async throws {
  // highlight-createStickers-manualConstruction
  // A 450x250 page hosts the sticker.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 450)
  try engine.block.setHeight(page, value: 250)
  try engine.block.appendChild(to: scene, child: page)

  // A sticker is a graphic block with a rect shape and an image fill.
  let sticker = try engine.block.create(.graphic)
  let stickerShape = try engine.block.createShape(.rect)
  try engine.block.setShape(sticker, shape: stickerShape)

  let stickerFill = try engine.block.createFill(.image)
  try engine.block.setString(
    stickerFill,
    property: "fill/image/imageFileURI",
    value: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.0"
      + "/assets/ly.img.sticker/images/emoticons/imgly_sticker_emoticons_grin.svg",
  )
  try engine.block.setFill(sticker, fill: stickerFill)

  // Preserve the source artwork's aspect ratio inside the block bounds.
  if try engine.block.supportsContentFillMode(sticker) {
    try engine.block.setContentFillMode(sticker, mode: .contain)
  }

  // Tag the block as a sticker so the editor categorizes it correctly and
  // exposes the sticker-specific inspector bar.
  try engine.block.setKind(sticker, kind: "sticker")

  try engine.block.setWidth(sticker, value: 150)
  try engine.block.setHeight(sticker, value: 150)
  try engine.block.setPositionX(sticker, value: 60)
  try engine.block.setPositionY(sticker, value: 50)
  try engine.block.appendChild(to: page, child: sticker)
  // highlight-createStickers-manualConstruction

  // Demo scaffolding: add a second sticker so the hero export shows the
  // multi-sticker layout the prose describes. The recipe is identical — only
  // the source URL and position differ.
  let secondSticker = try engine.block.create(.graphic)
  try engine.block.setShape(secondSticker, shape: try engine.block.createShape(.rect))
  let secondFill = try engine.block.createFill(.image)
  try engine.block.setString(
    secondFill,
    property: "fill/image/imageFileURI",
    value: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.0"
      + "/assets/ly.img.sticker/images/emoticons/imgly_sticker_emoticons_blush.svg",
  )
  try engine.block.setFill(secondSticker, fill: secondFill)
  if try engine.block.supportsContentFillMode(secondSticker) {
    try engine.block.setContentFillMode(secondSticker, mode: .contain)
  }
  try engine.block.setKind(secondSticker, kind: "sticker")
  try engine.block.setWidth(secondSticker, value: 150)
  try engine.block.setHeight(secondSticker, value: 150)
  try engine.block.setPositionX(secondSticker, value: 240)
  try engine.block.setPositionY(secondSticker, value: 50)
  try engine.block.appendChild(to: page, child: secondSticker)

  try await engine.captureGuide(page, label: "hero")
}
