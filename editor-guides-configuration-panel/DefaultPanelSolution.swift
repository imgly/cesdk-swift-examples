import IMGLYDesignEditor
import SwiftUI

struct DefaultPanelSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    DesignEditor(settings)
      .imgly.modifyDockItems { context, items in
        items.addFirst {
          Dock.Button(
            id: "custom_panel",
          ) { context in
            // highlight-open-panel
            context.eventHandler.send(
              .openSheet(
                type: .libraryAdd { context.assetLibrary.elementsTab },
              ),
            )
            // highlight-open-panel
          } label: { _ in
            Label("Open Panel", systemImage: "arrow.up.circle")
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
