import IMGLYEngine

@MainActor
func autoResize(engine: Engine) async throws {
  // highlight-autoResize-setup
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-autoResize-setup

  // highlight-autoResize-autoMode
  let titleBlock = try engine.block.create(.text)
  try engine.block.replaceText(titleBlock, text: "Auto-Resize Demo")
  try engine.block.setTextFontSize(titleBlock, fontSize: 64)
  try engine.block.setWidthMode(titleBlock, mode: .auto)
  try engine.block.setHeightMode(titleBlock, mode: .auto)
  try engine.block.appendChild(to: page, child: titleBlock)
  // highlight-autoResize-autoMode

  // highlight-autoResize-fillParent
  let coverBlock = try engine.block.create(.graphic)
  try engine.block.setShape(coverBlock, shape: engine.block.createShape(.rect))
  let coverFill = try engine.block.createFill(.color)
  try engine.block.setColor(coverFill, property: "fill/color/value", color: .rgba(r: 1, g: 1, b: 1, a: 0.08))
  try engine.block.setFill(coverBlock, fill: coverFill)
  try engine.block.appendChild(to: page, child: coverBlock)
  try engine.block.fillParent(coverBlock)
  // highlight-autoResize-fillParent
  try engine.block.destroy(coverBlock)

  await Task.yield()

  // highlight-autoResize-readFrameDimensions
  let titleWidth = try engine.block.getFrameWidth(titleBlock)
  let titleHeight = try engine.block.getFrameHeight(titleBlock)
  print("Title dimensions: \(Int(titleWidth))x\(Int(titleHeight)) pixels")
  // highlight-autoResize-readFrameDimensions

  // highlight-autoResize-centerBlock
  let pageWidth = try engine.block.getWidth(page)
  let pageHeight = try engine.block.getHeight(page)
  let centerX = (pageWidth - titleWidth) / 2
  let centerY = (pageHeight - titleHeight) / 2 - 100
  try engine.block.setPositionX(titleBlock, value: centerX)
  try engine.block.setPositionY(titleBlock, value: centerY)
  // highlight-autoResize-centerBlock

  // highlight-autoResize-percentMode
  let backgroundBlock = try engine.block.create(.graphic)
  try engine.block.setShape(backgroundBlock, shape: engine.block.createShape(.rect))
  let backgroundFill = try engine.block.createFill(.color)
  try engine.block.setColor(backgroundFill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.4, b: 0.8, a: 0.3))
  try engine.block.setFill(backgroundBlock, fill: backgroundFill)
  try engine.block.setWidthMode(backgroundBlock, mode: .percent)
  try engine.block.setHeightMode(backgroundBlock, mode: .percent)
  try engine.block.setWidth(backgroundBlock, value: 0.8)
  try engine.block.setHeight(backgroundBlock, value: 0.3)
  try engine.block.setPositionX(backgroundBlock, value: pageWidth * 0.1)
  try engine.block.setPositionY(backgroundBlock, value: pageHeight * 0.6)
  try engine.block.appendChild(to: page, child: backgroundBlock)
  try engine.block.sendToBack(backgroundBlock)
  // highlight-autoResize-percentMode

  // highlight-autoResize-subtitleAuto
  let subtitleBlock = try engine.block.create(.text)
  try engine.block.replaceText(subtitleBlock, text: "Text automatically sizes to fit content")
  try engine.block.setTextFontSize(subtitleBlock, fontSize: 32)
  try engine.block.setWidthMode(subtitleBlock, mode: .auto)
  try engine.block.setHeightMode(subtitleBlock, mode: .auto)
  try engine.block.appendChild(to: page, child: subtitleBlock)

  await Task.yield()

  let subtitleWidth = try engine.block.getFrameWidth(subtitleBlock)
  try engine.block.setPositionX(subtitleBlock, value: (pageWidth - subtitleWidth) / 2)
  try engine.block.setPositionY(subtitleBlock, value: pageHeight * 0.7)
  // highlight-autoResize-subtitleAuto

  // highlight-autoResize-checkModes
  let titleWidthMode = try engine.block.getWidthMode(titleBlock)
  let titleHeightMode = try engine.block.getHeightMode(titleBlock)
  let backgroundWidthMode = try engine.block.getWidthMode(backgroundBlock)
  let backgroundHeightMode = try engine.block.getHeightMode(backgroundBlock)
  print("Title uses auto sizing: \(titleWidthMode == .auto && titleHeightMode == .auto)")
  print("Background uses percent sizing: \(backgroundWidthMode == .percent && backgroundHeightMode == .percent)")
  // highlight-autoResize-checkModes

  // Most-evolved scene — promoted to the guide's hero image.
  try await engine.captureGuide(page, label: "hero")
}
