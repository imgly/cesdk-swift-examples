import IMGLYEditor

// MARK: - Bottom Panel

extension VideoEditorConfiguration {
  /// The default bottom panel configuration.
  static var defaultBottomPanel: BottomPanel.Configuration {
    BottomPanel.Configuration { builder in
      // highlight-starter-kit-bottom-panel
      builder.content { context in
        DefaultTimelineComponent(context: context)
      }
      // highlight-starter-kit-bottom-panel
    }
  }
}
