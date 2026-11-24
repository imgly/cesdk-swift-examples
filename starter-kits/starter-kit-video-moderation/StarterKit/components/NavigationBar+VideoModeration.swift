import IMGLYEditor
import SwiftUI

// MARK: - Navigation Bar

extension VideoModerationEditorConfiguration {
  /// The default navigation bar configuration.
  ///
  /// Adds a "Validate Content" button that opens the moderation results panel
  /// next to the standard video editor navigation bar items. Its icon reflects
  /// the live validation status via ``VideoModerationStatusLabel``.
  static func navigationBar(_ moderation: VideoModerationStore) -> NavigationBar.Configuration {
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
              VideoModerationResultsPanel(
                store: moderation,
                engine: engine,
                eventHandler: context.eventHandler,
              )
            }))
          } label: { _ in
            VideoModerationStatusLabel(store: moderation)
          } isEnabled: { context in
            context.engine != nil
          }
          // highlight-starter-kit-validate-button
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
