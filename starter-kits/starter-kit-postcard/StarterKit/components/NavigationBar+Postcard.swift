import IMGLYEditor

// MARK: - Navigation Bar

extension PostcardEditorConfiguration {
  /// The default navigation bar configuration.
  static var defaultNavigationBar: NavigationBar.Configuration {
    NavigationBar.Configuration { builder in
      // highlight-starter-kit-navigation-bar
      builder.items { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
          NavigationBar.Buttons.previousPage(
            label: { _ in NavigationLabel(
              .imgly.localized("ly_img_editor_navigation_bar_button_design"),
              direction: .backward,
            ) },
          )
        }
        NavigationBar.ItemGroup(placement: .principal) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          NavigationBar.Buttons.togglePreviewMode()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.nextPage(
            label: { _ in NavigationLabel(
              .imgly.localized("ly_img_editor_navigation_bar_button_write"),
              direction: .forward,
            ) },
          )
          NavigationBar.Buttons.export()
        }
      }
      // highlight-starter-kit-navigation-bar
    }
  }
}
