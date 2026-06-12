// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct DockItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              // highlight-dock-predefinedButton
              Dock.Buttons.elementsLibrary()
              // highlight-dock-predefinedButton

              // highlight-dock-customizeButton
              Dock.Buttons.imagesLibrary(
                action: { context in
                  context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.imagesTab }))
                },
                title: { _ in Text("Image") },
                icon: { _ in Image.imgly.addImage },
                isEnabled: { _ in true },
                isVisible: { _ in true },
              )
              // highlight-dock-customizeButton

              // highlight-dock-newButton
              Dock.Button(
                id: "my.package.dock.button.newButton",
              ) { _ in
                print("New Button action")
              } label: { _ in
                Label("New Button", systemImage: "star.circle")
              } isEnabled: { _ in
                true
              } isVisible: { _ in
                true
              }
              // highlight-dock-newButton

              // highlight-dock-customItem
              CustomDockItem()
              // highlight-dock-customItem
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

// highlight-dock-customItem-conformance
private struct CustomDockItem: Dock.Item {
  var id: EditorComponentID { "my.package.dock.newCustomItem" }

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

  func isVisible(_ context: Dock.Context) throws -> Bool {
    true
  }
}

// highlight-dock-customItem-conformance

#Preview {
  DockItemEditorSolution()
}
