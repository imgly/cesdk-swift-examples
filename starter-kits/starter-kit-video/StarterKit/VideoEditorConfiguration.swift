import IMGLYEditor
import IMGLYEngine
import SwiftUI

// CE.SDK Starter Kit: Video Editor
//
// This starter kit provides a complete, production-ready Video Editor configuration
// with all configuration code inline and fully documented. Copy this file into your
// project and customize it to match your needs.

// MARK: - Configuration

public final class VideoEditorConfiguration: EditorConfiguration {
  // MARK: - EditorConfiguration — Settings

  /// The zoom padding for the canvas.
  override public var zoomPadding: CGFloat? { 1 }

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
  override public var onCreate: OnCreate.Handler? { Self.defaultOnCreateHandler }

  /// The export handler.
  ///
  /// Default: Exports the current page as MP4 and opens the system share sheet.
  override public var onExport: OnExport.Handler? { Self.defaultOnExportHandler }

  // MARK: - EditorConfiguration — UI Components

  /// The navigation bar configuration.
  override public var navigationBar: NavigationBar.Configuration? { Self.defaultNavigationBar }

  /// The dock configuration.
  override public var dock: Dock.Configuration? { Self.defaultDock }

  /// The inspector bar configuration.
  override public var inspectorBar: InspectorBar.Configuration? { Self.defaultInspectorBar }

  /// The canvas menu configuration.
  override public var canvasMenu: CanvasMenu.Configuration? { Self.defaultCanvasMenu }

  /// The bottom panel configuration.
  override public var bottomPanel: BottomPanel.Configuration? { Self.defaultBottomPanel }
}
