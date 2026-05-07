import IMGLYEditor
import IMGLYEngine

// MARK: - Default OnChanged

extension PhotoEditorConfiguration {
  /// The default `onChanged` handler.
  static var defaultOnChangedHandler: OnChanged.Handler {
    { update, context, _ in
      switch update {
      case let .editMode(oldValue, newValue):
        guard oldValue != newValue else { return }

        let isCrop = newValue == .crop
        if let selection = context.engine.block.findAllSelected().first,
           let type = try? context.engine.block.getType(selection), type == DesignBlockType.page.rawValue {
          context.eventHandler.send(.setExtraCanvasInsets(isCrop ? 24 : 0))
        }
        try context.engine.editor.setSettingBool("page/allowResizeInteraction", value: isCrop)
      default:
        try OnChanged.default(update, context)
      }
    }
  }
}
