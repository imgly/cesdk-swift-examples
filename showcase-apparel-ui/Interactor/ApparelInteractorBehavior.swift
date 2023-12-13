import IMGLYEditorUI
import IMGLYEngine
import SwiftUI
import UniformTypeIdentifiers

final class ApparelInteractorBehavior: InteractorBehavior {
  func exportScene(_ context: InteractorContext) async throws -> (Data, UTType) {
    var data = Data()
    try await context.engine.block.overrideAndRestore(context.engine.getPage(0), scope: .key(.fillChange)) {
      let prevPageFill: Bool = try context.engine.block.get(context.engine.getPage(0), property: .key(.fillEnabled))
      try context.engine.block.set($0, property: .key(.fillEnabled), value: true)
      // We always want a background color when exporting
      data = try await context.engine.block.export(context.engine.getPage(0), mimeType: .pdf)
      try context.engine.block.set($0, property: .key(.fillEnabled), value: prevPageFill)
    }
    return (data, UTType.pdf)
  }

  private func pageSetup(_ context: InteractorContext) throws {
    try context.engine.block.overrideAndRestore(
      context.engine.getPage(0),
      scopes: [.key(.fillChange), .key(.layerClipping)]
    ) {
      try context.engine.editor.setSettingBool("page/dimOutOfPageAreas", value: false)
      try context.engine.block.setClipped($0, clipped: true)
      try context.engine.block.set($0, property: .key(.fillEnabled), value: false)
      try context.engine.showOutline(false)
    }
  }

  func enableEditMode(_ context: InteractorContext) throws {
    try pageSetup(context)
  }

  func enablePreviewMode(_ context: InteractorContext, _ insets: EdgeInsets?) async throws {
    try await context.engine.zoomToBackdrop(insets)
    try context.engine.block.deselectAll()
    try pageSetup(context)
  }

  func isGestureActive(_ context: InteractorContext, _ started: Bool) throws {
    try context.engine.showOutline(started)
  }
}

extension InteractorBehavior where Self == ApparelInteractorBehavior {
  static var apparelUI: Self { Self() }
}

extension Interactor {
  static var apparelUI: Interactor { Interactor(behavior: .apparelUI) }
}
