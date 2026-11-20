import IMGLYEditor
import SwiftUI

// MARK: - Dock

extension MemoriesEditorConfiguration {
  static func dock(model: MemoriesModel) -> Dock.Configuration {
    Dock.Configuration { builder in
      // highlight-starter-kit-dock
      builder.alignment = { _ in .center }
      builder.items { _ in
        // Opens the media grid, staged against the clips on the tracks.
        Dock.Button(id: "ly.img.memories.media") { _ in
          model.openMediaOverlay()
        } label: { _ in
          Label("Media", systemImage: "photo.on.rectangle")
        }

        Dock.Button(id: "ly.img.memories.styles") { context in
          context.eventHandler.send(.openSheet(style: .only(detent: .imgly.small)) {
            MemoriesStylesSheet(model: model)
          })
        } label: { _ in
          Label("Styles", systemImage: "camera.filters")
        }

        // The editor's audio library. A new soundtrack replaces the current one.
        Dock.Buttons.audioLibrary(action: { context in
          model.setPlaying(false)
          context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.audioTab }))
        })
      }
      // highlight-starter-kit-dock
    }
  }
}
