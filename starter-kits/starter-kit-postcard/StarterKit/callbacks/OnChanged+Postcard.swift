import IMGLYEditor
import IMGLYEngine

// MARK: - Default OnChanged

extension PostcardEditorConfiguration {
  /// The default `onChanged` handler.
  static var defaultOnChangedHandler: OnChanged.Handler {
    { update, context, _ in
      switch update {
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
        if state.editorViewMode == .preview {
          guard let scene = try context.engine.block.find(byType: .scene).first else {
            throw EditorError("No scene found.")
          }

          // Disable camera clamping.
          if try context.engine.scene.unstable_isCameraZoomClampingEnabled(scene) {
            try context.engine.scene.unstable_disableCameraZoomClamping()
          }
          if try context.engine.scene.unstable_isCameraPositionClampingEnabled(scene) {
            try context.engine.scene.unstable_disableCameraPositionClamping()
          }

          // Deselect all blocks.
          try context.engine.block.findAllSelected().forEach {
            try context.engine.block.setSelected($0, selected: false)
          }

          if let stack = try? context.engine.block.find(byType: .stack).first {
            let layoutAxis = state.verticalSizeClass == .compact ? "Horizontal" : "Vertical"
            try context.engine.block.setEnum(stack, property: "stack/axis", value: layoutAxis)
            try context.engine.block.setInt(stack, property: "stack/spacing", value: 16)
          }

          let pages = try context.engine.scene.getPages()
          for block in pages {
            let isVisibilityEnabled = try context.engine.block.isScopeEnabled(block, key: "layer/visibility")
            try context.engine.block.setScopeEnabled(block, key: "layer/visibility", enabled: true)
            try context.engine.block.setVisible(block, visible: true)
            try context.engine.block.setScopeEnabled(block, key: "layer/visibility", enabled: isVisibilityEnabled)
          }

          Task {
            // Zoom to the entire scene.
            try await context.engine.scene.zoom(
              to: scene,
              paddingLeft: Float(state.insets?.leading ?? 0),
              paddingTop: Float(state.insets?.top ?? 0),
              paddingRight: Float(state.insets?.trailing ?? 0),
              paddingBottom: Float(state.insets?.bottom ?? 0),
            )

            // Deselect all blocks.
            let selectedBlocks = context.engine.block.findAllSelected()
            try selectedBlocks.forEach { try context.engine.block.setSelected($0, selected: false) }
          }
        } else {
          try OnChanged.default(update, context)
        }

      default:
        try OnChanged.default(update, context)
      }
    }
  }
}
