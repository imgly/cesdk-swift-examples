// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct IconsEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-icons-dock
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary(icon: { _ in
                Image(systemName: "square.on.circle")
              })
              Dock.Buttons.imagesLibrary(icon: { _ in
                Image(systemName: "photo.on.rectangle.angled")
              })
              Dock.Buttons.textLibrary(icon: { _ in
                Image(systemName: "character.textbox")
              })
              Dock.Buttons.shapesLibrary(icon: { _ in
                Image(systemName: "star")
              })
            }
          }
          // highlight-icons-dock
          // highlight-icons-navigationBar
          builder.navigationBar { navigationBar in
            navigationBar.modify { _, items in
              items.replace(id: NavigationBar.Buttons.ID.undo) {
                NavigationBar.Buttons.undo(label: { context in
                  Label {
                    Text("Undo")
                  } icon: {
                    Image(systemName: "arrow.counterclockwise")
                  }
                  .opacity(context.state.viewMode == .preview ? 0 : 1)
                  .labelStyle(.imgly.adaptiveIconOnly)
                })
              }
              items.replace(id: NavigationBar.Buttons.ID.redo) {
                NavigationBar.Buttons.redo(label: { context in
                  Label {
                    Text("Redo")
                  } icon: {
                    Image(systemName: "arrow.clockwise")
                  }
                  .opacity(context.state.viewMode == .preview ? 0 : 1)
                  .labelStyle(.imgly.adaptiveIconOnly)
                })
              }
            }
          }
          // highlight-icons-navigationBar
          // highlight-icons-inspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.crop(icon: { _ in
                Image(systemName: "crop")
              })
              InspectorBar.Buttons.adjustments(icon: { _ in
                Image(systemName: "slider.horizontal.3")
              })
              InspectorBar.Buttons.filter(icon: { _ in
                Image(systemName: "camera.filters")
              })
              InspectorBar.Buttons.duplicate(icon: { _ in
                Image(systemName: "plus.square.on.square")
              })
              InspectorBar.Buttons.delete(icon: { _ in
                Image(systemName: "trash")
              })
            }
          }
          // highlight-icons-inspectorBar
          // highlight-icons-customButton
          builder.dock { dock in
            dock.modify { _, items in
              items.addLast {
                Dock.Button(
                  id: EditorComponentID("my.app.dock.bookmark"),
                  action: { _ in
                    // Open a custom panel, present a sheet, etc.
                  },
                  label: { _ in
                    Label {
                      Text("Bookmark")
                    } icon: {
                      Image(systemName: "bookmark")
                    }
                  },
                )
              }
            }
          }
          // highlight-icons-customButton
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
  IconsEditorSolution()
}
