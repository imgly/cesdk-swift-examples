import IMGLYEngine
import SwiftUI
import UniformTypeIdentifiers

@MainActor
public struct InteractorContext {
  public let engine: Engine
  public let interactor: Interactor

  init(_ engine: Engine, _ interactor: Interactor) {
    self.engine = engine
    self.interactor = interactor
  }
}

public enum RootBottomBarItem: IdentifiableByHash {
  case fab, selectionColors
  case font(_ id: DesignBlockID, fontFamilies: [String]? = nil)
  case fontSize(_ id: DesignBlockID)
  case color(_ id: DesignBlockID, colorPalette: [NamedColor]? = nil)

  var sheetMode: SheetMode {
    switch self {
    case .fab: return .add
    case .selectionColors: return .selectionColors
    case let .font(id, families): return .font(id, families)
    case let .fontSize(id): return .fontSize(id)
    case let .color(id, palette): return .color(id, palette)
    }
  }
}

@MainActor
public protocol InteractorBehavior: Sendable {
  func loadScene(_ context: InteractorContext, from url: URL, with insets: EdgeInsets?) async throws
  func exportScene(_ context: InteractorContext) async throws -> (Data, UTType)
  func enableEditMode(_ context: InteractorContext) throws
  func enablePreviewMode(_ context: InteractorContext, _ insets: EdgeInsets?) async throws
  func isGestureActive(_ context: InteractorContext, _ started: Bool) throws
  func rootBottomBarItems(_ context: InteractorContext) throws -> [RootBottomBarItem]
  func pageChanged(_ context: InteractorContext) throws
  func updateState(_ context: InteractorContext) throws
}

public extension InteractorBehavior {
  func loadScene(_ context: InteractorContext, from url: URL, with insets: EdgeInsets?) async throws {
    try context.engine.editor.setSettingString("license", value: Secrets.licenseKey)
    try context.engine.editor.setSettingBool("touch/singlePointPanning", value: true)
    try context.engine.editor.setSettingBool("touch/dragStartCanSelect", value: false)
    try context.engine.editor.setSettingEnum("touch/pinchAction", value: "Zoom")
    try context.engine.editor.setSettingEnum("touch/rotateAction", value: "None")
    try context.engine.editor.setSettingBool("doubleClickToCropEnabled", value: false)
    try context.engine.editor.setSettingString("basePath", value: Interactor.basePath.absoluteString)
    try context.engine.editor.setSettingEnum("role", value: "Adopter")
    try [ScopeKey]([
      .designStyle,
      .designArrange,
      .designArrangeMove,
      .designArrangeResize,
      .designArrangeRotate,
      .designArrangeFlip,
      .contentReplace,
      .lifecycleDestroy,
      .lifecycleDuplicate,
//      .editorAdd, // Cannot be restricted in web Dektop UI for now.
      .editorSelect
    ]).forEach { scope in
      try context.engine.editor.setGlobalScope(key: scope.rawValue, value: .defer)
    }
    let scene = try await context.engine.scene.load(fromURL: url)
    let page = try context.engine.getPage(context.interactor.page)
    _ = try context.engine.block.addOutline(Engine.outlineBlockName, for: page, to: scene)
    try context.engine.showOutline(false)
    try context.engine.showPage(context.interactor.page)
    try enableEditMode(context)
    try await context.engine.zoomToPage(context.interactor.page, insets)
    try context.engine.editor.addUndoStep()
  }

  private func showAllPages(_ context: InteractorContext) throws {
    try context.engine.showAllPages(layout: context.interactor.verticalSizeClass == .compact ? .horizontal : .vertical)
  }

  func exportScene(_ context: InteractorContext) async throws -> (Data, UTType) {
    try context.engine.showAllPages(layout: .vertical)
    let data = try await context.engine.block.export(context.engine.getScene(), mimeType: .pdf)
    if context.interactor.isEditing {
      try context.engine.showPage(context.interactor.page)
    } else {
      try showAllPages(context)
    }
    return (data, UTType.pdf)
  }

  func enableEditMode(_ context: InteractorContext) throws {
    try context.engine.showPage(context.interactor.page)
  }

  func enablePreviewMode(_ context: InteractorContext, _ insets: EdgeInsets?) async throws {
    try showAllPages(context)
    try await context.engine.zoomToScene(insets)
    try context.engine.block.deselectAll()
  }

  func isGestureActive(_: InteractorContext, _: Bool) throws {}

  func rootBottomBarItems(_: InteractorContext) throws -> [RootBottomBarItem] {
    [.fab]
  }

  func pageChanged(_: InteractorContext) throws {}

  func updateState(_ context: InteractorContext) throws {
    guard !context.interactor.isLoading else {
      return
    }
    context.interactor.selectionColors = try context.engine.selectionColors(forPage: context.interactor.page)
  }
}

public final class DefaultInteractorBehavior: InteractorBehavior {}

public extension InteractorBehavior where Self == DefaultInteractorBehavior {
  static var `default`: Self { Self() }
}

public extension Interactor {
  static var `default`: Interactor { Interactor(behavior: .default) }
}
