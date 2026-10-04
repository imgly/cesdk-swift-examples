import IMGLYEditor
import SwiftUI

// MARK: - Navigation Bar

extension ContentModerationEditorConfiguration {
  /// The default navigation bar configuration.
  ///
  /// Adds a "Validate Content" button that opens the moderation results panel
  /// next to the standard design editor navigation bar items. Its icon reflects
  /// the live validation status via ``ModerationStatusLabel``.
  static func navigationBar(_ moderation: ModerationStore) -> NavigationBar.Configuration {
    NavigationBar.Configuration { builder in
      // highlight-starter-kit-navigation-bar
      builder.items { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          // highlight-starter-kit-validate-button
          NavigationBar.Button(id: "my.app.navigationBar.button.validateContent") { context in
            guard let engine = context.engine else { return }
            context.eventHandler.send(.openSheet(style: .default(), content: {
              ModerationResultsPanel(
                store: moderation,
                engine: engine,
                eventHandler: context.eventHandler,
              )
            }))
          } label: { _ in
            ModerationStatusLabel(store: moderation)
          } isEnabled: { context in
            context.engine != nil
          }
          // highlight-starter-kit-validate-button
          NavigationBar.Buttons.export()
        }
      }
      // highlight-starter-kit-navigation-bar
    }
  }
}
