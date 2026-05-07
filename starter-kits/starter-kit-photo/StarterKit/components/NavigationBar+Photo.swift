import IMGLYEditor

// MARK: - Navigation Bar

extension PhotoEditorConfiguration {
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
          NavigationBar.Buttons.togglePreviewMode()
          NavigationBar.Buttons.export()
        }
      }
      // highlight-starter-kit-navigation-bar
    }
  }
}
