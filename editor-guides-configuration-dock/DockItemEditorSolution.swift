// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct DockItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              // highlight-predefinedButton
              Dock.Buttons.elementsLibrary()

              // highlight-customizePredefinedButton
              Dock.Buttons.imagesLibrary(
                // highlight-customizePredefinedButton-action
                action: { context in
                  context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.imagesTab }))
                },
                // highlight-customizePredefinedButton-action
                // highlight-customizePredefinedButton-title
                title: { _ in Text("Image") },
                // highlight-customizePredefinedButton-icon
                icon: { _ in Image.imgly.addImage },
                // highlight-customizePredefinedButton-isEnabled
                isEnabled: { _ in true },
                // highlight-customizePredefinedButton-isVisible
                isVisible: { _ in true },
              )
              // highlight-customizePredefinedButton

              // highlight-newButton
              Dock.Button(
                // highlight-newButton-id
                id: "my.package.dock.button.newButton",
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
              CustomDockItem()
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
private struct CustomDockItem: Dock.Item {
  // highlight-newCustomItem-id
  var id: EditorComponentID { "my.package.dock.newCustomItem" }

  // highlight-newCustomItem-body
  func body(_ context: Dock.Context) throws -> some View {
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
  func isVisible(_ context: Dock.Context) throws -> Bool {
    true
  }
  // highlight-newCustomItem-isVisible
}

// highlight-newCustomItem-conformance

#Preview {
  DockItemEditorSolution()
}
