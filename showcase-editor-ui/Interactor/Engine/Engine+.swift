import IMGLYCore
import IMGLYEngine
import SwiftUI
import UniformTypeIdentifiers

private struct Random: RandomNumberGenerator {
  init(seed: Int) {
    srand48(seed)
  }

  func next() -> UInt64 {
    // swiftlint:disable:next legacy_random
    UInt64(drand48() * Double(UInt64.max))
  }
}

extension Engine {
  private var engine: Engine { self }

  private static var rng: RandomNumberGenerator = ProcessInfo
    .isUITesting ? Random(seed: 0) : SystemRandomNumberGenerator()

  // MARK: - Scene

  static let outlineBlockName = "always-on-top-page-outline"

  public func showOutline(_ isVisible: Bool) throws {
    let outline = try getOutline()
    try engine.block.setVisible(outline, visible: isVisible)
    // Workaround: Trigger opacity to force refresh on "fast" devices.
    try engine.block.setOpacity(outline, value: isVisible ? 1 : 0)
  }

  public func selectionColors(forPage index: Int, includeUnnamed: Bool = false, includeDisabled: Bool = false,
                              setDisabled: Bool = false, ignoreScope: Bool = false) throws -> SelectionColors {
    try selectionColors(
      getPage(index),
      includeUnnamed: includeUnnamed,
      includeDisabled: includeDisabled,
      setDisabled: setDisabled,
      ignoreScope: ignoreScope
    )
  }

  private func getSelectionColors(_ id: DesignBlockID, includeUnnamed: Bool, includeDisabled: Bool, setDisabled: Bool,
                                  ignoreScope: Bool, selectionColors: inout SelectionColors) throws {
    guard try engine.block.isScopeEnabled(id, key: ScopeKey.designStyle.rawValue) || ignoreScope else {
      return
    }
    let name = try engine.block.getName(id)
    guard !name.isEmpty || includeUnnamed else {
      return
    }

    func addColor(property: Property, includeDisabled: Bool = false) throws -> CGColor? {
      guard let enabled = property.enabled, try engine.block.get(id, property: enabled) || includeDisabled else {
        return nil
      }
      if property == .key(.fillSolidColor),
         let fillType: FillType = try? engine.block.get(id, .fill, property: .key(.type)),
         fillType == .gradient {
        let colorStops: [GradientColorStop] = try engine.block.get(id, .fill, property: .key(.fillGradientColors))
        if let color = colorStops.first?.color.cgColor {
          selectionColors.add(id, property: property, value: color, name: name)
          return color
        }
        return nil
      } else {
        let color: CGColor = try engine.block.get(id, property: property)
        selectionColors.add(id, property: property, value: color, name: name)
        return color
      }
    }

    let hasFill = try engine.block.hasFill(id)
    let hasStroke = try engine.block.hasStroke(id)

    if hasFill, hasStroke {
      // Assign enabled color to disabled color to ease template creation.
      let fillColor = try addColor(property: .key(.fillSolidColor))
      let strokeColor = try addColor(property: .key(.strokeColor))

      func setAndAddColor(property: Property, color: CGColor) throws {
        if setDisabled, try engine.block.get(id, property: property) != color {
          try engine.block.overrideAndRestore(id, scope: .key(.designStyle)) {
            try engine.block.set($0, property: property, value: color)
          }
        }
        _ = try addColor(property: property, includeDisabled: includeDisabled)
      }

      if fillColor == nil, let strokeColor {
        try setAndAddColor(property: .key(.fillSolidColor), color: strokeColor)
      } else if strokeColor == nil, let fillColor {
        try setAndAddColor(property: .key(.strokeColor), color: fillColor)
      } else {
        _ = try addColor(property: .key(.fillSolidColor), includeDisabled: includeDisabled)
        _ = try addColor(property: .key(.strokeColor), includeDisabled: includeDisabled)
      }
    } else if hasFill {
      _ = try addColor(property: .key(.fillSolidColor), includeDisabled: includeDisabled)
    } else if hasStroke {
      _ = try addColor(property: .key(.strokeColor), includeDisabled: includeDisabled)
    }
  }

  /// Traverse design block hierarchy and collect used colors.
  /// - Attention: Use `setDisabled` with care!
  /// - Parameters:
  ///   - id: Parent block `id` to start traversal.
  ///   - includeUnnamed: Include colors of unnamed blocks.
  ///   - includeDisabled: Include currently invisible colors of disabled properties.
  ///   - setDisabled: Assign colors of enabled properties to colors of disabled properties of the same block to ease
  /// scene template creation.
  /// - Returns: The collected selection colors.
  func selectionColors(_ id: DesignBlockID, includeUnnamed: Bool, includeDisabled: Bool,
                       setDisabled: Bool, ignoreScope: Bool) throws -> SelectionColors {
    if setDisabled {
      print(
        // swiftlint:disable:next line_length
        "Assigning colors of enabled properties to colors of disabled properties of the same block while collecting selection colors."
      )
    }
    func traverse(_ id: DesignBlockID, selectionColors: inout SelectionColors) throws {
      try getSelectionColors(
        id,
        includeUnnamed: includeUnnamed,
        includeDisabled: includeDisabled,
        setDisabled: setDisabled,
        ignoreScope: ignoreScope,
        selectionColors: &selectionColors
      )
      let children = try engine.block.getChildren(id)
      for child in children {
        try traverse(child, selectionColors: &selectionColors)
      }
    }

    var selectionColors = SelectionColors()
    try traverse(id, selectionColors: &selectionColors)

    return selectionColors
  }

  // MARK: - Zoom

  func showAllPages(layout: LayoutAxis, spacing: Float = 16) throws {
    try showPage(index: nil, layout: layout, spacing: spacing)
  }

  func showPage(_ index: Int) throws {
    try showPage(index: index, layout: .depth)
  }

  private func showPage(index: Int?, layout axis: LayoutAxis, spacing: Float? = nil) throws {
    try engine.block.deselectAll()

    let allPages = index == nil
    try engine.block.set(getStack(), property: .key(.stackAxis), value: axis)
    if let spacing {
      try engine.block.set(getStack(), property: .key(.stackSpacing), value: spacing)
    }

    let pages = try getSortedPages()
    for (i, block) in pages.enumerated() {
      try engine.block.overrideAndRestore(block, scope: .key(.designStyle)) {
        try engine.block.setVisible($0, visible: allPages || i == index)
      }
    }
  }

  public func zoomToBackdrop(_ insets: EdgeInsets?) async throws {
    try await zoomToBlock(getBackdropImage(), with: insets)
  }

  func zoomToScene(_ insets: EdgeInsets?) async throws {
    try await zoomToBlock(getScene(), with: insets)
  }

  func zoomToPage(_ index: Int, _ insets: EdgeInsets?) async throws {
    try await zoomToBlock(getPage(index), with: insets)
  }

  func zoomToSelectedElement(_ insets: EdgeInsets?) async throws {
    if let block = engine.block.findAllSelected().first {
      try await zoomToBlock(block, with: insets)
    }
  }

  func zoomToBlock(_ block: DesignBlockID, with insets: EdgeInsets?) async throws {
    try await engine.scene.zoom(
      to: block,
      paddingLeft: Float(insets?.leading ?? 0),
      paddingTop: Float(insets?.top ?? 0),
      paddingRight: Float(insets?.trailing ?? 0),
      paddingBottom: Float(insets?.bottom ?? 0)
    )
  }

  func zoomToSelectedText(_ insets: EdgeInsets?, canvasHeight: CGFloat) throws {
    let paddingTop = insets?.top ?? 0
    let paddingBottom = insets?.bottom ?? 0

    let overlapTop: CGFloat = 50
    let overlapBottom: CGFloat = 50

    let selectedTexts = engine.block.findAllSelected()
    if selectedTexts.count == 1 {
      let cursorPosY = CGFloat(engine.editor.getTextCursorPositionInScreenSpaceY())
      // The first cursorPosY is 0 if no cursor has been layouted yet. Then we ignore zoom commands.
      let cursorPosIsValid = cursorPosY != 0
      if !cursorPosIsValid {
        return
      }
      let visiblePageAreaY = (canvasHeight - overlapBottom - paddingBottom)

      let visiblePageAreaYCanvas = try pointToCanvasUnit(visiblePageAreaY)
      let cursorPosYCanvas = try pointToCanvasUnit(cursorPosY)
      let cameraPosY = try engine.block.getPositionY(getCamera())

      let newCameraPosY = cursorPosYCanvas + cameraPosY - visiblePageAreaYCanvas

      if cursorPosY > visiblePageAreaY ||
        cursorPosY < (overlapTop + paddingTop) {
        try engine.block.overrideAndRestore(getCamera(), scope: .key(.designArrangeMove)) {
          try engine.block.setPositionY($0, value: newCameraPosY)
        }
      }
    }
  }

  // MARK: - Add

  func addText(_ url: URL, fontSize: CGFloat, toPage index: Int) throws {
    let fontSize = (50.0 / 24.0) * Float(fontSize) // Scale font size to match scene.
    let block = try engine.block.create(.text)
    try engine.block.set(block, property: .key(.textFontFileURI), value: url)
    try engine.block.set(block, property: .key(.textFontSize), value: fontSize)
    try engine.block.set(block, property: .key(.textHorizontalAlignment), value: HorizontalAlignment.center)
    try engine.block.setHeightMode(block, mode: .auto)
    try addBlock(block, toPage: index)
  }

  // MARK: - Actions

  func bringToFrontSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      try engine.block.bringToFront($0)
    }
    try engine.editor.addUndoStep()
  }

  func bringForwardSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      try engine.block.bringForward($0)
    }
    try engine.editor.addUndoStep()
  }

  func sendBackwardSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      try engine.block.sendBackward($0)
    }
    try engine.editor.addUndoStep()
  }

  func sendToBackSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      try engine.block.sendToBack($0)
    }
    try engine.editor.addUndoStep()
  }

  func duplicateSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      let duplicate = try engine.block.duplicate($0)

      // Remember values
      let positionModeX = try engine.block.getPositionXMode($0)
      let positionModeY = try engine.block.getPositionYMode($0)

      try engine.block.overrideAndRestore($0, scope: .key(.designArrangeMove)) {
        try engine.block.setPositionXMode($0, mode: .absolute)
        let x = try engine.block.getPositionX($0)
        try engine.block.setPositionYMode($0, mode: .absolute)
        let y = try engine.block.getPositionY($0)

        try engine.block.setPositionXMode(duplicate, mode: .absolute)
        try engine.block.setPositionX(duplicate, value: x + 5)
        try engine.block.setPositionYMode(duplicate, mode: .absolute)
        try engine.block.setPositionY(duplicate, value: y - 5)

        // Restore values
        try engine.block.setPositionXMode($0, mode: positionModeX)
        try engine.block.setPositionYMode($0, mode: positionModeY)
      }

      try engine.block.setSelected(duplicate, selected: true)
      try engine.block.setSelected($0, selected: false)
    }
    try engine.editor.addUndoStep()
  }

  func deleteSelectedElement(delay nanoseconds: UInt64 = .zero) throws {
    let ids = engine.block.findAllSelected()

    func delete() throws {
      try ids.forEach {
        try engine.block.destroy($0)
      }
      try engine.editor.addUndoStep()
    }

    if nanoseconds != .zero {
      // Delay real deletion, e.g., to wait for sheet disappear animations
      // to complete but fake deletion in the meantime.
      try ids.forEach {
        try engine.block.overrideAndRestore($0, scope: .key(.designStyle)) {
          try engine.block.setOpacity($0, value: 0)
        }
        try engine.block.setSelected($0, selected: false)
      }
      Task {
        try await Task.sleep(nanoseconds: nanoseconds)
        try delete()
      }
    } else {
      try delete()
    }
  }

  func resetCropSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      try engine.block.overrideAndRestore($0, scope: .key(.designStyle)) {
        // Reset crop requires "design/style" scope but crop UI should be based on "content/replace".
        try engine.block.resetCrop($0)
      }
    }
    try engine.editor.addUndoStep()
  }

  func flipCropSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      try engine.block.flipCropHorizontal($0)
    }
    try engine.editor.addUndoStep()
  }

  // MARK: - Utilities

  func set(_ ids: [DesignBlockID], _ propertyBlock: PropertyBlock? = nil,
           property: Property, value: some MappedType,
           completion: Interactor.PropertyCompletion? = Interactor.Completion.addUndoStep) throws -> Bool {
    let valid = ids.filter {
      engine.block.isValid($0)
    }
    let didChange = try engine.block.set(valid, propertyBlock, property: property, value: value)
    return try (completion?(engine, valid, didChange) ?? false) || didChange
  }

  private func pointToCanvasUnit(_ point: CGFloat) throws -> Float {
    let sceneUnit = try engine.block.getEnum(getScene(), property: "scene/designUnit")
    var densityFactor: Float = 1
    if sceneUnit == "Millimeter" {
      densityFactor = try engine.block.get(getScene(), property: .key(.sceneDPI)) / 25.4
    }
    if sceneUnit == "Inch" {
      densityFactor = try engine.block.get(getScene(), property: .key(.sceneDPI))
    }
    let zoomLevel = try engine.scene.getZoom()
    return Float(point) / (densityFactor * zoomLevel)
  }

  // All non-text blocks in this demo should be added with the same square size
  private func setSize(_ block: DesignBlockID) throws {
    try engine.block.setHeightMode(block, mode: .absolute)
    try engine.block.setHeight(block, value: 40)
    try engine.block.setWidthMode(block, mode: .absolute)
    try engine.block.setWidth(block, value: 40)
  }

  // Appends a block into the scene and positions it somewhat randomly.
  private func addBlock(_ block: DesignBlockID, toPage index: Int) throws {
    try engine.block.deselectAll()
    try engine.block.appendChild(to: getPage(index), child: block)

    try engine.block.setPositionXMode(block, mode: .absolute)
    try engine.block.setPositionX(block, value: 15 + Float.random(in: 0 ... 1, using: &Self.rng) * 20)
    try engine.block.setPositionYMode(block, mode: .absolute)
    try engine.block.setPositionY(block, value: 5 + Float.random(in: 0 ... 1, using: &Self.rng) * 20)

    try engine.block.setSelected(block, selected: true)
    try engine.editor.addUndoStep()
  }

  // Note: Backdrop Images are not officially supported yet.
  // The backdrop image is the only image that is a direct child of the scene block.
  private func getBackdropImage() throws -> DesignBlockID {
    let childIDs = try engine.block.getChildren(getScene())
    let imageID = try childIDs.first {
      try engine.block.getType($0) == DesignBlockType.image.rawValue
    }
    guard let imageID else {
      throw Error(errorDescription: "No backdrop image found.")
    }
    return imageID
  }

  private func getAllSelectedElements(of elementType: DesignBlockType? = nil) throws -> [DesignBlockID] {
    try getAllSelectedElements(of: elementType?.rawValue)
  }

  private func getAllSelectedElements(of elementType: String? = nil) throws -> [DesignBlockID] {
    let allSelected = engine.block.findAllSelected()

    guard let elementType else {
      return allSelected
    }

    return try allSelected.filter {
      try engine.block.getType($0).starts(with: elementType)
    }
  }

  private func getCamera() throws -> DesignBlockID {
    guard let camera = try engine.block.find(byType: .camera).first else {
      throw Error(errorDescription: "No camera found.")
    }
    return camera
  }

  private func getStack() throws -> DesignBlockID {
    guard let stack = try engine.block.find(byType: .stack).first else {
      throw Error(errorDescription: "No stack found.")
    }
    return stack
  }

  public func getPage(_ index: Int) throws -> DesignBlockID {
    let pages = try getSortedPages()
    guard index < pages.endIndex else {
      throw Error(errorDescription: "Invalid page index.")
    }
    return pages[index]
  }

  func getSortedPages() throws -> [DesignBlockID] {
    try engine.block.getChildren(getStack())
  }

  func getScene() throws -> DesignBlockID {
    guard let scene = try engine.block.find(byType: .scene).first else {
      throw Error(errorDescription: "No scene found.")
    }
    return scene
  }

  private func getOutline() throws -> DesignBlockID {
    guard let outline = engine.block.find(byName: Self.outlineBlockName).first else {
      throw Error(errorDescription: "No outline found.")
    }
    return outline
  }
}
