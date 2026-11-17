import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Starter Kit View

/// The complete Memories flow: pick photos and videos, then edit the slideshow built from them.
struct MemoriesEditorStarterKit: View {
  // Provide `EngineSettings` with your license and an optional userId.
  let settings = EngineSettings(
    license: secrets.licenseKey, // Use nil for evaluation mode with watermark
    userID: "<your unique user id>",
  )

  /// Leaves the flow from the selection screen, which then shows a close button. An app whose root is
  /// this view needs none.
  var onExit: (() -> Void)?

  @StateObject private var model = MemoriesModel()

  // highlight-starter-kit-view
  var body: some View {
    switch model.screen {
    case .selection:
      MemoriesSelectionScreen(model: model, onExit: onExit)
    case .editor:
      ZStack {
        // highlight-starter-kit-composable
        NavigationStack {
          Editor(settings)
            .imgly.configuration {
              MemoriesEditorConfiguration(model: model)
            }
        }
        // highlight-starter-kit-composable
        if model.isMediaOverlayPresented {
          MemoriesMediaOverlay(model: model)
            .transition(.move(edge: .bottom))
        }
        if model.isPreviewMode {
          MemoriesFullscreenControls(model: model)
        }
        if model.isEditorLoading {
          MemoriesLoadingScreen(items: model.picker.items)
            .transition(.opacity)
        }
      }
      .animation(.easeInOut(duration: 0.3), value: model.isEditorLoading)
      .animation(.easeInOut(duration: 0.25), value: model.isMediaOverlayPresented)
    }
  }
  // highlight-starter-kit-view
}

// MARK: - Preview

#Preview {
  MemoriesEditorStarterKit()
}
