import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Demonstrates how to enable the captions surface in a CE.SDK video editor.
///
/// The MDX renders each section from `editor` via highlight markers, and `body` presents
/// the same view at runtime so the showcase screenshot captures the Add Captions sheet.
struct AddCaptionsSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey, // pass nil for evaluation mode with watermark
    userID: "<your unique user id>",
  )

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // Demo scaffolding — not part of the lesson: open a sample video so the editor
          // starts with footage to caption.
          builder.onCreate { engine, _ in
            try await engine.scene.create(fromVideo: Self.sampleVideoURL)
          }
          // highlight-addCaptions-dock
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.captions()
            }
          }
          // highlight-addCaptions-dock
          // highlight-addCaptions-inspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.editCaptions()
              InspectorBar.Buttons.captionStyle()
              InspectorBar.Buttons.formatText()
              InspectorBar.Buttons.fillStroke()
              InspectorBar.Buttons.textBackground()
              InspectorBar.Buttons.split()
              InspectorBar.Buttons.delete()
            }
          }
          // highlight-addCaptions-inspectorBar
        }
      }
  }

  /// The video the demo opens with, so the canvas shows footage behind the captions sheet.
  private static let sampleVideoURL: URL = {
    let baseURL = secrets.baseURL
      ?? URL(string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.81.0-rc.0/assets")!
    return baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4")
  }()

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
  AddCaptionsSolution()
}
