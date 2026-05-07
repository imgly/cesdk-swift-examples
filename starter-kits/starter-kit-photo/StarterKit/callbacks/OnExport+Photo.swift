import IMGLYEditor
import IMGLYEngine
import UniformTypeIdentifiers

// MARK: - Default OnExport

extension PhotoEditorConfiguration {
  /// The default export handler.
  ///
  /// Exports the scene as PNG and opens the system share sheet.
  static var defaultOnExportHandler: OnExport.Handler {
    { engine, eventHandler, _ in
      // highlight-starter-kit-on-export
      guard let scene = try engine.scene.get() else {
        throw EditorError("No scene was found.")
      }
      let data = try await engine.block.export(scene, mimeType: .png) { engine in
        try engine.scene.getPages().forEach {
          try engine.block.setScopeEnabled($0, key: "layer/visibility", enabled: true)
          try engine.block.setVisible($0, visible: true)
        }
      }
      let url = FileManager.default.temporaryDirectory.appendingPathComponent("Export", conformingTo: .png)
      try data.write(to: url, options: [.atomic])
      eventHandler.send(.shareFile(url))
      // highlight-starter-kit-on-export
    }
  }
}
