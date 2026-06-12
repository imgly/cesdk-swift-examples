import Foundation
import IMGLYEngine

@MainActor
func collage(engine: Engine) async throws {
  // Demo scaffolding: build a source scene with two images and one caption so the
  // collage workflow has content to transfer. In a real app this is whatever the
  // user already has open in the editor.
  let scene = try engine.scene.create()
  let baseURL = try engine.guidesBaseURL
  let sourcePage = try makeCollagePage(engine: engine, width: 1080, height: 1080)
  try engine.block.appendChild(to: scene, child: sourcePage)

  let leftImage = try makeImageSlot(
    engine: engine, x: 40, y: 40, width: 480, height: 1000,
    uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.appendChild(to: sourcePage, child: leftImage)

  let rightImage = try makeImageSlot(
    engine: engine, x: 560, y: 40, width: 480, height: 760,
    uri: baseURL.appendingPathComponent("ly.img.image/images/sample_4.jpg"),
  )
  try engine.block.appendChild(to: sourcePage, child: rightImage)

  let caption = try makeTextBlock(
    engine: engine, x: 560, y: 820, width: 480,
    text: "Summer Memories", color: .rgba(r: 0.05, g: 0.05, b: 0.05, a: 1),
  )
  try engine.block.appendChild(to: sourcePage, child: caption)

  try await engine.captureGuide(sourcePage, label: "before-layout")

  let layoutData = try await makeFourUpLayout(engine: engine, baseURL: baseURL, width: 1080, height: 1080)

  // highlight-collage-applyLayout
  let collagedPage = try await applyCollageLayout(
    engine: engine,
    page: sourcePage,
    layoutData: layoutData,
    addUndoStep: true,
  )
  // highlight-collage-applyLayout

  try await engine.captureGuide(collagedPage, label: "hero")
}

// MARK: - Page and Slot Helpers

// highlight-collage-pageHelper
@MainActor
private func makeCollagePage(
  engine: Engine,
  width: Float,
  height: Float,
) throws -> DesignBlockID {
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: width)
  try engine.block.setHeight(page, value: height)
  return page
}

// highlight-collage-pageHelper

// highlight-collage-imageSlotHelper
@MainActor
private func makeImageSlot(
  engine: Engine,
  x: Float, y: Float,
  width: Float, height: Float,
  uri: URL,
) throws -> DesignBlockID {
  let graphic = try engine.block.create(.graphic)
  try engine.block.setShape(graphic, shape: engine.block.createShape(.rect))
  let fill = try engine.block.createFill(.image)
  try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: uri)
  try engine.block.setFill(graphic, fill: fill)
  try engine.block.setPositionX(graphic, value: x)
  try engine.block.setPositionY(graphic, value: y)
  try engine.block.setWidth(graphic, value: width)
  try engine.block.setHeight(graphic, value: height)
  return graphic
}

// highlight-collage-imageSlotHelper

// highlight-collage-textBlockHelper
@MainActor
private func makeTextBlock(
  engine: Engine,
  x: Float, y: Float,
  width: Float,
  text: String,
  color: Color,
) throws -> DesignBlockID {
  let block = try engine.block.create(.text)
  try engine.block.replaceText(block, text: text)
  try engine.block.setColor(block, property: "fill/solid/color", color: color)
  try engine.block.setPositionX(block, value: x)
  try engine.block.setPositionY(block, value: y)
  try engine.block.setWidth(block, value: width)
  return block
}

// highlight-collage-textBlockHelper

// MARK: - Define a Layout

// highlight-collage-defineLayout
@MainActor
private func makeFourUpLayout(
  engine: Engine,
  baseURL: URL,
  width: Float,
  height: Float,
) async throws -> String {
  let layoutPage = try makeCollagePage(engine: engine, width: width, height: height)
  let halfWidth = (width - 60) / 2
  let halfHeight = (height - 60) / 2 - 40
  let placeholders = [
    baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg"),
    baseURL.appendingPathComponent("ly.img.image/images/sample_3.jpg"),
    baseURL.appendingPathComponent("ly.img.image/images/sample_5.jpg"),
    baseURL.appendingPathComponent("ly.img.image/images/sample_6.jpg"),
  ]

  try engine.block.appendChild(to: layoutPage, child: try makeImageSlot(
    engine: engine, x: 20, y: 20,
    width: halfWidth, height: halfHeight, uri: placeholders[0],
  ))
  try engine.block.appendChild(to: layoutPage, child: try makeImageSlot(
    engine: engine, x: 40 + halfWidth, y: 20,
    width: halfWidth, height: halfHeight, uri: placeholders[1],
  ))
  try engine.block.appendChild(to: layoutPage, child: try makeImageSlot(
    engine: engine, x: 20, y: 40 + halfHeight,
    width: halfWidth, height: halfHeight, uri: placeholders[2],
  ))
  try engine.block.appendChild(to: layoutPage, child: try makeImageSlot(
    engine: engine, x: 40 + halfWidth, y: 40 + halfHeight,
    width: halfWidth, height: halfHeight, uri: placeholders[3],
  ))

  try engine.block.appendChild(to: layoutPage, child: try makeTextBlock(
    engine: engine, x: 20, y: height - 60,
    width: width - 40, text: "Layout Caption",
    color: .rgba(r: 0.2, g: 0.2, b: 0.2, a: 1),
  ))

  let saved = try await engine.block.saveToString(blocks: [layoutPage])
  try engine.block.destroy(layoutPage)
  return saved
}

// highlight-collage-defineLayout

// MARK: - Apply a Layout to a Page

// highlight-collage-layoutWorkflow
@MainActor
private func applyCollageLayout(
  engine: Engine,
  page: DesignBlockID,
  layoutData: String,
  addUndoStep: Bool,
) async throws -> DesignBlockID {
  let previousDestroyScope = try engine.editor.getGlobalScope(key: "lifecycle/destroy")
  try engine.editor.setGlobalScope(key: "lifecycle/destroy", value: .allow)
  defer {
    try? engine.editor.setGlobalScope(key: "lifecycle/destroy", value: previousDestroyScope)
  }

  for selected in engine.block.findAllSelected() {
    try engine.block.setSelected(selected, selected: false)
  }

  let oldPageBackup = try engine.block.duplicate(page, attachToParent: false)
  let loadedBlocks = try await engine.block.load(from: layoutData)
  guard let layoutPage = loadedBlocks.first else {
    throw NSError(domain: "Collage", code: 1, userInfo: [
      NSLocalizedDescriptionKey: "Saved layout string did not contain a page.",
    ])
  }

  for child in try engine.block.getChildren(page) {
    try engine.block.destroy(child)
  }
  for (index, child) in try engine.block.getChildren(layoutPage).enumerated() {
    try engine.block.insertChild(into: page, child: child, at: index)
  }

  try transferCollageContent(engine: engine, from: oldPageBackup, to: page)

  try engine.block.destroy(oldPageBackup)
  try engine.block.destroy(layoutPage)
  if addUndoStep {
    try engine.editor.addUndoStep()
  }
  return page
}

// highlight-collage-layoutWorkflow

// MARK: - Transfer Content Between Pages

// highlight-collage-transferContent
@MainActor
private func transferCollageContent(
  engine: Engine,
  from sourcePage: DesignBlockID,
  to targetPage: DesignBlockID,
) throws {
  let sourceBlocks = try visuallySortBlocks(
    engine: engine,
    blocks: collectDescendants(engine: engine, root: sourcePage),
  )
  let targetBlocks = try visuallySortBlocks(
    engine: engine,
    blocks: collectDescendants(engine: engine, root: targetPage),
  )

  let sourceImages = try sourceBlocks.filter { try isImageSlot(engine: engine, block: $0) }
  let targetImages = try targetBlocks.filter { try isImageSlot(engine: engine, block: $0) }
  for (source, target) in zip(sourceImages, targetImages) {
    try copyImage(engine: engine, from: source, to: target)
  }

  let sourceTexts = try sourceBlocks.filter { try engine.block.getType($0) == DesignBlockType.text.rawValue }
  let targetTexts = try targetBlocks.filter { try engine.block.getType($0) == DesignBlockType.text.rawValue }
  for (source, target) in zip(sourceTexts, targetTexts) {
    try copyText(engine: engine, from: source, to: target)
  }
}

// highlight-collage-transferContent

// MARK: - Visual Sort

// highlight-collage-visualSort
private struct SortedBlock {
  let block: DesignBlockID
  let x: Int
  let y: Int
}

@MainActor
private func collectDescendants(
  engine: Engine,
  root: DesignBlockID,
) throws -> [DesignBlockID] {
  var result: [DesignBlockID] = []
  for child in try engine.block.getChildren(root) {
    result.append(child)
    result.append(contentsOf: try collectDescendants(engine: engine, root: child))
  }
  return result
}

@MainActor
private func accumulatedPosition(
  engine: Engine,
  block: DesignBlockID,
) throws -> (x: Int, y: Int) {
  var x: Float = 0
  var y: Float = 0
  var current: DesignBlockID? = block
  while let id = current {
    x += try engine.block.getPositionX(id)
    y += try engine.block.getPositionY(id)
    current = try engine.block.getParent(id)
  }
  return (Int(x.rounded()), Int(y.rounded()))
}

@MainActor
private func visuallySortBlocks(
  engine: Engine,
  blocks: [DesignBlockID],
) throws -> [DesignBlockID] {
  let measured = try blocks.map { block -> SortedBlock in
    let position = try accumulatedPosition(engine: engine, block: block)
    return SortedBlock(block: block, x: position.x, y: position.y)
  }
  return measured
    .sorted { lhs, rhs in
      if lhs.y == rhs.y { return lhs.x < rhs.x }
      return lhs.y < rhs.y
    }
    .map(\.block)
}

// highlight-collage-visualSort

// MARK: - Copy Images

// highlight-collage-imageSlotCheck
@MainActor
private func isImageSlot(
  engine: Engine,
  block: DesignBlockID,
) throws -> Bool {
  guard try engine.block.getType(block) == DesignBlockType.graphic.rawValue else { return false }
  guard try engine.block.supportsFill(block) else { return false }
  let fill = try engine.block.getFill(block)
  return try engine.block.getType(fill) == FillType.image.rawValue
}

// highlight-collage-imageSlotCheck

// highlight-collage-copyImages
@MainActor
private func copyImage(
  engine: Engine,
  from source: DesignBlockID,
  to target: DesignBlockID,
) throws {
  let sourceFill = try engine.block.getFill(source)
  let targetFill = try engine.block.getFill(target)

  let uri = try engine.block.getString(sourceFill, property: "fill/image/imageFileURI")
  try engine.block.setString(targetFill, property: "fill/image/imageFileURI", value: uri)

  let sources = try engine.block.getSourceSet(sourceFill, property: "fill/image/sourceSet")
  try engine.block.setSourceSet(targetFill, property: "fill/image/sourceSet", sourceSet: sources)

  try engine.block.resetCrop(target)

  if try engine.block.supportsPlaceholderBehavior(source),
     try engine.block.supportsPlaceholderBehavior(target) {
    let enabled = try engine.block.isPlaceholderBehaviorEnabled(source)
    try engine.block.setPlaceholderBehaviorEnabled(target, enabled: enabled)
  }
}

// highlight-collage-copyImages

// MARK: - Copy Text

// highlight-collage-copyText
@MainActor
private func copyText(
  engine: Engine,
  from source: DesignBlockID,
  to target: DesignBlockID,
) throws {
  let text = try engine.block.getString(source, property: "text/text")
  try engine.block.replaceText(target, text: text)

  // Font transfer is best-effort: an unresolved URI must not abort the
  // collage update.
  if let typeface = try? engine.block.getTypeface(source) {
    let fontURIString = try engine.block.getString(source, property: "text/fontFileUri")
    if let fontURL = URL(string: fontURIString) {
      try? engine.block.setFont(target, fontFileURL: fontURL, typeface: typeface)
    }
  }

  if let color: Color = try? engine.block.getColor(source, property: "fill/solid/color") {
    try engine.block.setColor(target, property: "fill/solid/color", color: color)
  }
}

// highlight-collage-copyText
