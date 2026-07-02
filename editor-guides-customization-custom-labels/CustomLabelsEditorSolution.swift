// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct CustomLabelsEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-customLabels-dock
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.imagesLibrary(title: { _ in
                Text("Pictures")
              })
              Dock.Buttons.elementsLibrary(title: { _ in
                Text("Graphics")
              })
              Dock.Buttons.textLibrary(title: { _ in
                Text("Headlines")
              })
            }
          }
          // highlight-customLabels-dock
          // highlight-customLabels-inspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.duplicate(title: { _ in
                Text("Copy")
              })
              InspectorBar.Buttons.delete(title: { _ in
                Text("Remove")
              })
              InspectorBar.Buttons.crop()
            }
          }
          // highlight-customLabels-inspectorBar
          // highlight-customLabels-navigationBar
          builder.navigationBar { navigationBar in
            navigationBar.modify { _, items in
              items.replace(id: NavigationBar.Buttons.ID.undo) {
                NavigationBar.Buttons.undo(label: { context in
                  Label {
                    Text("Revert")
                  } icon: {
                    Image.imgly.undo
                  }
                  .opacity(context.state.viewMode == .preview ? 0 : 1)
                  .labelStyle(.imgly.adaptiveIconOnly)
                })
              }
            }
          }
          // highlight-customLabels-navigationBar
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
  CustomLabelsEditorSolution()
}
