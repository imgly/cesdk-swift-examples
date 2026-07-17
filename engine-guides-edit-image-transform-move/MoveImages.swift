import Foundation
import IMGLYEngine

@MainActor
func moveImages(engine: Engine) async throws {
  // Demo scaffolding: a scene with two image blocks on a single page so we can
  // demonstrate every positioning API against real, renderable content.
  let scene = try engine.scene.create()
  let baseURL = try engine.guidesBaseURL

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let imageBlock = try makeImageBlock(
    engine: engine,
    url: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
    width: 240,
    height: 200,
  )
  try engine.block.appendChild(to: page, child: imageBlock)

  let secondImage = try makeImageBlock(
    engine: engine,
    url: baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg"),
    width: 240,
    height: 200,
  )
  try engine.block.appendChild(to: page, child: secondImage)
  try engine.block.setPositionX(secondImage, value: 460)
  try engine.block.setPositionY(secondImage, value: 350)

  // highlight-moveImages-setPosition
  try engine.block.setPositionX(imageBlock, value: 150)
  try engine.block.setPositionY(imageBlock, value: 100)
  // highlight-moveImages-setPosition

  try await engine.captureGuide(page, label: "after-set-position")

  // highlight-moveImages-getPosition
  let xPosition = try engine.block.getPositionX(imageBlock)
  let yPosition = try engine.block.getPositionY(imageBlock)
  // highlight-moveImages-getPosition
  _ = (xPosition, yPosition)

  // highlight-moveImages-percent
  try engine.block.setPositionXMode(imageBlock, mode: .percent)
  try engine.block.setPositionYMode(imageBlock, mode: .percent)
  try engine.block.setPositionX(imageBlock, value: 0.5)
  try engine.block.setPositionY(imageBlock, value: 0.5)
  // highlight-moveImages-percent

  try await engine.captureGuide(page, label: "after-percent")

  // highlight-moveImages-getMode
  let xMode = try engine.block.getPositionXMode(imageBlock)
  let yMode = try engine.block.getPositionYMode(imageBlock)
  // highlight-moveImages-getMode
  _ = (xMode, yMode)

  // highlight-moveImages-relative
  let currentX = try engine.block.getPositionX(imageBlock)
  try engine.block.setPositionX(imageBlock, value: currentX + 0.05)
  // highlight-moveImages-relative

  // Switch back to absolute mode before grouping so the group below uses pixel
  // coordinates. The reader sees the explicit mode flip once and then keeps
  // working in absolute units.
  try engine.block.setPositionXMode(imageBlock, mode: .absolute)
  try engine.block.setPositionYMode(imageBlock, mode: .absolute)
  try engine.block.setPositionX(imageBlock, value: 120)
  try engine.block.setPositionY(imageBlock, value: 80)
  try engine.block.setPositionX(secondImage, value: 420)
  try engine.block.setPositionY(secondImage, value: 80)

  // highlight-moveImages-group
  if try engine.block.isGroupable([imageBlock, secondImage]) {
    let group = try engine.block.group([imageBlock, secondImage])
    try engine.block.setPositionX(group, value: 80)
    try engine.block.setPositionY(group, value: 200)
  }
  // highlight-moveImages-group

  try await engine.captureGuide(page, label: "hero")

  // highlight-moveImages-transformLock
  try engine.block.setTransformLocked(imageBlock, locked: true)
  // highlight-moveImages-transformLock
}

@MainActor
private func makeImageBlock(
  engine: Engine,
  url: URL,
  width: Float,
  height: Float,
) throws -> DesignBlockID {
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let fill = try engine.block.createFill(.image)
  try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: url)
  try engine.block.setFill(block, fill: fill)
  try engine.block.setContentFillMode(block, mode: .cover)
  try engine.block.setWidth(block, value: width)
  try engine.block.setHeight(block, value: height)
  return block
}
