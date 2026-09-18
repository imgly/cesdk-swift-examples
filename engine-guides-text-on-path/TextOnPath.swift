import IMGLYEngine

@MainActor
func textOnPath(engine: Engine) async throws {
  // Demo scaffolding: a square page that frames the curved text for the
  // captures below. Creating the scene with `designUnit: .px` pairs the
  // font-size unit to Pixel, so the `setTextFontSize` value below renders at
  // the scale the SVG path's local coordinates assume. `setTextOnPath` sizes
  // the block to span about 7 font heights of the curve's larger dimension,
  // so the page needs to be generous relative to the font size below or the
  // curve renders larger than the page (and the capture goes blank).
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 480)
  try engine.block.setHeight(page, value: 480)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-textOnPath-createText
  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: text)
  try engine.block.replaceText(text, text: "TEXT ON A PATH")
  try engine.block.setTextFontSize(text, fontSize: 48)
  // highlight-textOnPath-createText

  // highlight-textOnPath-placeOnPath
  let circlePath = "M 60,119.5 A 59.5,59.5 0 1,1 60.01,119.5 Z"
  try engine.block.setTextOnPath(text, svgPath: circlePath)
  // highlight-textOnPath-placeOnPath

  // Demo scaffolding: setTextOnPath resizes the block to the path's aspect
  // ratio, so center it on the page now that its size is known.
  let width = try engine.block.getWidth(text)
  let height = try engine.block.getHeight(text)
  try engine.block.setPositionX(text, value: (480 - width) / 2)
  try engine.block.setPositionY(text, value: (480 - height) / 2)

  try await engine.captureGuide(page, label: "after-place-on-path")

  // highlight-textOnPath-verticalPosition
  try engine.block.setEnum(text, property: "text/verticalAlignment", value: "Center")
  // highlight-textOnPath-verticalPosition

  try await engine.captureGuide(page, label: "after-vertical-position")

  // highlight-textOnPath-offset
  try engine.block.setTextOnPathOffset(text, offset: 0.05)
  let pathOffset = try engine.block.getTextOnPathOffset(text)
  print("Path offset:", pathOffset)
  // highlight-textOnPath-offset

  try await engine.captureGuide(page, label: "hero")

  // highlight-textOnPath-direction
  try engine.block.setTextOnPathFlipped(text, flipped: true)
  let isFlipped = try engine.block.getTextOnPathFlipped(text)
  print("Flipped:", isFlipped)
  // highlight-textOnPath-direction

  try await engine.captureGuide(page, label: "after-flip")

  // highlight-textOnPath-readAndClear
  let currentPath = try engine.block.getTextOnPath(text)
  print("Text on path:", currentPath ?? "none")

  try engine.block.setTextOnPath(text, svgPath: nil)
  // highlight-textOnPath-readAndClear

  try await engine.captureGuide(page, label: "after-clear")
}
