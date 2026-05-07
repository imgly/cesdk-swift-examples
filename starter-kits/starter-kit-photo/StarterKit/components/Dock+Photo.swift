import IMGLYEditor

// MARK: - Dock

extension PhotoEditorConfiguration {
  /// The default dock configuration.
  static var defaultDock: Dock.Configuration {
    Dock.Configuration { builder in
      // highlight-starter-kit-dock
      builder.items { _ in
        Dock.Buttons.adjustments() // Image adjustments
        Dock.Buttons.filter() // Filters
        Dock.Buttons.effect() // Effects
        Dock.Buttons.blur() // Blur
        Dock.Buttons.crop() // Crop tool
        Dock.Buttons.textLibrary() // Text tools
        Dock.Buttons.shapesLibrary() // Shapes
        Dock.Buttons.stickersLibrary() // Stickers
      }
      // highlight-starter-kit-dock
    }
  }
}
