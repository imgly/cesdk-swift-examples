import ActivityView
import IMGLYEngine
import SwiftUI

@MainActor
final class Interactor: ObservableObject {
  // MARK: - Properties

  @ViewBuilder var canvas: some View {
    if let engine {
      IMGLYEngine.Canvas(engine: engine)
    } else {
      EmptyView()
    }
  }

  let assets = AssetLibrary()

  @Published private(set) var isLoading = true
  @Published private(set) var isEditing = true
  @Published private(set) var isExporting = false
  @Published private(set) var isAddingAsset = false

  @Published var export: ActivityItem?
  @Published var error = AlertState()
  @Published var sheet = SheetState() { didSet { sheetChanged(oldValue) } }
  @Published var text = TextState() { didSet { textChanged(oldValue) } }
  @Published var shape = ShapeState() { didSet { shapeChanged(oldValue) } }

  typealias Selection = IMGLYEngine.SelectionBox
  typealias EditMode = IMGLYEngine.EditMode
  @Published private(set) var selection: Selection? { didSet { selectionChanged(oldValue) } }
  @Published private(set) var editMode: EditMode = .transform { didSet { editModeChanged(oldValue) } }
  @Published private(set) var textCursorPosition: CGPoint?
  @Published private(set) var canUndo = false
  @Published private(set) var canRedo = false
  @Published private(set) var canBringForward = false
  @Published private(set) var canBringBackward = false

  var isCanvasActionEnabled: Bool { !sheet.isPresented && editMode == .transform }

  var sheetTypeForSelection: SheetType? { sheetType(for: selection) }

  var rotationForSelection: CGFloat? {
    guard let first = selection?.blocks.first,
          let rotation = try? engine?.block.getRotation(first) else {
      return nil
    }
    return CGFloat(rotation)
  }

  // MARK: - Utilities

  static func resignFirstResponder() {
    _ = UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }

  // MARK: - Life cycle

  init(sheet: SheetState? = nil) {
    if let sheet {
      _sheet = .init(initialValue: sheet)
    }
  }

  deinit {
    stateTask?.cancel()
    eventTask?.cancel()
    sceneTask?.cancel()
    selectionTask?.cancel()
    zoom.task?.cancel()
  }

  func onAppear() {
    updateState()
    stateTask = observeState()
    eventTask = observeEvent()
    selectionTask = observeSelection()
  }

  func onWillDisappear() {
    sheet.isPresented = false
  }

  func onDisappear() {
    stateTask?.cancel()
    eventTask?.cancel()
    sceneTask?.cancel()
    selectionTask?.cancel()
    zoom.task?.cancel()
    _engine = nil
  }

  // MARK: - Private properties

  // Currently, IMGLYEngine.Engine does not support multiple instances.
  // The optional _engine instance allows to control the deinitialization.
  private lazy var _engine: Engine? = Engine()

  private var stateTask: Task<Void, Never>?
  private var eventTask: Task<Void, Never>?
  private var sceneTask: Task<Void, Never>?
  private var selectionTask: Task<Void, Never>?
  private var zoom: (task: Task<Void, Never>?, toTextCursor: Bool) = (nil, false)
}

// MARK: - Constraints

extension Interactor {
  func isAllowed(_ mode: SheetMode) -> Bool {
    guard let engine else {
      return false
    }
    do {
      switch mode {
      case .add:
        return true
      case .replace, .edit:
        return try engine.isAllowedForSelectedElement("content/replace")
      case .style:
        return try engine.isAllowedForSelectedElement("design/style")
      case .arrange:
        let layer = isAllowed(.toTop)
        let duplicate = isAllowed(.duplicate)
        let delete = isAllowed(.delete)
        return layer || duplicate || delete
      }
    } catch {
      handleError(error)
    }
    return false
  }

  func isAllowed(_ action: Action) -> Bool {
    guard let engine else {
      return false
    }
    do {
      switch action {
      case .undo: return canUndo
      case .redo: return canRedo
      case .previewMode: return true
      case .editMode: return true
      case .export: return true
      case .toTop, .up, .down, .toBottom:
        return try engine.isAllowedForSelectedElement("editor/add")
      case .duplicate:
        return try engine.isAllowedForSelectedElement("lifecycle/duplicate")
      case .delete:
        return try engine.isAllowedForSelectedElement("lifecycle/destroy")
      }
    } catch {
      handleError(error)
    }
    return false
  }
}

// MARK: - Actions

extension Interactor {
  func assetTapped(_ asset: AssetLibrary.Image) {
    if sheet.mode == .replace {
      do {
        try engine?.changeImageFile(asset.url)
        if sheet.detent == .large {
          sheet.isPresented = false
        }
      } catch {
        handleErrorAndDismiss(error)
      }
    } else {
      isAddingAsset = true
      Task(priority: .userInitiated) {
        do {
          try await engine?.addImage(asset.url)
          sheet.isPresented = false
        } catch {
          handleErrorAndDismiss(error)
        }
        isAddingAsset = false
      }
    }
  }

  func assetTapped(_ asset: AssetLibrary.Shape) {
    do {
      try engine?.addShape(asset.shape)
      sheet.isPresented = false
    } catch {
      handleErrorAndDismiss(error)
    }
  }

  func assetTapped(_ asset: AssetLibrary.Sticker) {
    do {
      if sheet.mode == .replace {
        try engine?.changeStickerFile(asset.url)
        if sheet.detent == .large {
          sheet.isPresented = false
        }
      } else {
        try engine?.addSticker(asset.url)
        sheet.isPresented = false
      }
    } catch {
      handleErrorAndDismiss(error)
    }
  }

  func canvasMenuButtonTapped(for mode: SheetMode) {
    if let type = sheetTypeForSelection {
      sheet = .init(mode, type)
    }
  }

  func toolbarButtonTapped(for type: SheetType) {
    do {
      switch type {
      case .text:
        try engine?.addText()
        sheet = .init(.edit, .text)
      case .image, .shape, .sticker:
        try engine?.deselectAllBlocks()
        sheet = .init(.add, type)
      }
    } catch {
      handleError(error)
    }
  }

  // swiftlint:disable:next cyclomatic_complexity
  func actionButtonTapped(for action: Action) {
    do {
      switch action {
      case .undo: try engine?.editor.undo()
      case .redo: try engine?.editor.redo()
      case .previewMode: try enablePreviewMode()
      case .editMode: try enableEditMode()
      case .export: exportScene()
      case .toTop: try engine?.bringToFrontSelectedElement()
      case .up: try engine?.bringForwardSelectedElement()
      case .down: try engine?.sendBackwardSelectedElement()
      case .toBottom: try engine?.sendToBackSelectedElement()
      case .duplicate: try engine?.duplicateSelectedElement()
      case .delete: try engine?.deleteSelectedElement()
      }
    } catch {
      handleError(error)
    }
  }

  func loadScene(from url: URL, with insets: EdgeInsets?) {
    guard sceneTask == nil else {
      return
    }

    sceneTask = Task { [engine] in
      guard let engine else {
        return
      }
      async let loadFonts = loadFonts()
      async let loadScene: () = engine.loadScene(from: url, with: insets)
      do {
        let (fonts, _) = try await (loadFonts, loadScene)
        assets.fonts = fonts
        isLoading = false
      } catch {
        handleErrorAndDismiss(error)
      }
    }
  }

  func updateZoom(with insets: EdgeInsets?, canvasHeight: CGFloat) {
    let lastTask = zoom.task
    lastTask?.cancel()

    zoom.toTextCursor = false
    zoom.task = Task {
      _ = await sceneTask?.result
      _ = await lastTask?.result
      if Task.isCancelled {
        return
      }
      do {
        if isEditing {
          try await engine?.zoomToPage(insets)
          if editMode == .text {
            try engine?.zoomToSelectedText(insets, canvasHeight: canvasHeight)
          }
        } else {
          try await engine?.zoomToBackdrop(insets)
          try engine?.enablePreviewMode()
        }
      } catch {
        handleError(error)
      }
    }
  }

  func zoomToText(with insets: EdgeInsets?, canvasHeight: CGFloat, cursorPosition: CGPoint?) {
    guard editMode == .text, let cursorPosition, cursorPosition != .zero else {
      return
    }

    let lastTask = zoom.task
    if zoom.toTextCursor {
      lastTask?.cancel()
    }

    zoom.toTextCursor = true
    zoom.task = Task {
      _ = await sceneTask?.result
      _ = await lastTask?.result
      if Task.isCancelled {
        return
      }
      do {
        try engine?.zoomToSelectedText(insets, canvasHeight: canvasHeight)
      } catch {
        handleError(error)
      }
    }
  }
}

// MARK: - Private implementation

private extension Interactor {
  var engine: Engine? {
    guard let engine = _engine else {
      return nil
    }
    return engine
  }

  func handleError(_ error: Swift.Error) {
    self.error = .init(error, dismiss: false)
  }

  func handleErrorAndDismiss(_ error: Swift.Error) {
    self.error = .init(error, dismiss: true)
  }

  func enablePreviewMode() throws {
    // Call engine?.enablePreviewMode() in updateZoom to avoid page fill flickering.
    withAnimation(.default) {
      isEditing = false
    }
    sheet.isPresented = false
  }

  func enableEditMode() throws {
    try engine?.enableEditMode()
    withAnimation(.default) {
      isEditing = true
    }
  }

  func exportScene() {
    isExporting = true
    Task(priority: .background) {
      guard let engine else {
        return
      }
      do {
        let (data, contentType) = try await engine.exportScene()
        let name = String(describing: Action.export)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name, conformingTo: contentType)
        try data.write(to: url)
        export = ActivityItem(items: url)
        isExporting = false
      } catch {
        handleError(error)
      }
    }
  }

  func sheetType(for designBlockType: String) -> SheetType? {
    switch designBlockType {
    case DesignBlockType.text.rawValue: return .text
    case DesignBlockType.image.rawValue: return .image
    case let type where type.starts(with: DesignBlockType.shapes): return .shape
    case DesignBlockType.sticker.rawValue: return .sticker
    default: return nil
    }
  }

  func sheetType(for designBlockID: DesignBlockID) -> SheetType? {
    guard let engine, let type = try? engine.block.getType(designBlockID) else {
      return nil
    }
    return sheetType(for: type)
  }

  func sheetType(for selection: Selection?) -> SheetType? {
    if let selection, selection.blocks.count == 1,
       let block = selection.blocks.first,
       let type = sheetType(for: block) {
      return type
    }
    return nil
  }

  func placeholderType(for selection: Selection?) -> SheetType? {
    guard let engine,
          let selection, selection.blocks.count == 1,
          let block = selection.blocks.first,
          let type = sheetType(for: block) else {
      return nil
    }
    do {
      let showsPlaceholderContent = try engine.block.showsPlaceholderContent(block)
      let showsPlaceholderButton = try engine.block.getBool(block, property: "image/showsPlaceholderButton")
      let showsPlaceholderOverlay = try engine.block.getBool(block, property: "image/showsPlaceholderOverlay")

      if showsPlaceholderContent, showsPlaceholderButton || showsPlaceholderOverlay {
        return type
      } else {
        return nil
      }
    } catch {
      return nil
    }
  }

  func updateState() {
    guard let engine else {
      return
    }
    editMode = engine.editor.getEditMode()
    textCursorPosition = CGPoint(x: CGFloat(engine.editor.getTextCursorPositionInScreenSpaceX()),
                                 y: CGFloat(engine.editor.getTextCursorPositionInScreenSpaceY()))
    canUndo = (try? engine.editor.canUndo()) ?? false
    canRedo = (try? engine.editor.canRedo()) ?? false
    canBringForward = (try? engine.canBringForwardSelectedElement()) ?? false
    canBringBackward = (try? engine.canBringBackwardSelectedElement()) ?? false

    updateState(for: sheet)
  }

  func updateState(for sheet: SheetState) {
    guard let engine, sheet.isPresented else {
      return
    }

    switch (sheet.mode, sheet.type) {
    case (.style, .text):
      if let textProperties = try? engine.getSelectedTextProperties(),
         let color = try? textProperties.fillSolidColor.color() {
        let selected = assets.fontFor(url: textProperties.fontFileURL)

        text.commit { text in
          text.fontID = selected?.font.id
          text.fontFamilyID = selected?.family.id
          text.setFontProperties(selected?.family.fontProperties(for: selected?.font.id))
          text.color = color
          text.alignment = textProperties.horizontalAlignment?.textProperty
        }
      }
    case (.style, .shape):
      if let shapeProperties = try? engine.getSelectedShapeProperties(),
         let color = try? shapeProperties.fillSolidColor.color() {
        shape.commit { shape in
          shape.color = color
        }
      }
    default:
      break
    }
  }

  func observeState() -> Task<Void, Never> {
    Task {
      guard let engine else {
        return
      }
      for await _ in engine.editor.onStateChanged {
        updateState()
      }
    }
  }

  func observeEvent() -> Task<Void, Never> {
    Task {
      guard let engine else {
        return
      }
      for await _ in engine.event.subscribe(to: []) {
        updateState()
      }
    }
  }

  func observeSelection() -> Task<Void, Never> {
    Task {
      guard let engine else {
        return
      }
      for await box in engine.onSelectionBoxChanged {
        selection = box
      }
    }
  }

  func setEditMode(_ newValue: EditMode) {
    guard newValue != editMode else {
      return
    }
    engine?.editor.setEditMode(newValue)
  }

  // MARK: - State changes

  func selectionChanged(_ oldValue: Selection?) {
    guard oldValue != selection else {
      return
    }
    if sheet.isPresented {
      if sheet.mode != .add,
         sheet.type != sheetType(for: selection) {
        sheet.isPresented = false
      }
      if sheet.mode == .add, selection != nil {
        sheet.isPresented = false
      }
    } else if oldValue?.blocks != selection?.blocks,
              let type = placeholderType(for: selection) {
      sheet = .init(.replace, type)
    }
  }

  func sheetChanged(_ oldValue: SheetState) {
    guard oldValue != sheet else {
      return
    }
    if sheet.isPresented {
      if sheet.state != oldValue.state {
        // Sheet appeared or model changed.
        if sheet.mode == .edit, sheet.type == .text {
          if oldValue.isPresented {
            setEditMode(.text)
          } else {
            // Delay appearance to get the segment control right.
            Task {
              try await Task.sleep(nanoseconds: 100_000_000) // 100ms
              setEditMode(.text)
            }
          }
        } else {
          setEditMode(.transform)
        }
      }
    } else {
      if oldValue.isPresented {
        // Sheet disappeared
        setEditMode(.transform)
      }
    }
  }

  func editModeChanged(_ oldValue: EditMode) {
    guard oldValue != editMode else {
      return
    }
    if sheet.isPresented {
      if sheet.type == .text {
        if editMode == .text, sheet.mode != .edit {
          // Switch to text edit sheet
          sheet.mode = .edit
        }
        if editMode != .text, sheet.mode == .edit {
          // Dismiss text edit sheet
          sheet.isPresented = false
        }
      }
    }
  }

  func textChanged(_ oldValue: TextState) {
    guard oldValue != text else {
      return
    }
    do {
      if text.fontID == oldValue.fontID, // Change was triggered from UI and not from engine.
         text.fontFamilyID != oldValue.fontFamilyID ||
         text.bold != oldValue.bold ||
         text.italic != oldValue.italic {
        // Update font based on (family, bold, italic) tuple.
        if let fontFamilyID = text.fontFamilyID, let fontFamily = assets.fontFamilyFor(id: fontFamilyID),
           let font = fontFamily.font(for: .init(bold: text.isBold, italic: text.isItalic)) ?? fontFamily.someFont,
           let selected = assets.fontFor(id: font.id) {
          text.commit { text in
            text.fontID = selected.font.id
            text.fontFamilyID = selected.family.id
            text.setFontProperties(selected.family.fontProperties(for: selected.font.id))
          }
          try engine?.changeTextFont(selected.font.url)
        }
      }

      if text.alignment != oldValue.alignment {
        if let newValue = text.alignment {
          try engine?.changeTextAlignment(.init(newValue))
        }
      }

      if text.color != oldValue.color {
        try engine?.changeTextColor(text.color.rgba())
      }
    } catch {
      handleError(error)
    }
  }

  func shapeChanged(_ oldValue: ShapeState) {
    guard oldValue != shape else {
      return
    }
    do {
      if shape.color != oldValue.color {
        try engine?.changeShapeColor(shape.color.rgba())
      }
    } catch {
      handleError(error)
    }
  }
}
