import IMGLYEditor
import IMGLYEngine

// MARK: - Default OnChanged

extension ApparelEditorConfiguration {
  /// The default `onChanged` handler.
  static var defaultOnChangedHandler: OnChanged.Handler {
    { update, context, _ in
      switch update {
      case let .gestureActive(_, newValue):
        try Self.showOutline(newValue, engine: context.engine)

      case let .page(_, newValue):
        // Deselect all blocks.
        try context.engine.block.findAllSelected().forEach {
          try context.engine.block.setSelected($0, selected: false)
        }

        // Reset history.
        let oldHistory = context.engine.editor.getActiveHistory()
        let newHistory = context.engine.editor.createHistory()
        context.engine.editor.setActiveHistory(newHistory)
        context.engine.editor.destroyHistory(oldHistory)
        try context.engine.editor.addUndoStep()

        if let stack = try? context.engine.block.find(byType: .stack).first {
          try context.engine.block.setEnum(stack, property: "stack/axis", value: "Depth")
        }

        let pages = try context.engine.scene.getPages()
        for (i, block) in pages.enumerated() {
          let isVisibilityEnabled = try context.engine.block.isScopeEnabled(block, key: "layer/visibility")
          try context.engine.block.setScopeEnabled(block, key: "layer/visibility", enabled: true)
          try context.engine.block.setVisible(block, visible: i == newValue)
          try context.engine.block.setScopeEnabled(block, key: "layer/visibility", enabled: isVisibilityEnabled)
        }

      case let .viewMode(_, state):
        if state.editorViewMode == .edit {
          try Self.setupPage(context)
        } else if state.editorViewMode == .preview {
          guard let scene = try context.engine.block.find(byType: .scene).first
          else { throw EditorError("No scene found.") }

          Task {
            // Disable camera clamping.
            if try context.engine.scene.unstable_isCameraZoomClampingEnabled(scene) {
              try context.engine.scene.unstable_disableCameraZoomClamping()
            }
            if try context.engine.scene.unstable_isCameraPositionClampingEnabled(scene) {
              try context.engine.scene.unstable_disableCameraPositionClamping()
            }

            // Zoom to the backdrop image.
            try await context.engine.scene.zoom(
              to: Self.getBackdropImage(engine: context.engine),
              paddingLeft: Float(state.insets?.leading ?? 0),
              paddingTop: Float(state.insets?.top ?? 0),
              paddingRight: Float(state.insets?.trailing ?? 0),
              paddingBottom: Float(state.insets?.bottom ?? 0),
            )

            // Deselect all blocks.
            let selectedBlocks = context.engine.block.findAllSelected()
            try selectedBlocks.forEach { try context.engine.block.setSelected($0, selected: false) }

            try Self.setupPage(context)
          }
        } else {
          try OnChanged.default(update, context)
        }

      default:
        try OnChanged.default(update, context)
      }
    }
  }

  // MARK: - Helpers

  /// Gets the backdrop image from the scene.
  /// The backdrop image is the only image that is a direct child of the scene block.
  static func getBackdropImage(engine: Engine) throws -> DesignBlockID {
    guard let scene = try engine.scene.get() else { throw EditorError("No scene found.") }
    let childIDs = try engine.block.getChildren(scene)
    let imageID = try childIDs.first {
      guard try engine.block.getType($0) == DesignBlockType.graphic.rawValue,
            try engine.block.supportsFill($0)
      else {
        return false
      }
      return try engine.block.getType(try engine.block.getFill($0)) == FillType.image.rawValue
    }
    guard let imageID else {
      throw EditorError("No backdrop image found.")
    }
    return imageID
  }

  /// Configures the current page for proper apparel editing.
  static func setupPage(_ context: OnChanged.Context) throws {
    guard let page = try context.engine.scene.getCurrentPage() else {
      throw EditorError("No scene found.")
    }

    let fillChangeEnabled = try context.engine.block.isScopeEnabled(page, key: "fill/change")
    let layerClippingEnabled = try context.engine.block.isScopeEnabled(page, key: "layer/clipping")
    try context.engine.editor.setSettingBool("page/dimOutOfPageAreas", value: false)
    try context.engine.block.setClipped(page, clipped: true)
    try context.engine.block.setBool(page, property: "fill/enabled", value: false)
    try showOutline(false, engine: context.engine)
    try context.engine.block.setScopeEnabled(page, key: "fill/change", enabled: fillChangeEnabled)
    try context.engine.block.setScopeEnabled(page, key: "layer/clipping", enabled: layerClippingEnabled)
  }
}
