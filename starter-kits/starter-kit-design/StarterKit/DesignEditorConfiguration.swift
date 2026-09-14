import IMGLYEditor
import IMGLYEngine
import SwiftUI

// CE.SDK Starter Kit: Design Editor
//
// This starter kit provides a complete, production-ready Design Editor configuration
// with all configuration code inline and fully documented. Copy this file into your
// project and customize it to match your needs.

// MARK: - Configuration

/// A composable Design Editor configuration.
public final class DesignEditorConfiguration: EditorConfiguration {
  // MARK: - EditorConfiguration — Settings

  /// The zoom padding for the canvas.
  override public var zoomPadding: CGFloat? { 16 }

  // MARK: - EditorConfiguration — Callbacks

  /// The `onCreate` handler.
  override public var onCreate: OnCreate.Handler? { Self.defaultOnCreateHandler }

  /// The export handler.
  ///
  /// Default: Exports the scene as PDF and opens the system share sheet.
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
}
