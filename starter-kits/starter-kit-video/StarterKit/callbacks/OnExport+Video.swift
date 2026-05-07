import Foundation
import IMGLYEditor
import IMGLYEngine

// MARK: - Default OnExport

extension VideoEditorConfiguration {
  /// The default export handler.
  ///
  /// Exports the current page as MP4 and opens the system share sheet.
  static var defaultOnExportHandler: OnExport.Handler {
    { engine, eventHandler, _ in
      // highlight-starter-kit-on-export
      guard let page = try engine.scene.getCurrentPage() else {
        throw EditorError("No page was found.")
      }
      eventHandler.send(.exportProgress(.relative(0)))
      let mimeType: MIMEType = .mp4
      let stream = try await engine.block.exportVideo(page, mimeType: mimeType) { _ in }

      var lastReportedProgress = 0
      for try await export in stream {
        try Task.checkCancellation()
        switch export {
        case let .progress(_, encodedFrames, totalFrames):
          let progress = Int((Float(encodedFrames) / Float(totalFrames)) * 100)
          if progress > lastReportedProgress {
            lastReportedProgress = progress
            eventHandler.send(.exportProgress(.relative(Float(progress) / 100)))
          }
        case let .finished(video: videoData):
          let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "Export",
            conformingTo: mimeType.uniformType,
          )
          try videoData.write(to: url, options: [.atomic])
          eventHandler.send(.exportCompleted { eventHandler.send(.shareFile(url)) })
          return
        }
      }
      try Task.checkCancellation()
      throw EditorError("Failed to export the content.")
      // highlight-starter-kit-on-export
    }
  }
}
