import IMGLYDesignEditor
import SwiftUI

/// This example demonstrates how to integrate photo library access in CE.SDK iOS.
///
/// This example shows how to:
/// - Use the default photos picker mode (privacy-friendly, no permissions)
/// - Enable full photo library access mode
/// - Configure Info.plist for photo library permissions
struct PhotoRollSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  // highlight-photoRoll-default
  // Default Photos Picker Mode
  // The photo roll button opens the system photos picker
  // No permissions required, maximum privacy
  var editorWithPhotosPicker: some View {
    DesignEditor(settings)
    // PhotoRollAssetSource is automatically registered in default mode
    // Dock includes Dock.Buttons.photoRoll() by default
    // Users tap Photo Roll → System picker opens → Select photos
  }

  // highlight-photoRoll-default

  // highlight-photoRoll-fullAccess
  // Full Library Access Mode
  // Photo library is loaded directly into the CE.SDK Asset Panel
  // Requires photo library permissions on first use
  var editorWithFullLibrary: some View {
    DesignEditor(settings)
      .imgly.onCreate { engine in
        // Load or create scene
        try await engine.scene.load(from: DesignEditor.defaultScene) // or `engine.scene.create*`
        // Add asset sources
        try await engine.addDefaultAssetSources()
        try await engine.addDemoAssetSources(sceneMode: engine.scene.getMode(),
                                             withUploadAssetSources: true)
        try await engine.asset.addSource(TextAssetSource(engine: engine))
        try engine.asset.addSource(PhotoRollAssetSource(engine: engine, mode: .fullLibraryAccess))
      }
    // IMPORTANT: Add NSPhotoLibraryUsageDescription to Info.plist
    // <key>NSPhotoLibraryUsageDescription</key>
    // <string>We need access to your photo library to let you add photos to your designs.</string>
  }

  // highlight-photoRoll-fullAccess

  @State private var isPresented = false
  @State private var useFullLibrary = false

  var body: some View {
    VStack {
      Toggle("Enable Full Library Access", isOn: $useFullLibrary)
        .padding()

      Button("Use the Editor") {
        isPresented = true
      }
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        if useFullLibrary {
          editorWithFullLibrary
        } else {
          editorWithPhotosPicker
        }
      }
    }
  }
}

#Preview {
  PhotoRollSolution()
}
