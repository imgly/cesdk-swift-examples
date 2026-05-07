import IMGLYEditor

// MARK: - Dock

extension ApparelEditorConfiguration {
  /// The default dock configuration.
  static var defaultDock: Dock.Configuration {
    Dock.Configuration { builder in
      // highlight-starter-kit-dock
      builder.items { _ in
        Dock.Buttons.assetLibrary(modifier: { _ in Dock.Buttons.AssetLibraryModifier() })
      }
      builder.alignment = { _ in .leading }
      builder.backgroundColor = { _, _ in .clear }
      builder.scrollDisabled = { _ in true }
      // highlight-starter-kit-dock
    }
  }
}
