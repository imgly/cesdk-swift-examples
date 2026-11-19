import IMGLYEditor
import IMGLYEngine
import SwiftUI

// CE.SDK Starter Kit: Video Moderation Editor
//
// This starter kit provides a complete, production-ready Video Editor configuration
// extended with a moderation workflow: a "Validate Content" button checks every video clip,
// image and text in the scene against a moderation API and reports violations in a
// results panel, grouped by block with the flagged times of each clip, and export is
// gated on the video being free of violations.
// Copy these files into your project and customize them to match your needs.

// MARK: - Configuration

/// A composable Video Moderation Editor configuration.
public final class VideoModerationEditorConfiguration: EditorConfiguration {
  // MARK: - Moderation

  /// The moderation state for this editor.
  ///
  /// Exposed so a host can reach it: installing a service once the user supplies an
  /// API key, or observing ``VideoModerationStore/authenticationFailed`` to re-prompt.
  /// Everything inside the kit receives this instance rather than reaching for a
  /// global, so two editors never share one verdict.
  public let moderation: VideoModerationStore

  /// Creates the configuration.
  /// - Parameters:
  ///   - moderation: The moderation state to use. Pass a store you hold when the host
  ///     needs a reference to it; omit it for one the configuration owns.
  ///   - customize: Customizes the underlying editor builder.
  public init(
    moderation: VideoModerationStore = VideoModerationStore(),
    _ customize: (_ builder: Builder) -> Void = { _ in },
  ) {
    // Assigned before `super.init`, which calls `prepopulateDefaults(from:)` and so
    // reads the overridden properties below — each of which needs this store.
    self.moderation = moderation
    super.init(customize)
  }

  // MARK: - EditorConfiguration — Settings

  /// The zoom padding for the canvas.
  override public var zoomPadding: CGFloat? {
    1
  }

  /// The asset library configuration.
  ///
  /// Includes video and audio categories for the video editor.
  override public var assetLibrary: AssetLibraryConfiguration? {
    AssetLibraryConfiguration { builder in
      builder.includeAVResources = true
    }
  }

  // MARK: - EditorConfiguration — Callbacks

  /// The `onCreate` handler.
  override public var onCreate: OnCreate.Handler? {
    Self.defaultOnCreateHandler
  }

  /// The `onLoaded` handler.
  ///
  /// Resets the moderation state and starts change tracking, once the engine exists.
  override public var onLoaded: OnLoaded.Handler? {
    Self.defaultOnLoadedHandler(moderation)
  }

  /// The export handler.
  ///
  /// Default: Exports a video that the last check found clean as MP4 and opens the
  /// system share sheet. Any other video shows an alert that offers to moderate now,
  /// to export anyway, or to cancel.
  override public var onExport: OnExport.Handler? {
    Self.onExportHandler(moderation)
  }

  // MARK: - EditorConfiguration — UI Components

  /// The navigation bar configuration.
  override public var navigationBar: NavigationBar.Configuration? {
    Self.navigationBar(moderation)
  }

  /// The dock configuration.
  override public var dock: Dock.Configuration? {
    Self.defaultDock
  }

  /// The inspector bar configuration.
  override public var inspectorBar: InspectorBar.Configuration? {
    Self.defaultInspectorBar
  }

  /// The canvas menu configuration.
  override public var canvasMenu: CanvasMenu.Configuration? {
    Self.defaultCanvasMenu
  }

  /// The bottom panel configuration: the timeline.
  override public var bottomPanel: BottomPanel.Configuration? {
    Self.defaultBottomPanel
  }
}
