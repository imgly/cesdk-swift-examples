@_spi(Internal) import IMGLYEditor
import IMGLYEngine

// highlight-starter-kit-force-crop
/// Example: Apply force crop in the `onLoaded` callback.
/// Add this logic before or after the existing `onLoaded` handler in `PhotoEditorConfiguration`.
extension PhotoEditorConfiguration {
  static var forceCropOnLoadedHandler: OnLoaded.Handler {
    { context, existing in
      // Apply force crop: allow 1:1, 16:9, or 9:16
      if let page = try context.engine.scene.getPages().first {
        context.eventHandler.send(
          .applyForceCrop(
            to: page,
            with: [
              ForceCropPreset(sourceID: "ly.img.crop.presets", presetID: "aspect-ratio-1-1"),
              ForceCropPreset(sourceID: "ly.img.crop.presets", presetID: "aspect-ratio-16-9"),
              ForceCropPreset(sourceID: "ly.img.crop.presets", presetID: "aspect-ratio-9-16"),
            ],
            mode: .ifNeeded,
          ),
        )
      }
      // Continue with the existing onLoaded logic
      try await existing()
    }
  }
}

// highlight-starter-kit-force-crop
