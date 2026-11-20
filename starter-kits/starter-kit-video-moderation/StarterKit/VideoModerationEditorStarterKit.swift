import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Starter Kit View

struct VideoModerationEditorStarterKit: View {
  // Provide `EngineSettings` with your license and an optional userId.
  let settings = EngineSettings(
    license: secrets.licenseKey, // Use nil for evaluation mode with watermark
    userID: "<your unique user id>",
  )

  // Moderation state for this editor, pointed at the IMG.LY AI Gateway with the key
  // from `Secrets.swift`. Swap in your own `VideoModerationService` here to use a
  // different provider. Held as `@StateObject` so it survives re-renders — the
  // editor's verdict must not be discarded every time this view's body runs.
  @StateObject private var moderation = VideoModerationStore(
    service: GatewayVideoModerationService(apiKey: secrets.gatewayApiKey, thresholds: .moderate),
  )

  // highlight-starter-kit-view
  var body: some View {
    // highlight-starter-kit-composable
    Editor(settings)
      .imgly.configuration {
        VideoModerationEditorConfiguration(moderation: moderation)
      }
    // highlight-starter-kit-composable
  }
  // highlight-starter-kit-view
}

// MARK: - Preview

#Preview {
  VideoModerationEditorStarterKit()
}
