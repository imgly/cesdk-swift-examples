import IMGLYEditor
import SwiftUI

// MARK: - Dock

extension VideoEditorConfiguration {
  /// The default dock configuration.
  static var defaultDock: Dock.Configuration {
    Dock.Configuration { builder in
      // highlight-starter-kit-dock
      builder.items { _ in
        Dock.Buttons.photoRoll(
          action: { $0.eventHandler.send(.addFromPhotoRoll(addToBackgroundTrack: true)) },
          icon: { _ in Image.imgly.addPhotoRollBackground },
        ) // Device photos and videos
        // highlight-starter-kit-imgly-camera
        Dock.Buttons.imglyCamera(icon: { _ in Image.imgly.addCameraBackground }) // Camera capture
        // highlight-starter-kit-imgly-camera
        Dock.Buttons.overlaysLibrary() // Video overlays
        Dock.Buttons.textLibrary() // Text tools
        Dock.Buttons.stickersAndShapesLibrary() // Stickers and shapes
        Dock.Buttons.audioLibrary() // Audio tracks
        Dock.Buttons.voiceover() // Voice recording
        Dock.Buttons.resize() // Aspect ratio and canvas size
      }
      // highlight-starter-kit-dock
    }
  }
}
