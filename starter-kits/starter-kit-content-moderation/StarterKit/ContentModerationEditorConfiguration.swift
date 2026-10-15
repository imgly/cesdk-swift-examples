import IMGLYEditor
import IMGLYEngine
import SwiftUI

// CE.SDK Starter Kit: Content Moderation Editor
//
// This starter kit provides a complete, production-ready Design Editor configuration
// extended with a content moderation workflow: a "Validate" button checks every
// image and text block in the scene against a content moderation API and reports
// violations in a results panel, grouped by the block they came from, and export is
// gated on the design being free of violations.
// Copy these files into your project and customize them to match your needs.

// MARK: - Configuration

/// A composable Content Moderation Editor configuration.
public final class ContentModerationEditorConfiguration: EditorConfiguration {
  // MARK: - Moderation

  /// The moderation state for this editor.
  ///
  /// Exposed so a host can reach it: installing a service once the user supplies an
  /// API key, or observing ``ModerationStore/authenticationFailed`` to re-prompt.
  /// Everything inside the kit receives this instance rather than reaching for a
  /// global, so two editors never share one verdict.
  public let moderation: ModerationStore

  /// Creates the configuration.
  /// - Parameters:
  ///   - moderation: The moderation state to use. Pass a store you hold when the host
  ///     needs a reference to it; omit it for one the configuration owns.
  ///   - customize: Customizes the underlying editor builder.
  public init(
    moderation: ModerationStore = ModerationStore(),
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
    16
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
  /// Default: Requires a completed validation first. If any
  /// violations are found the export is blocked and the results panel opens.
  /// Otherwise the scene is exported as PDF and the system share sheet opens.
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
}
