import IMGLYEditor
import IMGLYEngine

// MARK: - Default OnLoaded

extension PhotoEditorConfiguration {
  /// The default `onLoaded` handler.
  static var defaultOnLoadedHandler: OnLoaded.Handler {
    { context, existing in
      try await existing()
      for try await _ in context.engine.editor.onHistoryUpdated {
        let editMode = context.engine.editor.getEditMode()
        let isCrop = editMode == .crop
        try context.engine.editor.setSettingBool("page/allowResizeInteraction", value: isCrop)
      }
    }
  }
}
