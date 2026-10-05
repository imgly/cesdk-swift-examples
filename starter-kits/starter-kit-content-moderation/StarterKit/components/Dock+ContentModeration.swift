import IMGLYEditor

// MARK: - Dock

extension ContentModerationEditorConfiguration {
  /// The default dock configuration.
  ///
  /// The photo roll and camera buttons are omitted so the demo leads with the
  /// bundled example scene rather than the picker. Local images are still checked
  /// wherever they enter — ``GatewayModerationService`` uploads them — so add
  /// `Dock.Buttons.photoRoll()` and `Dock.Buttons.imglyCamera()` back if you want
  /// them, and they arrive through the images library and
  /// `InspectorBar.Buttons.replace()` regardless.
  static var defaultDock: Dock.Configuration {
    Dock.Configuration { builder in
      // highlight-starter-kit-dock
      builder.items { _ in
        Dock.Buttons.elementsLibrary()
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
