import IMGLYEditor
import IMGLYEngine
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Default OnExport

extension ContentModerationEditorConfiguration {
  /// The default export handler.
  ///
  /// Gates the export on content moderation:
  /// 1. Never validated, or the design changed since the last validation →
  ///    show the validation alert instead of exporting.
  /// 2. Validated, but violations were found — or some blocks could not be checked
  ///    at all → open the results panel so the user can locate and resolve them.
  /// 3. Validated and clean → export as PDF and open the system share sheet.
  ///
  /// Remove the gate if your workflow moderates content at a different
  /// integration point (e.g. on upload or in a review queue).
  static func onExportHandler(_ moderation: ModerationStore) -> OnExport.Handler {
    { engine, eventHandler, existing in
      // highlight-starter-kit-on-export-validation
      // `refreshNeedsValidation` recomputes rather than reading the cached flag: a
      // missed history update may leave the icon stale, but it must never open this
      // gate on a design the store has not just compared.
      if moderation.refreshNeedsValidation(engine: engine) {
        let reason: ModerationExportAlert.Reason = moderation.hasValidated ? .contentChanged : .neverValidated
        eventHandler.send(.openSheet(style: .default(), content: {
          ModerationExportAlert(
            store: moderation,
            reason: reason,
            engine: engine,
            eventHandler: eventHandler,
            // `existing` is non-escaping, so the override path exports directly
            // instead of chaining. With no other export handler registered in
            // this kit the two are equivalent.
            onExportAnyway: {
              Task {
                do {
                  try await exportScene(engine: engine, eventHandler: eventHandler)
                } catch {
                  eventHandler.send(.showErrorAlert(error))
                }
              }
            },
          )
        }))
        return
      }

      if let outcome = moderation.outcome, !outcome.isCertifiablyClean {
        eventHandler.send(.openSheet(style: .default(), content: {
          ModerationResultsPanel(
            store: moderation,
            engine: engine,
            eventHandler: eventHandler,
            isExportBlocked: true,
          )
        }))
        return
      }
      // highlight-starter-kit-on-export-validation

      try await existing()
      try await exportScene(engine: engine, eventHandler: eventHandler)
    }
  }

  /// Exports the scene as PDF and opens the system share sheet.
  @MainActor
  private static func exportScene(engine: Engine, eventHandler: any EditorEventHandler) async throws {
    // highlight-starter-kit-on-export
    guard let scene = try engine.scene.get() else {
      throw EditorError("No scene was found.")
    }
    let data = try await engine.block.export(scene, mimeType: .pdf) { engine in
      try engine.scene.getPages().forEach {
        try engine.block.setScopeEnabled($0, key: "layer/visibility", enabled: true)
        try engine.block.setVisible($0, visible: true)
      }
    }
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("Export", conformingTo: .pdf)
    try data.write(to: url, options: [.atomic])
    eventHandler.send(.shareFile(url))
    // highlight-starter-kit-on-export
  }
}
