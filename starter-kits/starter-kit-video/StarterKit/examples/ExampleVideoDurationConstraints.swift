@_spi(Internal) import IMGLYEditor
import IMGLYEngine

// highlight-starter-kit-constraints
/// Example: Apply video duration constraints in the `onLoaded` callback.
/// Add this logic before or after the existing `onLoaded` handler in `VideoEditorConfiguration`.
extension VideoEditorConfiguration {
  static var durationConstraintsOnLoadedHandler: OnLoaded.Handler {
    { context, existing in
      // Enforce all videos to be between 10 and 20 seconds
      context.eventHandler.send(
        .setVideoDurationConstraints(
          minimumVideoDuration: 10,
          maximumVideoDuration: 20,
        ),
      )
      // Continue with the existing onLoaded logic
      try await existing()
    }
  }
}

// highlight-starter-kit-constraints
