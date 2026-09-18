import IMGLYEditor

// MARK: - Dock

extension DesignEditorConfiguration {
  /// The default dock configuration.
  static var defaultDock: Dock.Configuration {
    Dock.Configuration { builder in
      // highlight-starter-kit-dock
      builder.items { _ in
        Dock.Buttons.elementsLibrary()
        Dock.Buttons.photoRoll()
        Dock.Buttons.imglyCamera()
        Dock.Buttons.imagesLibrary()
        Dock.Buttons.textLibrary()
        Dock.Buttons.shapesLibrary()
        Dock.Buttons.stickersLibrary()
        Dock.Buttons.resize()
      }
      // highlight-starter-kit-dock
    }
  }
}
