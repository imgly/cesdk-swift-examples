import Foundation
import IMGLYEngine

@MainActor
func resizeImages(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let baseURL = try engine.guidesBaseURL

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let imageBlock = try createImageBlock(engine: engine, page: page, baseURL: baseURL)

  // highlight-resizeImages-resizeHandles
  try engine.editor.setResizeHandlesVisibility(.always)
  let resizeHandlesVisibility = try engine.editor.getResizeHandlesVisibility()
  print("Resize handles: \(resizeHandlesVisibility.rawValue)")
  // highlight-resizeImages-resizeHandles

  // highlight-resizeImages-absoluteSize
  try engine.block.setWidthMode(imageBlock, mode: .absolute)
  try engine.block.setHeightMode(imageBlock, mode: .absolute)
  try engine.block.setWidth(imageBlock, value: 400)
  try engine.block.setHeight(imageBlock, value: 300)

  let absoluteWidth = try engine.block.getWidth(imageBlock)
  let absoluteHeight = try engine.block.getHeight(imageBlock)
  print("Configured size: \(absoluteWidth) x \(absoluteHeight)")
  // highlight-resizeImages-absoluteSize

  // Center the resized block on the page for the guide's hero image.
  try engine.block.setPositionX(imageBlock, value: 200)
  try engine.block.setPositionY(imageBlock, value: 150)
  try await engine.captureGuide(page, label: "hero")

  // highlight-resizeImages-percentSize
  try engine.block.setWidthMode(imageBlock, mode: .percent)
  try engine.block.setHeightMode(imageBlock, mode: .percent)
  try engine.block.setWidth(imageBlock, value: 0.5)
  try engine.block.setHeight(imageBlock, value: 0.5)

  let percentWidth = try engine.block.getWidth(imageBlock)
  let widthMode = try engine.block.getWidthMode(imageBlock)
  print("Configured width: \(percentWidth) (mode is percent: \(widthMode == .percent))")
  // highlight-resizeImages-percentSize

  // highlight-resizeImages-frameDimensions
  let frameWidth = try engine.block.getFrameWidth(imageBlock)
  let frameHeight = try engine.block.getFrameHeight(imageBlock)
  print("Frame size: \(frameWidth) x \(frameHeight)")
  // highlight-resizeImages-frameDimensions

  // highlight-resizeImages-maintainCrop
  try engine.block.setContentFillMode(imageBlock, mode: .crop)
  try engine.block.setWidthMode(imageBlock, mode: .absolute)
  try engine.block.setHeightMode(imageBlock, mode: .absolute)
  try engine.block.setWidth(imageBlock, value: 520, maintainCrop: true)
  try engine.block.setHeight(imageBlock, value: 320, maintainCrop: true)

  let contentFillMode = try engine.block.getContentFillMode(imageBlock)
  print("Content fill mode is crop: \(contentFillMode == .crop)")
  // highlight-resizeImages-maintainCrop

  let secondImageBlock = try createImageBlock(engine: engine, page: page, baseURL: baseURL)
  try engine.block.setPositionX(secondImageBlock, value: 460)

  // highlight-resizeImages-groupResize
  let group = try engine.block.group([imageBlock, secondImageBlock])
  try engine.block.setWidth(group, value: 600)

  let groupWidth = try engine.block.getWidth(group)
  print("Group width: \(groupWidth)")
  // highlight-resizeImages-groupResize

  // highlight-resizeImages-contentAwareResize
  try engine.block.resizeContentAware([page], width: 1080, height: 1080)

  let pageWidth = try engine.block.getWidth(page)
  print("Page width after content-aware resize: \(pageWidth)")
  // highlight-resizeImages-contentAwareResize

  // highlight-resizeImages-lockResize
  try engine.editor.setGlobalScope(key: "layer/resize", value: .defer)
  try engine.block.setScopeEnabled(group, key: "layer/resize", enabled: false)
  let resizeAllowed = try engine.block.isAllowedByScope(group, key: "layer/resize")
  print("Resize allowed: \(resizeAllowed)")

  try engine.block.setTransformLocked(group, locked: true)
  let locked = try engine.block.isTransformLocked(group)
  print("Transform locked: \(locked)")
  // highlight-resizeImages-lockResize
}

// highlight-resizeImages-createImageBlock
@MainActor
private func createImageBlock(
  engine: Engine,
  page: DesignBlockID,
  baseURL: URL,
) throws -> DesignBlockID {
  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(imageBlock, value: 320)
  try engine.block.setHeight(imageBlock, value: 240)
  try engine.block.setPositionX(imageBlock, value: 120)
  try engine.block.setPositionY(imageBlock, value: 120)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.appendChild(to: page, child: imageBlock)

  return imageBlock
}

// highlight-resizeImages-createImageBlock
