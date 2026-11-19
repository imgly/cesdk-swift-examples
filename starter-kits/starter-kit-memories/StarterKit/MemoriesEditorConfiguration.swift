import IMGLYEditor
import IMGLYEngine
import SwiftUI

// CE.SDK Starter Kit: Memories Editor
//
// Turns picked photos and video clips into a slideshow with a title card, Ken Burns motion and
// transitions, then exports it as MP4. Copy the `StarterKit/` folder into your project and
// customize it to match your needs.

// MARK: - Configuration

/// The slideshow editor. The picked media and the editor state live in ``MemoriesModel``, which the
/// callbacks and components share.
final class MemoriesEditorConfiguration: EditorConfiguration {
  let model: MemoriesModel

  init(model: MemoriesModel) {
    self.model = model
    super.init()
  }

  // MARK: - EditorConfiguration — Settings

  /// The inset that keeps the page off the screen edges and the bottom controls.
  override var zoomPadding: CGFloat? {
    MemoriesConstants.canvasPadding
  }

  /// Includes the audio library that the Audio dock button opens.
  override var assetLibrary: AssetLibraryConfiguration? {
    AssetLibraryConfiguration { builder in
      builder.includeAVResources = true
    }
  }

  // MARK: - EditorConfiguration — Callbacks

  /// Builds the slideshow from the picked media.
  override var onCreate: OnCreate.Handler? {
    Self.onCreateHandler(model: model)
  }

  /// Starts the loading, playback, history and audio observers.
  override var onLoaded: OnLoaded.Handler? {
    { [model] context, _ in model.editorDidLoad(context) }
  }

  /// Exports the slideshow as MP4 and opens the system share sheet.
  override var onExport: OnExport.Handler? {
    Self.onExportHandler
  }

  /// Returns to the selection screen without asking, as the picked media stays there.
  override var onClose: OnClose.Handler? {
    { [model] _, _, _ in model.closeEditor() }
  }

  /// Removes the loading screen, then shows the editor's error alert.
  override var onError: OnError.Handler? {
    { [model] error, eventHandler, _ in
      model.editorDidFail()
      // Not `existing()`: no earlier handler is set, and the editor shows its alert only without a handler.
      eventHandler.send(.showErrorAlert(error))
    }
  }

  // MARK: - EditorConfiguration — UI Components

  override var navigationBar: NavigationBar.Configuration? {
    Self.defaultNavigationBar
  }

  override var dock: Dock.Configuration? {
    Self.dock(model: model)
  }

  override var bottomPanel: BottomPanel.Configuration? {
    Self.bottomPanel(model: model)
  }
}
