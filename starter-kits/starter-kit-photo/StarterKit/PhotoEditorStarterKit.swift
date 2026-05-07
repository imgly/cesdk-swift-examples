import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Starter Kit View

struct PhotoEditorStarterKit: View {
  // Provide `EngineSettings` with your license and an optional userId.
  let settings = EngineSettings(
    license: secrets.licenseKey, // Use nil for evaluation mode with watermark
    userID: "<your unique user id>",
  )

  // highlight-starter-kit-view
  var body: some View {
    // highlight-starter-kit-composable
    Editor(settings)
      .imgly.configuration {
        PhotoEditorConfiguration()
      }
    // highlight-starter-kit-composable
  }
  // highlight-starter-kit-view
}

// MARK: - Preview

#Preview {
  PhotoEditorStarterKit()
}
