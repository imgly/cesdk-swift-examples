import ActivityView
import IMGLYCore
import IMGLYCoreUI
import IMGLYEngine
import SwiftUI

@MainActor
public final class Interactor: ObservableObject, KeyboardObserver {
  // MARK: - Properties

  static let basePath = URL(string: "https://cdn.img.ly/packages/imgly/cesdk-js/latest/assets")!

  @ViewBuilder var canvas: some View {
    if let engine {
      IMGLYEngine.Canvas(engine: engine)
    }
  }

  let assets = AssetLibrary()

  @Published public private(set) var isLoading = true
  @Published public private(set) var isEditing = true
  @Published private(set) var isExporting = false
  @Published public private(set) var isAddingAsset = false

  @Published var export: ActivityItem?
  @Published var error = AlertState()
  @Published var sheet = SheetState() { didSet { sheetChanged(oldValue) } }

  typealias BlockID = IMGLYEngine.DesignBlockID
  typealias BlockType = IMGLYEngine.DesignBlockType
  typealias EditMode = IMGLYEngine.EditMode
  typealias RGBA = IMGLYEngine.RGBA

  struct Selection: Equatable {
    let blocks: [BlockID]
    let boundingBox: CGRect
  }

  @Published public internal(set) var verticalSizeClass: UserInterfaceSizeClass?
  @Published public private(set) var page = 0 { didSet { pageChanged(oldValue) } }
  @Published public var selectionColors = SelectionColors()
  @Published private(set) var selection: Selection? { didSet { selectionChanged(oldValue) } }
  @Published private(set) var editMode: EditMode = .transform { didSet { editModeChanged(oldValue) } }
  @Published private(set) var textCursorPosition: CGPoint?
  @Published private(set) var canUndo = false
  @Published private(set) var canRedo = false
  @Published private var isKeyboardPresented: Bool = false

  var isCanvasActionEnabled: Bool {
    !sheet.isPresented && editMode == .transform && !isGrouped(selection?.blocks.first)
  }

  var sheetTypeForSelection: SheetType? { sheetType(for: selection) }

  func sheetType(_ id: BlockID?) -> SheetType? {
    guard let id, let engine, let type = try? engine.block.getType(id) else {
      return nil
    }
    return sheetType(for: type)
  }

  func blockType(_ id: BlockID?) -> DesignBlockType? {
    guard let id, let engine, let type = try? engine.block.getType(id) else {
      return nil
    }
    return DesignBlockType(rawValue: type)
  }

  var rotationForSelection: CGFloat? {
    guard let first = selection?.blocks.first,
          let rotation = try? engine?.block.getRotation(first) else {
      return nil
    }
    return CGFloat(rotation)
  }

  func isGestureActive(_ started: Bool) {
    guard let engine else {
      return
    }
    do {
      try behavior.isGestureActive(.init(engine, self), started)
    } catch {
      handleError(error)
    }
  }

  var rootBottomBarItems: [RootBottomBarItem] {
    guard let engine else {
      return []
    }
    do {
      return try behavior.rootBottomBarItems(.init(engine, self))
    } catch {
      handleError(error)
      return []
    }
  }

  // MARK: - Life cycle

  public init(behavior: InteractorBehavior) {
    self.behavior = behavior
  }

  init(behavior: InteractorBehavior, sheet: SheetState?) {
    self.behavior = behavior
    if let sheet {
      _sheet = .init(initialValue: sheet)
    }
  }

  deinit {
    stateTask?.cancel()
    eventTask?.cancel()
    sceneTask?.cancel()
    zoom.task?.cancel()
  }

  func onAppear() {
    updateState()
    stateTask = observeState()
    eventTask = observeEvent()
    keyboardPublisher.assign(to: &$isKeyboardPresented)
  }

  func onWillDisappear() {
    sheet.isPresented = false
  }

  func onDisappear() {
    stateTask?.cancel()
    eventTask?.cancel()
    sceneTask?.cancel()
    zoom.task?.cancel()
    _engine = nil
  }

  // MARK: - Private properties

  private let behavior: InteractorBehavior

  // Currently, IMGLYEngine.Engine does not support multiple instances.
  // The optional _engine instance allows to control the deinitialization.
  private lazy var _engine: Engine? = Engine()

  private var stateTask: Task<Void, Never>?
  private var eventTask: Task<Void, Never>?
  private var sceneTask: Task<Void, Never>?
  private var zoom: (task: Task<Void, Never>?, toTextCursor: Bool) = (nil, false)
}

// MARK: - Block queries

extension Interactor {
  private func block<T>(_ id: BlockID?, _ query: (@MainActor (BlockID) throws -> T)?) -> T? {
    guard let engine, let id, engine.block.isValid(id) else {
      return nil
    }
    do {
      return try query?(id)
    } catch {
      handleErrorWithTask(error)
      return nil
    }
  }

  func canBringForward(_ id: BlockID?) -> Bool { block(id, engine?.block.canBringForward) ?? false }
  func canBringBackward(_ id: BlockID?) -> Bool { block(id, engine?.block.canBringBackward) ?? false }
  func hasFill(_ id: BlockID?) -> Bool { block(id, engine?.block.hasFill) ?? false }
  func hasStroke(_ id: BlockID?) -> Bool { block(id, engine?.block.hasStroke) ?? false }
  func hasOpacity(_ id: BlockID?) -> Bool { block(id, engine?.block.hasOpacity) ?? false }
  func hasBlendMode(_ id: BlockID?) -> Bool { block(id, engine?.block.hasBlendMode) ?? false }
  func hasBlur(_ id: BlockID?) -> Bool { block(id, engine?.block.hasBlur) ?? false }
  func hasCrop(_ id: BlockID?) -> Bool { block(id, engine?.block.hasCrop) ?? false }
  func canResetCrop(_ id: BlockID?) -> Bool { block(id, engine?.block.canResetCrop) ?? false }
  func isGrouped(_ id: BlockID?) -> Bool { block(id, engine?.block.isGrouped) ?? false }
}

// MARK: - Property bindings

extension Interactor {
  /// Create a `TextState` binding for a block `id`.
  /// If `resetFontProperties` is enabled bold and italic states would not be preserved on set.
  func bindTextState(_ id: BlockID?, resetFontProperties: Bool) -> Binding<TextState> {
    let fontURL: Binding<URL?> = bind(id, property: .key(.textFontFileURI))
    return .init {
      if let fontURL = fontURL.wrappedValue {
        let selected = self.assets.fontFor(url: fontURL)
        var text = TextState()
        text.fontID = selected?.font.id
        text.fontFamilyID = selected?.family.id
        text.setFontProperties(selected?.family.fontProperties(for: selected?.font.id))
        return text
      } else {
        return TextState()
      }
    } set: { text in
      func font(fontFamily: FontFamily) -> Font? {
        if resetFontProperties {
          return fontFamily.someFont
        } else {
          return fontFamily.font(for: .init(bold: text.isBold, italic: text.isItalic)) ?? fontFamily.someFont
        }
      }

      if let fontFamilyID = text.fontFamilyID, let fontFamily = self.assets.fontFamilyFor(id: fontFamilyID),
         let font = font(fontFamily: fontFamily),
         let selected = self.assets.fontFor(id: font.id) {
        fontURL.wrappedValue = selected.font.url
      }
    }
  }

  /// Create `SelectionColor` bindings categorized by block names for a given set of `selectionColors`.
  func bind(_ selectionColors: SelectionColors,
            completion: PropertyCompletion? = Completion.addUndoStep) -> [(name: String, colors: [SelectionColor])] {
    selectionColors.sorted.map { name, colors in
      let colors = colors.map { color in
        SelectionColor(color: color, binding: .init {
          // Assume all properties and valid blocks assigned to the selection color still share the same color.
          // Otherwise the first found visible color is returned.
          guard let engine = self.engine, let properties = selectionColors[name, color] else {
            return color
          }

          for (property, blocks) in properties {
            let validBlock = blocks.first { id in
              let isEnabled: Bool = {
                guard let enabledProperty = property.enabled else {
                  return false
                }
                do {
                  return try engine.block.get(id, property: enabledProperty)
                } catch {
                  self.handleErrorWithTask(error)
                  return false
                }
              }()
              return engine.block.isValid(id) && isEnabled
            }
            if let validBlock, let value: CGColor = self.get(validBlock, property: property) {
              return value
            }
          }

          // No valid block found.
          return color
        } set: { value, _ in
          guard let properties = selectionColors[name, color] else {
            return
          }
          properties.forEach { property, ids in
            _ = self.set(ids, property: property, value: value,
                         setter: Setter.set(overrideScope: .key(.designStyle)),
                         completion: completion)
          }
        })
      }

      return (name: name, colors: colors)
    }
  }

  /// Create a `property` `Binding` for a block `id`. The`defaultValue` will be used as fallback if the property
  /// cannot be resolved.
  func bind<T: MappedType>(_ id: BlockID?, _ propertyBlock: PropertyBlock? = nil,
                           property: Property, default defaultValue: T,
                           setter: @escaping PropertySetter<T> = Setter.set(),
                           completion: PropertyCompletion? = Completion.addUndoStep) -> Binding<T> {
    .init {
      guard let id, let value: T = self.get(id, propertyBlock, property: property) else {
        return defaultValue
      }
      return value
    } set: { value, _ in
      guard let id else {
        return
      }
      _ = self.set([id], propertyBlock, property: property, value: value, setter: setter, completion: completion)
    }
  }

  /// Create a `property` `Binding` for a block `id`. The value `nil` will be used as fallback if the property
  /// cannot be resolved.
  func bind<T: MappedType>(_ id: BlockID?, _ propertyBlock: PropertyBlock? = nil,
                           property: Property,
                           setter: @escaping PropertySetter<T> = Setter.set(),
                           completion: PropertyCompletion? = Completion.addUndoStep) -> Binding<T?> {
    .init {
      guard let id else {
        return nil
      }
      return self.get(id, propertyBlock, property: property)
    } set: { value, _ in
      guard let value, let id else {
        return
      }
      _ = self.set([id], propertyBlock, property: property, value: value, setter: setter, completion: completion)
    }
  }

  func addUndoStep() {
    do {
      try engine?.editor.addUndoStep()
    } catch {
      handleError(error)
    }
  }

  typealias PropertySetter<T: MappedType> = @MainActor (
    _ engine: Engine,
    _ blocks: [DesignBlockID],
    _ propertyBlock: PropertyBlock?,
    _ property: Property,
    _ value: T,
    _ completion: PropertyCompletion?
  ) throws -> Bool

  enum Setter {
    static func set<T: MappedType>() -> Interactor.PropertySetter<T> {
      { engine, blocks, propertyBlock, property, value, completion in
        let didChange = try engine.block.set(blocks, propertyBlock, property: property, value: value)
        return try (completion?(engine, blocks, didChange) ?? false) || didChange
      }
    }

    static func set<T: MappedType>(overrideScope: Scope) -> Interactor.PropertySetter<T> {
      { engine, blocks, propertyBlock, property, value, completion in
        let didChange = try engine.block.overrideAndRestore(blocks, scope: overrideScope) {
          try engine.block.set($0, propertyBlock, property: property, value: value)
        }
        return try (completion?(engine, blocks, didChange) ?? false) || didChange
      }
    }
  }

  typealias PropertyCompletion = @MainActor (
    _ engine: Engine,
    _ blocks: [DesignBlockID],
    _ didChange: Bool
  ) throws -> Bool

  enum Completion {
    static let addUndoStep: PropertyCompletion = addUndoStep()

    static func addUndoStep(completion: Interactor.PropertyCompletion? = nil) -> Interactor.PropertyCompletion {
      { engine, blocks, didChange in
        if didChange {
          try engine.editor.addUndoStep()
        }
        return try (completion?(engine, blocks, didChange) ?? false) || didChange
      }
    }

    static func set(_ propertyBlock: PropertyBlock? = nil,
                    property: Property, value: some MappedType,
                    completion: Interactor.PropertyCompletion? = nil) -> Interactor.PropertyCompletion {
      { engine, blocks, didChange in
        let didSet = try engine.block.set(blocks, propertyBlock, property: property, value: value)
        let didChange = didChange || didSet
        return try (completion?(engine, blocks, didChange) ?? false || didChange)
      }
    }
  }

  func enumValues<T>(property: Property) -> [T]
    where T: CaseIterable & RawRepresentable, T.RawValue == String {
    guard let engine else {
      return []
    }
    do {
      return try engine.block.enumValues(property: property)
    } catch {
      handleErrorWithTask(error)
      return []
    }
  }
}

// MARK: - Constraints

extension Interactor {
  func isAllowed(_ id: BlockID?, scope: Scope) -> Bool {
    guard let engine, let id, engine.block.isValid(id) else {
      return false
    }
    do {
      return try engine.block.isAllowedByScope(id, key: scope.rawValue)
    } catch {
      handleErrorWithTask(error)
      return false
    }
  }

  func isAllowed(_ id: BlockID?, _ mode: SheetMode) -> Bool {
    switch mode {
    case .add:
      return true
    case .replace, .edit:
      return isAllowed(id, scope: .key(.contentReplace))
    case .crop:
      return isAllowed(id, scope: .key(.contentReplace)) || isAllowed(id, scope: .key(.designStyle))
    case .format, .options, .fillAndStroke:
      return isAllowed(id, scope: .key(.designStyle))
    case .layer:
      let style = isAllowed(id, .fillAndStroke)
      let layer = isAllowed(id, .toTop)
      let duplicate = isAllowed(id, .duplicate)
      let delete = isAllowed(id, .delete)
      return style || layer || duplicate || delete
    case .enterGroup:
      return true
    case .selectGroup:
      return isGrouped(id)
    case .selectionColors, .font, .fontSize, .color:
      return true
    }
  }

  func isAllowed(_ id: BlockID?, _ action: Action) -> Bool {
    switch action {
    case .undo: return canUndo
    case .redo: return canRedo
    case .previewMode: return true
    case .editMode: return true
    case .export: return true
    case .toTop, .up, .down, .toBottom:
      return isAllowed(id, scope: .key(.editorAdd)) && !isGrouped(id)
    case .duplicate:
      return isAllowed(id, scope: .key(.lifecycleDuplicate)) && !isGrouped(id)
    case .delete:
      return isAllowed(id, scope: .key(.lifecycleDestroy)) && !isGrouped(id)
    case .previousPage, .nextPage, .page: return true
    case .resetCrop, .flipCrop:
      return isAllowed(id, .crop) && !isGrouped(id)
    }
  }
}

// MARK: - Actions

extension Interactor: AssetLibraryInteractor {
  public func findAssets(sourceID: String, query: AssetQueryData) async throws -> AssetQueryResult {
    guard let engine else {
      throw Error(errorDescription: "Engine unavailable.")
    }
    return try await engine.asset.findAssets(sourceID: sourceID, query: query)
  }

  public func assetTapped(sourceID: String, asset: AssetResult) {
    guard let engine else {
      return
    }
    isAddingAsset = true
    Task(priority: .userInitiated) {
      do {
        if sheet.mode == .replace, let id = selection?.blocks.first {
          switch sheet.type {
          case .sticker:
            guard let url = asset.url else {
              return
            }
            _ = try engine.set([id], property: .key(.stickerImageFileURI), value: url)
          default:
            try await engine.asset.applyToBlock(sourceID: sourceID, assetResult: asset, block: id)
          }
          if try engine.editor.getSettingEnum("role") == "Adopter" {
            try engine.block.setPlaceholderEnabled(id, enabled: false)
          }
          try engine.editor.addUndoStep()
          if sheet.detent == .large || isKeyboardPresented {
            sheet.isPresented = false
          }
        } else {
          if let id = try await engine.asset.apply(sourceID: sourceID, assetResult: asset) {
            try engine.block.appendChild(to: engine.getPage(page), child: id)
            if ProcessInfo.isUITesting {
              try engine.block.setPositionX(id, value: 15)
              try engine.block.setPositionY(id, value: 5)
            }
          }
          sheet.isPresented = false
        }
      } catch {
        handleErrorAndDismiss(error)
      }
      isAddingAsset = false
    }
  }

  public func uploadAsset(sourceID: String, url: URL, thumb: URL, type: DesignBlockType) {
    guard let engine else {
      return
    }

    Task {
      do {
        let (data, _) = try await URLSession.get(url)
        guard let size = UIImage(data: data)?.size else {
          return
        }

        let assetID = url.absoluteString
        try engine.asset.addAsset(to: sourceID, asset:
          .init(id: assetID,
                meta: [
                  "uri": url.absoluteString,
                  "thumbUri": thumb.absoluteString,
                  "blockType": type.rawValue,
                  "width": String(Int(size.width)),
                  "height": String(Int(size.height))
                ]))

        let result = try await engine.asset.findAssets(
          sourceID: sourceID,
          query: .init(query: assetID, page: 0, perPage: 10)
        )
        NotificationCenter.default.post(name: .AssetSourceDidChange, object: nil, userInfo: ["sourceID": sourceID])

        if result.assets.count == 1, let asset = result.assets.first {
          assetTapped(sourceID: sourceID, asset: asset)
        }
      } catch {
        handleErrorAndDismiss(error)
      }
    }
  }
}

extension Interactor {
  func assetTapped(_ asset: AssetLibrary.Text) {
    do {
      try engine?.addText(asset.url, fontSize: asset.size, toPage: page)
      sheet.isPresented = false
    } catch {
      handleErrorAndDismiss(error)
    }
  }

  func sheetDismissButtonTapped() {
    sheet.isPresented = false
  }

  func bottomBarCloseButtonTapped() {
    do {
      try engine?.block.deselectAll()
    } catch {
      handleError(error)
    }
  }

  func keyboardBarDismissButtonTapped() {
    setEditMode(.transform)
  }

  // swiftlint:disable:next cyclomatic_complexity
  func bottomBarButtonTapped(for mode: SheetMode) {
    do {
      switch mode {
      case .add:
        try engine?.block.deselectAll()
        sheet.commit { model in
          model = .init(mode, .image)
          model.detent = .large
        }
      case .edit:
        setEditMode(.text)
      case .crop:
        setEditMode(.crop)
      case .enterGroup:
        if let group = selection?.blocks.first {
          try engine?.block.enterGroup(group)
        }
      case .selectGroup:
        if let child = selection?.blocks.first {
          try engine?.block.exitGroup(child)
        }
      case .selectionColors:
        sheet.commit { model in
          model = .init(mode, .selectionColors)
        }
      case .font:
        sheet.commit { model in
          model = .init(mode, .font)
        }
      case .fontSize:
        sheet.commit { model in
          model = .init(mode, .fontSize)
          model.detent = .tiny
          model.detents = [.tiny]
        }
      case .color:
        sheet.commit { model in
          model = .init(mode, .color)
          model.detent = .tiny
          model.detents = [.tiny]
        }
      default:
        guard let type = sheetTypeForSelection else {
          return
        }
        sheet.commit { model in
          model = .init(mode, type)
        }
      }
    } catch {
      handleError(error)
    }
  }

  // swiftlint:disable:next cyclomatic_complexity
  public func actionButtonTapped(for action: Action) {
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
      case .delete: try engine?.deleteSelectedElement(delay: NSEC_PER_MSEC * 200)
      case .previousPage: try setPage(page - 1)
      case .nextPage: try setPage(page + 1)
      case let .page(index): try setPage(index)
      case .resetCrop: try engine?.resetCropSelectedElement()
      case .flipCrop: try engine?.flipCropSelectedElement()
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
      async let loadScene: () = behavior.loadScene(.init(engine, self), from: url, with: insets)
      async let loadDefaultAssets: () = engine.addDefaultAssetSources()
      async let loadDemoAssetSources: () = engine.addDemoAssetSources(withUploadAssetSources: true)

      let baseURL = URL(string: "https://cdn.img.ly/assets/showcases/v1")!
      async let loadImages: () = engine.populateAssetSource(id: ImageSource.images.sourceID, baseURL: baseURL)
      async let loadShapes: () = engine.populateAssetSource(id: AssetLibrary.shapeSourceID, baseURL: baseURL)
      async let loadStickers: () = engine.populateAssetSource(id: AssetLibrary.stickerSourceID, baseURL: baseURL)

      do {
        let (fonts, _, _, _, _, _, _) = try await (loadFonts, loadScene, loadDefaultAssets, loadDemoAssetSources,
                                                   loadImages, loadShapes, loadStickers)
        assets.fonts = fonts
        try engine.asset.addSource(UnsplashAssetSource())
        isLoading = false
      } catch {
        handleErrorAndDismiss(error)
      }
    }
  }

  private func getContext(_ action: (@MainActor (_ context: InteractorContext) throws -> Void)?) rethrows {
    guard let engine else {
      return
    }
    try action?(.init(engine, self))
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
          try await engine?.zoomToPage(page, insets)
          if editMode == .text {
            try engine?.zoomToSelectedText(insets, canvasHeight: canvasHeight)
          }
        } else {
          if let engine {
            try await behavior.enablePreviewMode(.init(engine, self), insets)
          }
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

  func handleErrorWithTask(_ error: Swift.Error) {
    // Only show most recent error once.
    if error.localizedDescription != self.error.details?.message {
      Task {
        handleError(error)
      }
    }
  }

  func handleErrorAndDismiss(_ error: Swift.Error) {
    self.error = .init(error, dismiss: true)
  }

  func get<T: MappedType>(_ id: DesignBlockID, _ propertyBlock: PropertyBlock? = nil,
                          property: Property) -> T? {
    guard let engine, engine.block.isValid(id) else {
      return nil
    }
    do {
      return try engine.block.get(id, propertyBlock, property: property)
    } catch {
      handleErrorWithTask(error)
      return nil
    }
  }

  func set<T: MappedType>(_ ids: [DesignBlockID], _ propertyBlock: PropertyBlock? = nil,
                          property: Property, value: T,
                          setter: PropertySetter<T> = Setter.set(),
                          completion: PropertyCompletion?) -> Bool {
    guard let engine else {
      return false
    }
    do {
      let valid = ids.filter {
        engine.block.isValid($0)
      }
      return try setter(engine, valid, propertyBlock, property, value, completion)
    } catch {
      handleErrorWithTask(error)
      return false
    }
  }

  func enablePreviewMode() throws {
    // Call engine?.enablePreviewMode() in updateZoom to avoid page fill flickering.
    withAnimation(.default) {
      isEditing = false
    }
    sheet.isPresented = false
    setEditMode(.transform)
  }

  func enableEditMode() throws {
    try getContext(behavior.enableEditMode)
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
        let (data, contentType) = try await behavior.exportScene(.init(engine, self))
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
    case _ where designBlockType.hasPrefix(DesignBlockType.shapes): return .shape
    case DesignBlockType.vectorPath.rawValue: return .shape
    case DesignBlockType.sticker.rawValue: return .sticker
    case DesignBlockType.group.rawValue: return .group
    default: return nil
    }
  }

  func sheetType(for selection: Selection?) -> SheetType? {
    if let selection, selection.blocks.count == 1,
       let block = selection.blocks.first,
       let type = sheetType(block) {
      return type
    }
    return nil
  }

  func placeholderType(for selection: Selection?) -> SheetType? {
    guard let engine,
          let selection, selection.blocks.count == 1,
          let block = selection.blocks.first,
          let type = sheetType(block) else {
      return nil
    }
    do {
      guard try engine.editor.getSettingEnum("role") == "Adopter",
            try engine.block.hasPlaceholderControls(block) else {
        return nil
      }
      let isPlaceholder = try engine.block.isPlaceholderEnabled(block)
      let showsPlaceholderButton = try engine.block.isPlaceholderControlsButtonEnabled(block)
      let showsPlaceholderOverlay = try engine.block.isPlaceholderControlsOverlayEnabled(block)

      if isPlaceholder, showsPlaceholderButton || showsPlaceholderOverlay {
        return type
      } else {
        return nil
      }
    } catch {
      handleError(error)
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

    let selected = engine.block.findAllSelected()
    selection = {
      if selected.isEmpty {
        return nil
      } else {
        let box = try? engine.block.getScreenSpaceBoundingBox(containing: selected)
        return .init(blocks: selected, boundingBox: box ?? .zero)
      }
    }()

    do {
      try behavior.updateState(.init(engine, self))
    } catch {
      handleErrorWithTask(error)
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

  func setEditMode(_ newValue: EditMode) {
    guard newValue != editMode else {
      return
    }
    engine?.editor.setEditMode(newValue)
  }

  func setPage(_ newValue: Int) throws {
    guard newValue != page, let engine else {
      return
    }
    let pages = try engine.getSortedPages()
    if (0 ..< pages.endIndex).contains(newValue) {
      page = newValue
    }
  }

  // MARK: - State changes

  func pageChanged(_ oldValue: Int) {
    guard let engine, oldValue != page else {
      return
    }
    do {
      try engine.showPage(page)
      try engine.editor.resetHistory()
      try behavior.pageChanged(.init(engine, self))
      sheet.isPresented = false
    } catch {
      handleError(error)
    }
  }

  func sheetChanged(_ oldValue: SheetState) {
    guard oldValue != sheet else {
      return
    }
    if !sheet.isPresented, oldValue.state == .init(.crop, .image) {
      setEditMode(.transform)
    }
  }

  func selectionChanged(_ oldValue: Selection?) {
    guard oldValue != selection else {
      return
    }
    let wasPresented = sheet.isPresented

    if sheet.isPresented {
      if sheet.mode != .add,
         oldValue?.blocks != selection?.blocks {
        sheet.isPresented = false
      }
      if sheet.mode == .add, selection != nil {
        sheet.isPresented = false
      }
    }
    if oldValue?.blocks != selection?.blocks,
       let type = placeholderType(for: selection) {
      func showReplaceSheet() {
        sheet = .init(.replace, type)
      }

      if wasPresented, sheet.mode != .replace, sheet.type != type {
        if sheet.isPresented {
          sheet.isPresented = false
        }
        Task {
          try? await Task.sleep(nanoseconds: NSEC_PER_MSEC * 200)
          showReplaceSheet()
        }
      } else {
        showReplaceSheet()
      }
    }
  }

  func editModeChanged(_ oldValue: EditMode) {
    guard oldValue != editMode else {
      return
    }
    if sheet.isPresented {
      if editMode == .text || oldValue == .crop {
        sheet.isPresented = false
      }
    }
    if editMode == .crop, sheet.state != .init(.crop, .image) {
      func showCropSheet() {
        sheet.commit { model in
          model = .init(.crop, .image)
          model.detent = .small
          model.detents = [.small, .large]
        }
      }

      if sheet.isPresented {
        sheet.isPresented = false
        Task {
          try? await Task.sleep(nanoseconds: NSEC_PER_MSEC * 200)
          showCropSheet()
        }
      } else {
        showCropSheet()
      }
    }
  }
}
