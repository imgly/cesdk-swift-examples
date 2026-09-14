// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct DockEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.dock { dock in
            // highlight-dockItems
            dock.items { _ in
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
            // highlight-modifyDockItemsSignature
            dock.modify { _, items in
              // highlight-modifyDockItemsSignature
              // highlight-addFirst
              items.addFirst {
                Dock.Button(id: "my.package.dock.button.first") { _ in
                  print("First Button action")
                } label: { _ in
                  Label("First Button", systemImage: "arrow.backward.circle")
                }
              }
              // highlight-addFirst
              // highlight-addLast
              items.addLast {
                Dock.Button(id: "my.package.dock.button.last") { _ in
                  print("Last Button action")
                } label: { _ in
                  Label("Last Button", systemImage: "arrow.forward.circle")
                }
              }
              // highlight-addLast
              // highlight-addAfter
              items.addAfter(id: Dock.Buttons.ID.photoRoll) {
                Dock.Button(id: "my.package.dock.button.afterPhotoRoll") { _ in
                  print("After Photo Roll action")
                } label: { _ in
                  Label("After Photo Roll", systemImage: "arrow.forward.square")
                }
              }
              // highlight-addAfter
              // highlight-addBefore
              items.addBefore(id: Dock.Buttons.ID.systemCamera) {
                Dock.Button(id: "my.package.dock.button.beforeSystemCamera") { _ in
                  print("Before Camera action")
                } label: { _ in
                  Label("Before Camera", systemImage: "arrow.backward.square")
                }
              }
              // highlight-addBefore
              // highlight-replace
              items.replace(id: Dock.Buttons.ID.textLibrary) {
                Dock.Button(id: "my.package.dock.button.replacedTextLibrary") { _ in
                  print("Replaced Text action")
                } label: { _ in
                  Label("Replaced Text ", systemImage: "arrow.uturn.down.square")
                }
              }
              // highlight-replace
              // highlight-remove
              items.remove(id: Dock.Buttons.ID.shapesLibrary)
            }
            // highlight-modifyDockItems
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
  DockEditorSolution()
}
