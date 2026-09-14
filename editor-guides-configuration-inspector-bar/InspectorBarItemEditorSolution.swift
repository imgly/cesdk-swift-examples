// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct InspectorBarItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              // highlight-predefinedButton
              InspectorBar.Buttons.layer()

              // highlight-customizePredefinedButton
              InspectorBar.Buttons.formatText(
                // highlight-customizePredefinedButton-action
                action: { context in
                  context.eventHandler.send(.openSheet(type: .formatText()))
                },
                // highlight-customizePredefinedButton-action
                // highlight-customizePredefinedButton-title
                title: { _ in Text("Format") },
                // highlight-customizePredefinedButton-icon
                icon: { _ in Image.imgly.formatText },
                // highlight-customizePredefinedButton-isEnabled
                isEnabled: { _ in true },
                // highlight-customizePredefinedButton-isVisible
                isVisible: { context in
                  try context.selection.type == .text &&
                    context.engine.block.isAllowedByScope(context.selection.block, key: "text/character")
                },
                // highlight-customizePredefinedButton-isVisible
              )
              // highlight-customizePredefinedButton

              // highlight-newButton
              InspectorBar.Button(
                // highlight-newButton-id
                id: "my.package.inspectorBar.button.newButton",
                // highlight-newButton-action
              ) { _ in
                print("New Button action")
                // highlight-newButton-action
                // highlight-newButton-label
              } label: { _ in
                Label("New Button", systemImage: "star.circle")
                // highlight-newButton-label
                // highlight-newButton-isEnabled
              } isEnabled: { _ in
                true
                // highlight-newButton-isEnabled
                // highlight-newButton-isVisible
              } isVisible: { _ in
                true
              }
              // highlight-newButton-isVisible
              // highlight-newButton

              // highlight-newCustomItem
              CustomInspectorBarItem()
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

// highlight-newCustomItem-conformance
private struct CustomInspectorBarItem: InspectorBar.Item {
  // highlight-newCustomItem-id
  var id: EditorComponentID { "my.package.inspectorBar.newCustomItem" }

  // highlight-newCustomItem-body
  func body(_ context: InspectorBar.Context) throws -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(.conicGradient(colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red], center: .center))
      Text("New Custom Item")
        .padding(4)
    }
    .onTapGesture {
      print("New Custom Item action")
    }
  }

  // highlight-newCustomItem-body
  // highlight-newCustomItem-isVisible
  func isVisible(_ context: InspectorBar.Context) throws -> Bool {
    true
  }
  // highlight-newCustomItem-isVisible
}

// highlight-newCustomItem-conformance

#Preview {
  InspectorBarItemEditorSolution()
}
