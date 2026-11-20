import IMGLYEditor
import SwiftUI

// MARK: - Bottom Panel

extension MemoriesEditorConfiguration {
  /// The thumbnail strip and the playback controls above the dock.
  static func bottomPanel(model: MemoriesModel) -> BottomPanel.Configuration {
    BottomPanel.Configuration { builder in
      // highlight-starter-kit-bottom-panel
      builder.content { context in
        MemoriesBottomPanel(model: model, eventHandler: context.eventHandler)
      }
      // highlight-starter-kit-bottom-panel
    }
  }
}

/// Hidden in the fullscreen preview, which shows ``MemoriesFullscreenControls`` instead.
private struct MemoriesBottomPanel: View {
  @ObservedObject var model: MemoriesModel
  let eventHandler: EditorEventHandler

  var body: some View {
    if !model.isPreviewMode {
      VStack(spacing: 4) {
        MemoriesTimelineStrip(model: model)
        MemoriesPlaybackControls(model: model) {
          eventHandler.send(.openSheet(style: .only(detent: .imgly.tiny)) {
            MemoriesVolumeSheet(model: model)
          })
        }
      }
      .padding(.bottom, 8)
    }
  }
}
