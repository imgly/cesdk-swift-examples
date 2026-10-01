import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating how to customize the video timeline.
///
/// The `editor` view shows the lesson — what the documentation renders, and what the showcase runs.
/// The alternatives below it are the variants the guide discusses one at a time. They are not
/// mounted; they exist so every snippet the guide renders is compiled rather than hand-written.
struct VideoTimelineEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  // highlight-videoTimeline-expandedState
  /// The timeline's expanded state, owned by this view rather than by the component.
  @State private var isTimelineExpanded = true
  // highlight-videoTimeline-expandedState

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // Demo scaffolding — not part of the lesson: footage to arrange, so the timeline has a
          // background track to render.
          builder.onCreate { engine, _ in
            let basePath = try engine.editor.getSettingString("basePath")
            guard let baseURL = URL(string: basePath) else { return }
            try await engine.scene.create(
              fromVideo: baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4"),
            )
            // Trimmed to a few seconds so the whole background track — and the "Add Clip" button
            // that sits after its last clip — fits the viewport at the default zoom.
            guard let page = try engine.scene.getCurrentPage() else { return }
            try engine.block.setDuration(page, duration: Self.demoClipDuration)
            for graphicBlock in try engine.block.find(byType: .graphic) {
              try engine.block.setDuration(graphicBlock, duration: Self.demoClipDuration)
            }
          }
          // Demo scaffolding — not part of the lesson: the dock a video editor typically offers,
          // so the timeline sits above it the way it does in a real integration rather than
          // floating above the empty bottom-bar slot.
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.photoRoll(
                action: { $0.eventHandler.send(.addFromPhotoRoll(addToBackgroundTrack: true)) },
                icon: { _ in Image.imgly.addPhotoRollBackground },
              )
              Dock.Buttons.imglyCamera(icon: { _ in Image.imgly.addCameraBackground })
              Dock.Buttons.overlaysLibrary()
              Dock.Buttons.textLibrary()
              Dock.Buttons.stickersAndShapesLibrary()
              Dock.Buttons.audioLibrary()
              Dock.Buttons.voiceover()
              Dock.Buttons.resize()
            }
          }
          // highlight-videoTimeline-bottomPanel
          builder.bottomPanel { bottomPanel in
            // Built once here rather than inside `content`, which re-renders with the editor.
            let configuration = timelineConfiguration
            bottomPanel.content { context in
              // highlight-videoTimeline-isExpanded
              Timeline(
                context: context,
                configuration: configuration,
                isExpanded: $isTimelineExpanded,
              )
              // highlight-videoTimeline-isExpanded
            }
          }
          // highlight-videoTimeline-bottomPanel
        }
      }
  }

  /// Keeps the demo clip short enough that the background track and its "Add Clip" button both
  /// fit on screen.
  private static let demoClipDuration = 4.0

  /// The configuration the editor above mounts.
  private var timelineConfiguration: Timeline.Configuration {
    .init { configuration in
      // highlight-videoTimeline-addClip
      configuration.addClip = Timeline.Buttons.addClip { _ in
        // Passing options replaces the menu, so the built-in sources are restated here.
        Timeline.AddClipOption.camera()
        Timeline.AddClipOption.library()
        Timeline.AddClipOption.photoRoll()
        Timeline.AddClipOption.custom(
          id: "my.package.timeline.addClip.stockFootage",
          action: { context in
            context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.videosTab }))
          },
          title: { _ in Text("Stock Footage") },
          icon: { _ in Image(systemName: "film.stack") },
        )
      }
      // highlight-videoTimeline-addClip

      // highlight-videoTimeline-addAudio
      configuration.addAudio = Timeline.Buttons.addAudio { _ in
        Timeline.AddAudioOption.music()
        Timeline.AddAudioOption.voiceover()
        Timeline.AddAudioOption.custom(
          id: "my.package.timeline.addAudio.soundEffects",
          action: { context in
            context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.audioTab }))
          },
          title: { _ in Text("Sound Effects") },
          icon: { _ in Image(systemName: "waveform") },
        )
      }
      // highlight-videoTimeline-addAudio

      // highlight-videoTimeline-header-declare
      // The timeline renders tracks alone, so the header is declared before it is adjusted.
      configuration.header { _ in
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
      // highlight-videoTimeline-header-declare

      // highlight-videoTimeline-modifyHeader
      configuration.modifyHeader { _, items in
        items.remove(id: Timeline.Buttons.ID.loop)
        items.addFirst(placement: .trailing) {
          Timeline.Custom(id: "my.package.timeline.button.mute", content: { _ in
            MuteButton()
          })
        }
      }
      // highlight-videoTimeline-modifyHeader

      // highlight-videoTimeline-height
      configuration.height = { _ in .dynamic(maximumTracks: 2) }
      // highlight-videoTimeline-height
    }
  }

  // MARK: - Alternatives

  /// Restating the options, which is what it takes to reorder
  /// them, relabel one, or replace what a built-in source does.
  private var restatedAddClip: some Timeline.Item {
    // highlight-videoTimeline-addClipRestated
    Timeline.Buttons.addClip { _ in
      Timeline.AddClipOption.photoRoll()
      // A built-in source keeps its behavior while its label and icon change.
      Timeline.AddClipOption.library(
        title: { _ in Text("Media") },
        icon: { _ in Image(systemName: "square.stack.fill") },
      )
      // A built-in source keeps its label and icon while its action is replaced.
      Timeline.AddClipOption.camera(action: { context in
        context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.videosTab }))
      })
    }
    // highlight-videoTimeline-addClipRestated
  }

  /// One visible source, so the button performs it on tap instead of opening a menu.
  private var singleSourceAddClip: some Timeline.Item {
    // highlight-videoTimeline-addClipSingle
    Timeline.Buttons.addClip { _ in Timeline.AddClipOption.photoRoll() }
    // highlight-videoTimeline-addClipSingle
  }

  /// A source hidden while the editor exports, leaving the rest of the menu intact.
  private var conditionalAddClip: some Timeline.Item {
    // highlight-videoTimeline-addClipConditional
    Timeline.Buttons.addClip { _ in
      Timeline.AddClipOption.camera(isVisible: { !$0.state.isExporting })
      Timeline.AddClipOption.library()
    }
    // highlight-videoTimeline-addClipConditional
  }

  /// Replacing the whole button rather than its options.
  private var customAddAudioButton: some Timeline.Item {
    // highlight-videoTimeline-addAudioCustom
    Timeline.Custom(id: "my.package.timeline.button.addAudio", content: { context in
      Button {
        context.eventHandler.send(.openSheet(type: .voiceover()))
      } label: {
        Label("Record", systemImage: "mic.circle.fill")
          .font(.caption)
          .fontWeight(.semibold)
      }
      .buttonStyle(.plain)
      .padding(.horizontal)
      .fixedSize(horizontal: true, vertical: false)
    })
    // highlight-videoTimeline-addAudioCustom
  }

  /// Declaring the header outright instead of adjusting the built-in one.
  private var restatedHeaderConfiguration: Timeline.Configuration {
    .init { configuration in
      // highlight-videoTimeline-header
      configuration.header { _ in
        Timeline.ItemGroup(placement: .leading) {
          Timeline.Labels.timecode()
          Timeline.Spacer()
        }
        Timeline.ItemGroup(placement: .center) {
          Timeline.Buttons.playPause()
        }
        Timeline.ItemGroup(placement: .trailing) {
          Timeline.Spacer()
          Timeline.Buttons.toggleExpanded()
        }
      }
      // highlight-videoTimeline-header
    }
  }

  /// Removing every surface the configuration can remove.
  private var strippedConfiguration: Timeline.Configuration {
    .init { configuration in
      // highlight-videoTimeline-remove
      configuration.addClip = nil
      configuration.addAudio = nil
      configuration.header { _ in }
      // highlight-videoTimeline-remove
    }
  }

  /// A height that follows the context instead of being a constant.
  private var adaptiveHeightConfiguration: Timeline.Configuration {
    .init { configuration in
      // highlight-videoTimeline-heightAdaptive
      configuration.height = { context in
        context.verticalSizeClass == .compact ? .fixed(tracks: 1) : .dynamic(maximumTracks: 3)
      }
      // highlight-videoTimeline-heightAdaptive
    }
  }

  /// A height that does not move as tracks are added or removed.
  private var fixedHeightConfiguration: Timeline.Configuration {
    .init { configuration in
      // highlight-videoTimeline-heightFixed
      configuration.height = { _ in .fixed(tracks: 2) }
      // highlight-videoTimeline-heightFixed
    }
  }

  @State private var isPresented = false

  var body: some View {
    Button("Use the Editor") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        editor
      }
    }
  }
}

/// A custom header item, showing what `modifyHeader` can place beside the built-in controls.
private struct MuteButton: View {
  @State private var isMuted = false

  var body: some View {
    Button { isMuted.toggle() } label: {
      Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
    }
    .buttonStyle(.plain)
    .font(.system(size: 18))
    .padding(.horizontal, 8)
    .accessibilityLabel(Text(isMuted ? "Unmute" : "Mute"))
  }
}

#Preview {
  VideoTimelineEditorSolution()
}
