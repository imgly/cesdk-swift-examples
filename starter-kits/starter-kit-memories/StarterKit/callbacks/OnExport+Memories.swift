import Foundation
import IMGLYEditor
import IMGLYEngine

// MARK: - OnExport

extension MemoriesEditorConfiguration {
  /// Renders the slideshow page to an MP4 and opens the system share sheet. The editor shows the
  /// progress and lets the user cancel.
  static var onExportHandler: OnExport.Handler {
    { engine, eventHandler, _ in
      // highlight-starter-kit-on-export
      guard let page = try engine.scene.getCurrentPage() else {
        throw EditorError("No page was found.")
      }
      eventHandler.send(.exportProgress(.relative(0)))
      let mimeType: MIMEType = .mp4
      // `.auto` derives a bounded bitrate from the resolution and frame rate.
      let stream = try await engine.block.exportVideo(
        page,
        mimeType: mimeType,
        options: VideoExportOptions(videoBitrate: .auto),
      ) { _ in }

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
            "Memory",
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
