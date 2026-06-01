import IMGLYEditor

/// A baseline editor configuration used across CE.SDK guides.
///
/// Sets up a navigation bar with the essentials that work without extra configuration:
/// a close button (so users can always dismiss the editor, matching Android's system
/// back) plus undo and redo. Each guide builds on top of this by declaring its own dock,
/// canvas menu, inspector bar, or overriding the navigation bar as needed.
class GuideEditorConfiguration: EditorConfiguration {
  override var navigationBar: NavigationBar.Configuration? {
    NavigationBar.Configuration { builder in
      builder.items { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
        }
      }
    }
  }
}
