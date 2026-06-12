import IMGLYEditor
import SwiftUI

struct DefaultPanelSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              Dock.Button(id: "open_library_panel") { context in
                // highlight-open-panel
                context.eventHandler.send(
                  .openSheet(type: .libraryAdd { context.assetLibrary.elementsTab }),
                )
                // highlight-open-panel
              } label: { _ in
                Label("Open Library", systemImage: "arrow.up.circle")
              }
            }
          }
        }
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

#Preview {
  DefaultPanelSolution()
}
