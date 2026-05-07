import IMGLYEditor
import SwiftUI

// MARK: - Dock

extension PostcardEditorConfiguration {
  /// The default dock configuration.
  static var defaultDock: Dock.Configuration {
    Dock.Configuration { builder in
      // highlight-starter-kit-dock
      builder.items { _ in
        Dock.Buttons
          .assetLibrary(
            isVisible: { try $0.engine.scene.getPages().first == $0.engine.scene.getCurrentPage() },
            modifier: { _ in Dock.Buttons.AssetLibraryModifier() },
          )
        Dock.Custom(id: "ly.img.component.dock.postcard.divider", content: { _ in
          Divider()
            .frame(height: 40)
            .padding(.leading, 8)
        }, isVisible: { try $0.engine.scene.getPages().first == $0.engine.scene.getCurrentPage() })
        Dock.Buttons.designColors()
        Dock.Buttons.greetingFont()
        Dock.Buttons.greetingSize()
        Dock.Buttons.greetingColors()
      }
      builder.alignment = {
        try $0.engine.scene.getPages().first == $0.engine.scene.getCurrentPage() ? .leading : .center
      }
      builder.scrollDisabled = { _ in true }
      // highlight-starter-kit-dock
    }
  }
}
