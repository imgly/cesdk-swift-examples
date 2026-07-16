import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Demonstrates how to let users add media from their device's photo library
/// in CE.SDK iOS.
///
/// Photo Roll ships as a built-in asset source with two access modes:
/// - `photosPicker` (default): opens the system photos picker, no permissions.
/// - `fullLibraryAccess`: browses the library in an in-app sheet, requires
///   photo library permission.
struct PhotoRollSolution: View {
  var settings: EngineSettings {
    EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>")
  }

  /// Default photos-picker configuration. Presented in the showcase and shown
  /// as the primary lesson in the guide.
  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            // GuideEditorConfiguration ships no scene, so build the page the
            // editor renders on. The default OnCreate would do this, but the
            // source registration below needs to run in the same callback.
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            // highlight-photoRoll-picker
            try engine.asset.addSource(PhotoRollAssetSource(engine: engine))
            // highlight-photoRoll-picker
          }
          // highlight-photoRoll-dock
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.photoRoll()
            }
          }
          // highlight-photoRoll-dock
          // highlight-photoRoll-onUpload
          builder.onUpload { _, sourceID, asset, existing in
            guard sourceID == PhotoRollAssetSource.id else { return try await existing(asset) }
            // AssetDefinition is immutable, so build a new one to tag the import.
            let tagged = AssetDefinition(
              id: asset.id,
              groups: asset.groups,
              meta: asset.meta,
              payload: asset.payload,
              label: asset.label,
              tags: ["en": ["photo-roll"]],
            )
            return try await existing(tagged)
          }
          // highlight-photoRoll-onUpload
        }
      }
  }

  /// Full library access configuration. Registering the source with
  /// `.fullLibraryAccess` makes the same dock button open the in-app library.
  var fullLibraryEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            // highlight-photoRoll-fullLibrary
            try engine.asset.addSource(PhotoRollAssetSource(engine: engine, mode: .fullLibraryAccess))
            // highlight-photoRoll-fullLibrary
          }
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.photoRoll()
            }
          }
        }
      }
  }

  @State private var isPresented = false

  var body: some View {
    Button("Use the Editor") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        editor
      }
    }
  }
}

#Preview {
  PhotoRollSolution()
}
