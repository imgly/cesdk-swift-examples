import IMGLYDesignEditor
import SwiftUI

struct CustomPanelSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    DesignEditor(settings)
      .imgly.modifyDockItems { context, items in
        items.addFirst {
          Dock.Button(
            id: "custom_panel",
          ) { context in
            // highlight-open-custom-panel
            context.eventHandler.send(.openSheet(
              style: .default(
                isFloating: false,
                detent: .fraction(0.7),
                detents: [.large, .fraction(0.7)],
              ),
              content: {
                VStack(spacing: 16) {
                  Text("Custom Panel")
                    .font(.headline)
                  Button("Close") {
                    // highlight-close-panel
                    context.eventHandler.send(.closeSheet)
                    // highlight-close-panel
                  }
                  .buttonStyle(.bordered)
                }
                .padding()
              },
            ))
            // highlight-open-custom-panel
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
  CustomPanelSolution()
}
