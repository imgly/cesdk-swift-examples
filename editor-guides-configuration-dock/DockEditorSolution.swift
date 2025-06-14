// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
import SwiftUI

struct DockEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor
    DesignEditor(settings)
      // highlight-dockItems
      .imgly.dockItems { context in
        Dock.Buttons.elementsLibrary()
        Dock.Buttons.photoRoll()
        Dock.Buttons.systemCamera()
        Dock.Buttons.imagesLibrary()
        Dock.Buttons.textLibrary()
        Dock.Buttons.shapesLibrary()
        Dock.Buttons.stickersLibrary()
        Dock.Buttons.resize()
      }
      // highlight-dockItems
      // highlight-modifyDockItems
      .imgly.modifyDockItems { context, items in
        // highlight-addFirst
        items.addFirst {
          Dock.Button(id: "my.package.dock.button.first") { context in
            print("First Button action")
          } label: { context in
            Label("First Button", systemImage: "arrow.backward.circle")
          }
        }
        // highlight-addFirst
        // highlight-addLast
        items.addLast {
          Dock.Button(id: "my.package.dock.button.last") { context in
            print("Last Button action")
          } label: { context in
            Label("Last Button", systemImage: "arrow.forward.circle")
          }
        }
        // highlight-addLast
        // highlight-addAfter
        items.addAfter(id: Dock.Buttons.ID.photoRoll) {
          Dock.Button(id: "my.package.dock.button.afterPhotoRoll") { context in
            print("After Photo Roll action")
          } label: { context in
            Label("After Photo Roll", systemImage: "arrow.forward.square")
          }
        }
        // highlight-addAfter
        // highlight-addBefore
        items.addBefore(id: Dock.Buttons.ID.systemCamera) {
          Dock.Button(id: "my.package.dock.button.beforeSystemCamera") { context in
            print("Before Camera action")
          } label: { context in
            Label("Before Camera", systemImage: "arrow.backward.square")
          }
        }
        // highlight-addBefore
        // highlight-replace
        items.replace(id: Dock.Buttons.ID.textLibrary) {
          Dock.Button(id: "my.package.dock.button.replacedTextLibrary") { context in
            print("Replaced Text action")
          } label: { context in
            Label("Replaced Text ", systemImage: "arrow.uturn.down.square")
          }
        }
        // highlight-replace
        // highlight-remove
        items.remove(id: Dock.Buttons.ID.shapesLibrary)
      }
    // highlight-modifyDockItems
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
  DockEditorSolution()
}
