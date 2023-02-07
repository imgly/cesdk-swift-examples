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

  private static var isUITesting = ProcessInfo.processInfo.arguments.contains("UI-Testing")
  private static var rng: RandomNumberGenerator = isUITesting ? Random(seed: 0) : SystemRandomNumberGenerator()

  // MARK: - Scene

  static let basePath = URL(string: "https://cdn.img.ly/packages/imgly/cesdk-js/latest/assets")!

  func loadScene(from url: URL, with insets: EdgeInsets? = nil) async throws {
    try engine.editor.setSettingBool("ubq://touch/singlePointPanning", value: true)
    try engine.editor.setSettingBool("ubq://touch/dragStartCanSelect", value: false)
    try engine.editor.setSettingEnum("ubq://touch/pinchAction", value: "Zoom")
    try engine.editor.setSettingEnum("ubq://touch/rotateAction", value: "None")
    try engine.editor.setSettingBool("ubq://doubleClickToCropEnabled", value: false)
    try engine.editor.setSettingString("ubq://basePath", value: Self.basePath.absoluteString)
    try engine.editor.setSettingEnum("role", value: "Adopter")
    try [
      "design/style",
      "design/arrange",
      "design/arrange/move",
      "design/arrange/resize",
      "design/arrange/rotate",
      "design/arrange/flip",
      "content/replace",
      "lifecycle/destroy",
      "lifecycle/duplicate",
//      "editor/add", // Cannot be restricted in web Dektop UI for now.
      "editor/select"
    ].forEach { scope in
      try engine.editor.setGlobalScope(key: scope, value: .defer)
    }
    _ = try await engine.scene.load(fromURL: url)
    try enableEditMode()
    try await zoomToPage(insets)
    try engine.editor.addUndoStep()
  }

  func exportScene() async throws -> (Data, UTType) {
    var data = Data()
    try await overrideAndRestore(getPage(), scope: "design/style") {
      let prevPageFill = try engine.block.getBool(getPage(), property: "fill/enabled")
      try engine.block.setBool($0, property: "fill/enabled", value: true)
      // We always want a background color when exporting
      data = try await engine.block.export(getPage(), mimeType: .pdf)
      try engine.block.setBool($0, property: "fill/enabled", value: prevPageFill)
    }
    return (data, UTType.pdf)
  }

  // MARK: - Mode

  func enablePreviewMode() throws {
    try deselectAllBlocks()

    try overrideAndRestore(getPage(), scope: "design/style") {
      try engine.editor.setSettingBool("ubq://page/dimOutOfPageAreas", value: false)
      try engine.block.setClipped($0, clipped: true)
      try engine.block.setBool($0, property: "fill/enabled", value: false)
    }
  }

  func enableEditMode() throws {
    try overrideAndRestore(getPage(), scope: "design/style") {
      try engine.editor.setSettingBool("ubq://page/dimOutOfPageAreas", value: true)
      try engine.block.setClipped($0, clipped: false)
      try engine.block.setBool($0, property: "fill/enabled", value: true)
    }
  }

  // MARK: - Zoom

  func zoomToBackdrop(_ insets: EdgeInsets?) async throws {
    try await zoomToBlock(getBackdropImage(), with: insets)
  }

  func zoomToPage(_ insets: EdgeInsets?) async throws {
    try await zoomToBlock(getPage(), with: insets)
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
        try overrideAndRestore(getCamera(), scope: "design/arrange/move") {
          try engine.block.setPositionY($0, value: newCameraPosY)
        }
      }
    }
  }

  // MARK: - Add

  func addText() throws {
    let block = try engine.block.create(.text)
    try engine.block.setString(
      block,
      property: "text/fontFileUri",
      value: Font.basePath.appending(path: "fonts/Roboto/Roboto-Regular.ttf").absoluteString
    )
    try engine.block.setFloat(block, property: "text/fontSize", value: 50)
    try engine.block.setEnum(block, property: "text/horizontalAlignment", value: "Center")
    try engine.block.setHeightMode(block, mode: .auto)
    try addBlockToPage(block)
  }

  func addImage(_ url: URL) async throws {
    let (data, _) = try await URLSession.shared.data(from: url)
    guard let image = UIImage(data: data) else {
      return
    }

    let block = try engine.block.create(.image)
    try engine.block.setString(block, property: "image/imageFileURI", value: url.absoluteString)
    let (width, height) = (image.size.width, image.size.height)
    let imageAspectRatio = Float(width) / Float(height)
    let baseHeight: Float = 50

    try engine.block.setHeightMode(block, mode: .absolute)
    try engine.block.setHeight(block, value: baseHeight)
    try engine.block.setWidthMode(block, mode: .absolute)
    try engine.block.setWidth(block, value: baseHeight * imageAspectRatio)

    try addBlockToPage(block)
  }

  func addShape(_ shapeBlockType: DesignBlockType) throws {
    let block = try engine.block.create(shapeBlockType)
    try setSize(block)
    // Set default parameters for some shape types
    // When we add a polygon, we add a triangle
    if shapeBlockType == .polygonShape {
      try engine.block.setInt(block, property: "shapes/polygon/sides", value: 3)
    }
    // When we add a line, we need to resize the height again
    else if shapeBlockType == .lineShape {
      try engine.block.setHeightMode(block, mode: .absolute)
      try engine.block.setHeight(block, value: 1)
    } else if shapeBlockType == .starShape {
      try engine.block.setFloat(block, property: "shapes/star/innerDiameter", value: 0.4)
    }
    try addBlockToPage(block)
  }

  func addSticker(_ url: URL) throws {
    let block = try engine.block.create(.sticker)
    try engine.block.setString(block, property: "sticker/imageFileURI", value: url.absoluteString)
    try setSize(block)
    try addBlockToPage(block)
  }

  // MARK: - Actions

  func isAllowedForSelectedElement(_ scope: String) throws -> Bool {
    let allSelected = engine.block.findAllSelected()
    if allSelected.isEmpty {
      return true // Default to true for convenient SwiftUI previews as there is initially nothing selected.
    }
    return try allSelected.allSatisfy {
      try engine.block.isAllowedByScope($0, key: scope)
    }
  }

  func canBringForwardSelectedElement() throws -> Bool {
    let allSelected = engine.block.findAllSelected()
    guard allSelected.count == 1, let selectedBlock = allSelected.first else {
      return false
    }

    if let parent = try engine.block.getParent(selectedBlock) {
      let children = try engine.block.getChildren(parent)
      return children.last != selectedBlock
    }
    return false
  }

  func canBringBackwardSelectedElement() throws -> Bool {
    let allSelected = engine.block.findAllSelected()
    guard allSelected.count == 1, let selectedBlock = allSelected.first else {
      return false
    }

    if let parent = try engine.block.getParent(selectedBlock) {
      let children = try engine.block.getChildren(parent)
      return children.first != selectedBlock
    }
    return false
  }

  func bringToFrontSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      if let parent = try engine.block.getParent($0) {
        let children = try engine.block.getChildren(parent)
        if let index = children.firstIndex(of: $0), index < children.endIndex - 1 {
          try engine.block.appendChild(to: parent, child: $0)
        }
      }
    }
    try engine.editor.addUndoStep()
  }

  func bringForwardSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      if let parent = try engine.block.getParent($0) {
        let children = try engine.block.getChildren(parent)
        if let index = children.firstIndex(of: $0), index < children.endIndex - 1 {
          try engine.block.insertChild(into: parent, child: $0, at: index + 1)
        }
      }
    }
    try engine.editor.addUndoStep()
  }

  func sendBackwardSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      if let parent = try engine.block.getParent($0) {
        let children = try engine.block.getChildren(parent)
        if let index = children.firstIndex(of: $0), index > 0 {
          try engine.block.insertChild(into: parent, child: $0, at: index - 1)
        }
      }
    }
    try engine.editor.addUndoStep()
  }

  func sendToBackSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      if let parent = try engine.block.getParent($0) {
        let children = try engine.block.getChildren(parent)
        if let index = children.firstIndex(of: $0), index > 0 {
          try engine.block.insertChild(into: parent, child: $0, at: 0)
        }
      }
    }
    try engine.editor.addUndoStep()
  }

  func duplicateSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      let duplicate = try engine.block.duplicate($0)

      // Remember values
      let positionModeX = try engine.block.getPositionXMode($0)
      let positionModeY = try engine.block.getPositionYMode($0)

      try overrideAndRestore($0, scope: "design/arrange/move") {
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

  func deleteSelectedElement() throws {
    try engine.block.findAllSelected().forEach {
      try engine.block.destroy($0)
    }
    try engine.editor.addUndoStep()
  }

  // MARK: - Utilities

  func deselectAllBlocks() throws {
    try engine.block.findAllSelected().forEach {
      try engine.block.setSelected($0, selected: false)
    }
  }

  func set(_ ids: [DesignBlockID], _ propertyBlock: PropertyBlock? = nil,
           property: String, value: some MappedType,
           completion: Interactor.SetPropertyCompletion? = Interactor.Completion.addUndoStep) throws {
    let valid = ids.filter {
      engine.block.isValid($0)
    }
    let didChange = try engine.block.set(valid, propertyBlock, property: property, value: value)
    try completion?(engine, valid, didChange)
  }

  func overrideAndRestore(_ block: DesignBlockID, scope: String,
                          action: (DesignBlockID) throws -> Void) throws {
    try overrideAndRestore(block, scopes: [scope], action: action)
  }

  func overrideAndRestore(_ block: DesignBlockID, scopes: Set<String>,
                          action: (DesignBlockID) throws -> Void) throws {
    let isScopeEnabled = try scopes.map { scope in
      let wasEnabled = try engine.block.isScopeEnabled(block, key: scope)
      try engine.block.setScopeEnabled(block, key: scope, enabled: true)
      return (scope: scope, isEnabled: wasEnabled)
    }

    try action(block)

    try isScopeEnabled.forEach { scope, isEnabled in
      try engine.block.setScopeEnabled(block, key: scope, enabled: isEnabled)
    }
  }

  func overrideAndRestore(_ block: DesignBlockID, scope: String,
                          action: (DesignBlockID) async throws -> Void) async throws {
    try await overrideAndRestore(block, scopes: [scope], action: action)
  }

  func overrideAndRestore(_ block: DesignBlockID, scopes: Set<String>,
                          action: (DesignBlockID) async throws -> Void) async throws {
    let isScopeEnabled = try scopes.map { scope in
      let wasEnabled = try engine.block.isScopeEnabled(block, key: scope)
      try engine.block.setScopeEnabled(block, key: scope, enabled: true)
      return (scope: scope, isEnabled: wasEnabled)
    }

    try await action(block)

    try isScopeEnabled.forEach { scope, isEnabled in
      try engine.block.setScopeEnabled(block, key: scope, enabled: isEnabled)
    }
  }

  private func pointToCanvasUnit(_ point: CGFloat) throws -> Float {
    let sceneUnit = try engine.block.getEnum(getScene(), property: "scene/designUnit")
    var densityFactor: Float = 1
    if sceneUnit == "Millimeter" {
      densityFactor = try engine.block.getFloat(getScene(), property: "scene/dpi") / 25.4
    }
    if sceneUnit == "Inch" {
      densityFactor = try engine.block.getFloat(getScene(), property: "scene/dpi")
    }
    let zoomLevel = try engine.scene.getZoom()
    return Float(point) / (densityFactor * zoomLevel)
  }

  // All non-text blocks in this demo should be added with the same square size
  private func setSize(_ block: DesignBlockID) throws {
    try engine.block.setHeightMode(block, mode: .absolute)
    try engine.block.setHeight(block, value: 20)
    try engine.block.setWidthMode(block, mode: .absolute)
    try engine.block.setWidth(block, value: 20)
  }

  // Appends a block into the scene and positions it somewhat randomly.
  private func addBlockToPage(_ block: DesignBlockID) throws {
    try deselectAllBlocks()
    try engine.block.appendChild(to: getPage(), child: block)

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

  private func getPage() throws -> DesignBlockID {
    guard let page = try engine.block.find(byType: .page).first else {
      throw Error(errorDescription: "No page found.")
    }
    return page
  }

  private func getScene() throws -> DesignBlockID {
    guard let scene = try engine.block.find(byType: .scene).first else {
      throw Error(errorDescription: "No scene found.")
    }
    return scene
  }
}
