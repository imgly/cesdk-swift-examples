import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Default OnExport

extension VideoModerationEditorConfiguration {
  /// The default export handler.
  ///
  /// Gates the export on video moderation: a video that was checked, is unchanged since,
  /// has nothing flagged as *Certain* or *Likely*, and has every block checked exports as
  /// MP4 and opens the system share sheet. Any other video shows an alert that offers to
  /// moderate now, to export anyway, or to cancel.
  ///
  /// Remove the gate if your workflow moderates content at a different
  /// integration point (e.g. on upload or in a review queue).
  static func onExportHandler(_ moderation: VideoModerationStore) -> OnExport.Handler {
    { engine, eventHandler, existing in
      // highlight-starter-kit-on-export-validation
      if let reason = VideoModerationExportAlert.Reason.current(store: moderation, engine: engine) {
        eventHandler.send(.openSheet(style: .default(), content: {
          VideoModerationExportAlert(
            store: moderation,
            reason: reason,
            engine: engine,
            eventHandler: eventHandler,
            // `existing` is non-escaping, so the override path exports directly
            // instead of chaining. With no other export handler registered in
            // this kit the two are equivalent.
            onExportAnyway: {
              Task {
                do {
                  try await exportVideo(engine: engine, eventHandler: eventHandler)
                } catch {
                  eventHandler.send(.showErrorAlert(error))
                }
              }
            },
          )
        }))
        return
      }
      // highlight-starter-kit-on-export-validation

      try await existing()
      try await exportVideo(engine: engine, eventHandler: eventHandler)
    }
  }

  /// Exports the current page as MP4 and opens the system share sheet.
  @MainActor
  private static func exportVideo(engine: Engine, eventHandler: any EditorEventHandler) async throws {
    // highlight-starter-kit-on-export
    guard let page = try engine.scene.getCurrentPage() else {
      throw EditorError("No page was found.")
    }
    eventHandler.send(.exportProgress(.relative(0)))
    let mimeType: MIMEType = .mp4
    // videoBitrate: .auto derives a bounded bitrate from the resolution/framerate.
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
