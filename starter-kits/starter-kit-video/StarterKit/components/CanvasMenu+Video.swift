import IMGLYEditor

// MARK: - Canvas Menu

extension VideoEditorConfiguration {
  /// The default canvas menu configuration.
  static var defaultCanvasMenu: CanvasMenu.Configuration {
    CanvasMenu.Configuration { builder in
      // highlight-starter-kit-canvas-menu
      builder.items { _ in
        CanvasMenu.Buttons.selectGroup()
        CanvasMenu.Divider()
        CanvasMenu.Buttons.bringForward()
        CanvasMenu.Buttons.sendBackward()
        CanvasMenu.Divider()
        CanvasMenu.Buttons.duplicate()
        CanvasMenu.Buttons.delete()
      }
      // highlight-starter-kit-canvas-menu
    }
  }
}
