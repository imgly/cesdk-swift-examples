import IMGLYEditor
import IMGLYEngine
import SwiftUI

@MainActor
final class UiEventsLog: ObservableObject {
  @Published var lastEvent: String = "Waiting for editor events"
}

struct UiEventsEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  @StateObject private var log = UiEventsLog()
  @State private var isPresented = false

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-uiEvents-observe
          builder.onChanged { [log] update, _, existing in
            try existing()
            let message: String = switch update {
            case let .viewMode(_, new):
              "View mode changed to \(new.editorViewMode)"
            case let .page(_, new):
              "Page index changed to \(new)"
            case let .editMode(_, new):
              "Edit mode changed to \(new)"
            case let .gestureActive(_, isActive):
              isActive ? "Canvas touch started" : "Canvas touch ended"
            }
            log.lastEvent = message
          }
          // highlight-uiEvents-observe

          // highlight-uiEvents-sendFromCallback
          builder.onLoaded { [log] context, existing in
            try await existing()
            context.eventHandler.send(.setExtraCanvasInsets(24))
            log.lastEvent = "Editor loaded"
          }
          // highlight-uiEvents-sendFromCallback

          // highlight-uiEvents-sendFromComponent
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary()
              Dock.Button(id: "app.dock.button.preview") { context in
                context.eventHandler.send(.setViewMode(.preview))
              } label: { _ in
                Label("Preview", systemImage: "eye")
              }
            }
          }
          // highlight-uiEvents-sendFromComponent
        }
      }
  }

  var body: some View {
    Button("Use the Editor") { isPresented = true }
      .fullScreenCover(isPresented: $isPresented) {
        ModalEditor {
          // highlight-uiEvents-overlay
          editor
            .safeAreaInset(edge: .top) {
              Text(log.lastEvent)
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.thinMaterial, in: Capsule())
                .padding(.top, 4)
            }
          // highlight-uiEvents-overlay
        }
      }
  }
}

#Preview {
  UiEventsEditorSolution()
}
