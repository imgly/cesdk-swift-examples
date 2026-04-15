// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct RearrangeButtonsEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          // highlight-rearrangeButtons-navbar
          builder.navigationBar { navigationBar in
            navigationBar.modify { _, items in
              // Move undo/redo to the leading position
              items.remove(id: NavigationBar.Buttons.ID.undo)
              items.remove(id: NavigationBar.Buttons.ID.redo)
              items.addFirst(placement: .topBarLeading) {
                NavigationBar.Buttons.undo()
                NavigationBar.Buttons.redo()
              }
            }
          }
          // highlight-rearrangeButtons-navbar
          // highlight-rearrangeButtons-canvasMenu
          builder.canvasMenu { canvasMenu in
            canvasMenu.modify { _, items in
              // Keep only duplicate and delete, removing layer ordering options
              items.remove(id: CanvasMenu.Buttons.ID.bringForward)
              items.remove(id: CanvasMenu.Buttons.ID.sendBackward)
              items.remove(id: CanvasMenu.Buttons.ID.selectGroup)
            }
          }
          // highlight-rearrangeButtons-canvasMenu
          // highlight-rearrangeButtons-dock
          builder.dock { dock in
            dock.modify { _, items in
              // Move text library to the beginning for text-focused workflows
              items.remove(id: Dock.Buttons.ID.textLibrary)
              items.addFirst {
                Dock.Buttons.textLibrary()
              }
            }
          }
          // highlight-rearrangeButtons-dock
          // highlight-rearrangeButtons-inspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.modify { _, items in
              // Move duplicate button to appear before layer options
              items.remove(id: InspectorBar.Buttons.ID.duplicate)
              items.addBefore(id: InspectorBar.Buttons.ID.layer) {
                InspectorBar.Buttons.duplicate()
              }
            }
          }
          // highlight-rearrangeButtons-inspectorBar
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
  RearrangeButtonsEditorSolution()
}
