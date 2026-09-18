import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Demonstrates how to enable voiceover recording in a CE.SDK editor.
///
/// The MDX renders each section from `editor` via highlight markers, and `body` presents
/// the same view at runtime so the showcase screenshot captures the recording sheet.
struct RecordVoiceoverSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey, // pass nil for evaluation mode with watermark
    userID: "<your unique user id>",
  )

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-recordVoiceover-onCreate
          builder.onCreate { engine, _ in
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)
            try engine.block.setDuration(page, duration: 30)
          }
          // highlight-recordVoiceover-onCreate
          // highlight-recordVoiceover-bottomPanel
          builder.bottomPanel { bottomPanel in
            bottomPanel.content { context in
              DefaultTimelineComponent(context: context)
            }
          }
          // highlight-recordVoiceover-bottomPanel
          // highlight-recordVoiceover-dock
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.voiceover()
            }
          }
          // highlight-recordVoiceover-dock
          // highlight-recordVoiceover-inspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.addVoiceoverRecording()
            }
          }
          // highlight-recordVoiceover-inspectorBar
        }
      }
  }

  // highlight-recordVoiceover-detectKind
  @MainActor
  static func isVoiceoverBlock(_ blockID: DesignBlockID, engine: Engine) throws -> Bool {
    let type = try engine.block.getType(blockID)
    let kind = try engine.block.getKind(blockID)
    return type == DesignBlockType.audio.rawValue && kind == "voiceover"
  }

  // highlight-recordVoiceover-detectKind

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

#Preview {
  RecordVoiceoverSolution()
}
