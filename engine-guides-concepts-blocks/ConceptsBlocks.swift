import Foundation
import IMGLYEngine

@MainActor
func conceptsBlocks(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)
  // highlight-setup

  // highlight-block-types
  // Find the page block - pages contain all design elements
  let pages = try engine.block.find(byType: .page)
  let firstPage = pages[0]

  // Query the block type - returns the full type path
  let pageType = try engine.block.getType(firstPage)
  print("Page block type:", pageType) // '//ly.img.ubq/page'
  // highlight-block-types

  // highlight-type-vs-kind
  // Type is immutable, determined at creation
  // Kind is a custom label you can set and change
  try engine.block.setKind(firstPage, kind: "main-canvas")
  let pageKind = try engine.block.getKind(firstPage)
  print("Page kind:", pageKind) // 'main-canvas'

  // Find blocks by kind
  let mainCanvasBlocks = try engine.block.find(byKind: "main-canvas")
  print("Blocks with kind 'main-canvas':", mainCanvasBlocks.count)
  // highlight-type-vs-kind

  // highlight-block-lifecycle
  // Create a graphic block for an image
  let graphic = try engine.block.create(.graphic)

  // Duplicate creates a copy with a new UUID
  let graphicCopy = try engine.block.duplicate(graphic)

  // Destroy removes a block - the duplicate is no longer needed
  try engine.block.destroy(graphicCopy)

  // Check if a block ID is still valid after operations
  let isOriginalValid = engine.block.isValid(graphic)
  let isCopyValid = engine.block.isValid(graphicCopy)
  print("Original valid:", isOriginalValid) // true
  print("Copy valid after destroy:", isCopyValid) // false
  // highlight-block-lifecycle

  // highlight-fill
  // Create a rect shape to define the graphic's bounds
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(graphic, shape: rectShape)

  // Position and size the graphic
  try engine.block.setPositionX(graphic, value: 200)
  try engine.block.setPositionY(graphic, value: 100)
  try engine.block.setWidth(graphic, value: 400)
  try engine.block.setHeight(graphic, value: 300)

  // Create an image fill and attach it to the graphic
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg",
  )
  try engine.block.setFill(graphic, fill: imageFill)

  // Set content fill mode so the image fills the block bounds
  try engine.block.setEnum(graphic, property: "contentFill/mode", value: "Cover")
  // highlight-fill

  // highlight-block-hierarchy
  // Blocks form a tree: scene > page > elements
  // Append the graphic to the page to make it visible
  try engine.block.appendChild(to: page, child: graphic)

  // Query parent-child relationships
  let graphicParent = try engine.block.getParent(graphic)
  print("Graphic parent is page:", graphicParent == page) // true

  let pageChildren = try engine.block.getChildren(page)
  print("Page has children:", pageChildren.count)
  // highlight-block-hierarchy

  // highlight-text-block
  // Create a text block with content
  let textBlock = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: textBlock)

  // Position the text block
  try engine.block.setPositionX(textBlock, value: 200)
  try engine.block.setPositionY(textBlock, value: 450)
  try engine.block.setWidth(textBlock, value: 400)
  try engine.block.setHeight(textBlock, value: 80)

  // Set text content and styling
  try engine.block.setString(textBlock, property: "text/text", value: "Blocks are the building units of CE.SDK designs")
  try engine.block.setFloat(textBlock, property: "text/fontSize", value: 24)
  try engine.block.setEnum(textBlock, property: "text/horizontalAlignment", value: "Center")

  // Check the text block type
  let textType = try engine.block.getType(textBlock)
  print("Text block type:", textType) // '//ly.img.ubq/text'
  // highlight-text-block

  // highlight-block-properties
  // Use reflection to discover available properties
  let graphicProperties = try engine.block.findAllProperties(graphic)
  print("Graphic block has", graphicProperties.count, "properties")

  // Get property type information
  let opacityType = try engine.block.getType(ofProperty: "opacity")
  print("Opacity property type:", opacityType) // .float

  // Check if properties are readable/writable
  let isOpacityReadable = try engine.block.isPropertyReadable(property: "opacity")
  let isOpacityWritable = try engine.block.isPropertyWritable(property: "opacity")
  print("Opacity readable:", isOpacityReadable, "writable:", isOpacityWritable)
  // highlight-block-properties

  // highlight-property-accessors
  // Use type-specific getters and setters
  // Float properties
  try engine.block.setFloat(graphic, property: "opacity", value: 0.9)
  let opacity = try engine.block.getFloat(graphic, property: "opacity")
  print("Graphic opacity:", opacity)

  // Bool properties
  try engine.block.setBool(page, property: "page/marginEnabled", value: false)
  let marginEnabled = try engine.block.getBool(page, property: "page/marginEnabled")
  print("Page margin enabled:", marginEnabled)

  // Enum properties - get allowed values first
  let blendModes = try engine.block.getEnumValues(ofProperty: "blend/mode")
  print("Available blend modes:", blendModes.prefix(3).joined(separator: ", "), "...")

  try engine.block.setEnum(graphic, property: "blend/mode", value: "Multiply")
  let blendMode = try engine.block.getEnum(graphic, property: "blend/mode")
  print("Graphic blend mode:", blendMode)
  // highlight-property-accessors

  // highlight-uuid-identity
  // Each block has a stable UUID across save/load cycles
  let graphicUUID = try engine.block.getUUID(graphic)
  print("Graphic UUID:", graphicUUID)

  // Block names are mutable labels for organization
  try engine.block.setName(graphic, name: "Hero Image")
  try engine.block.setName(textBlock, name: "Caption")

  let graphicName = try engine.block.getName(graphic)
  print("Graphic name:", graphicName) // 'Hero Image'
  // highlight-uuid-identity

  // highlight-selection
  // Select a block programmatically
  try engine.block.select(graphic) // Selects graphic, deselects others

  // Check selection state
  let isGraphicSelected = try engine.block.isSelected(graphic)
  print("Graphic is selected:", isGraphicSelected) // true

  // Add to selection without deselecting others
  try engine.block.setSelected(textBlock, selected: true)

  // Get all selected blocks
  let selectedBlocks = engine.block.findAllSelected()
  print("Selected blocks count:", selectedBlocks.count) // 2

  // Subscribe to selection changes
  let selectionTask = Task {
    for await _ in engine.block.onSelectionChanged {
      let selected = engine.block.findAllSelected()
      print("Selection changed, now selected:", selected.count, "blocks")
    }
  }
  // highlight-selection

  // highlight-visibility
  // Control block visibility
  try engine.block.setVisible(graphic, visible: true)
  let isVisible = try engine.block.isVisible(graphic)
  print("Graphic is visible:", isVisible)

  // Control export inclusion
  try engine.block.setIncludedInExport(graphic, enabled: true)
  let inExport = try engine.block.isIncludedInExport(graphic)
  print("Graphic included in export:", inExport)
  // highlight-visibility

  // highlight-clipping
  // Control clipping behavior
  try engine.block.setClipped(graphic, clipped: false)
  let isClipped = try engine.block.isClipped(graphic)
  print("Graphic is clipped:", isClipped)
  // highlight-clipping

  // highlight-block-state
  // Query block state - indicates loading status
  let graphicState = try engine.block.getState(graphic)
  print("Graphic state:", graphicState)

  // Subscribe to state changes (useful for loading indicators)
  let stateTask = Task {
    for await changedBlocks in engine.block.onStateChanged([graphic]) {
      for blockID in changedBlocks {
        let state = try engine.block.getState(blockID)
        print("Block \(blockID) state changed to:", state)
      }
    }
  }
  // highlight-block-state

  // highlight-serialization
  // Save blocks to a string for persistence
  let savedString = try await engine.block.saveToString(blocks: [graphic, textBlock])
  print("Blocks saved to string, length:", savedString.count)

  // Load blocks from string (creates new blocks, not attached to scene)
  let loadedBlocks = try await engine.block.load(from: savedString)
  print("Loaded blocks from string:", loadedBlocks.count)

  // Loaded blocks must be parented to appear in the scene
  // For demo purposes, destroy them to avoid duplicates
  for loadedBlock in loadedBlocks {
    try engine.block.destroy(loadedBlock)
  }
  // highlight-serialization

  // Clean up async subscriptions
  selectionTask.cancel()
  stateTask.cancel()
}
