import IMGLYEditor

// MARK: - Navigation Bar

extension VideoEditorConfiguration {
  /// The default navigation bar configuration.
  static var defaultNavigationBar: NavigationBar.Configuration {
    NavigationBar.Configuration { builder in
      // highlight-starter-kit-navigation-bar
      builder.items { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          NavigationBar.Buttons.export(
            isEnabled: {
              guard !$0.state.isCreating, !$0.state.isExporting,
                    let engine = $0.engine,
                    let scene = try engine.scene.get() else {
                return false
              }
              return try engine.block.getDuration(scene) > 0
            },
          )
        }
      }
      // highlight-starter-kit-navigation-bar
    }
  }
}
