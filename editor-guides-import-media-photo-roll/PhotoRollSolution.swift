import IMGLYEditor
import IMGLYEngine
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
    Editor(settings)
      .imgly.configuration { DesignEditorConfiguration() }
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
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            // Load or create scene
            let sceneURL = Bundle.main.url(forResource: "design-ui-empty", withExtension: "scene")!
            try await engine.scene.load(from: sceneURL) // or `engine.scene.create*`
            // Add asset sources
            let basePath = try engine.editor.getSettingString("basePath")
            guard let baseURL = URL(string: basePath) else { return }
            let sourceIDs = [
              "ly.img.sticker", "ly.img.vector.shape", "ly.img.filter", "ly.img.color.palette",
              "ly.img.effect", "ly.img.blur", "ly.img.typeface", "ly.img.crop.presets",
              "ly.img.page.presets", "ly.img.text.presets", "ly.img.text.components",
              "ly.img.caption.presets", "ly.img.image",
            ]
            try await withThrowingTaskGroup(of: String.self) { group in
              for id in sourceIDs {
                group.addTask {
                  try await engine.asset.addLocalAssetSourceFromJSON(
                    baseURL.appendingPathComponent(id).appendingPathComponent("content.json"),
                  )
                }
              }
              for try await _ in group {}
            }
            try engine.asset.addLocalSource(
              sourceID: "ly.img.image.upload",
              supportedMimeTypes: ["image/jpeg", "image/png", "image/svg+xml", "image/gif", "image/apng", "image/bmp"],
            )
            try await engine.asset.addSource(TextAssetSource(engine: engine))
            try engine.asset.addSource(PhotoRollAssetSource(engine: engine, mode: .fullLibraryAccess))
          }
        }
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
