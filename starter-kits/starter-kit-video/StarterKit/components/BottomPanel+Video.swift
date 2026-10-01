import IMGLYEditor

// MARK: - Bottom Panel

extension VideoEditorConfiguration {
  /// The default bottom panel configuration.
  static var defaultBottomPanel: BottomPanel.Configuration {
    BottomPanel.Configuration { builder in
      // highlight-starter-kit-bottom-panel
      builder.content { context in
        Timeline(context: context, configuration: .videoStarterKit)
      }
      // highlight-starter-kit-bottom-panel
    }
  }
}

// MARK: - Timeline

private extension Timeline.Configuration {
  /// The `Timeline` renders its tracks alone, so this starter kit declares the header and the two
  /// lane buttons.
  static var videoStarterKit: Timeline.Configuration {
    Timeline.Configuration { builder in
      // highlight-starter-kit-timeline-header
      // The spacers are explicit, so inserting an item is predictable: put it before or after a
      // `Timeline.Spacer` to choose which edge it hugs.
      builder.header { _ in
        Timeline.ItemGroup(placement: .leading) {
          Timeline.Labels.timecode()
          Timeline.Spacer()
        }
        Timeline.ItemGroup(placement: .center) {
          Timeline.Buttons.playPause()
        }
        Timeline.ItemGroup(placement: .trailing) {
          Timeline.Buttons.loop()
          Timeline.Spacer()
          Timeline.Buttons.toggleExpanded()
        }
      }
      // highlight-starter-kit-timeline-header

      // highlight-starter-kit-timeline-lane-buttons
      builder.addClip = Timeline.Buttons.addClip()
      builder.addAudio = Timeline.Buttons.addAudio()
      // highlight-starter-kit-timeline-lane-buttons
    }
  }
}
