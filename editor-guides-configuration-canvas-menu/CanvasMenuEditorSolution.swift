// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct CanvasMenuEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.canvasMenu { canvasMenu in
            // highlight-canvasMenu-canvasMenuItems
            canvasMenu.items { _ in
              CanvasMenu.Buttons.selectGroup()
              CanvasMenu.Divider()
              CanvasMenu.Buttons.bringForward()
              CanvasMenu.Buttons.sendBackward()
              CanvasMenu.Divider()
              CanvasMenu.Buttons.duplicate()
              CanvasMenu.Buttons.delete()
            }
            // highlight-canvasMenu-canvasMenuItems
            // highlight-canvasMenu-modifyCanvasMenuItems
            // highlight-canvasMenu-modifyCanvasMenuItemsSignature
            canvasMenu.modify { _, items in
              // highlight-canvasMenu-modifyCanvasMenuItemsSignature
              // highlight-canvasMenu-addFirst
              items.addFirst {
                CanvasMenu.Button(id: "my.package.canvasMenu.button.first") { _ in
                  print("First Button action")
                } label: { _ in
                  Label("First Button", systemImage: "arrow.backward.circle")
                }
              }
              // highlight-canvasMenu-addFirst
              // highlight-canvasMenu-addLast
              items.addLast {
                CanvasMenu.Button(id: "my.package.canvasMenu.button.last") { _ in
                  print("Last Button action")
                } label: { _ in
                  Label("Last Button", systemImage: "arrow.forward.circle")
                }
              }
              // highlight-canvasMenu-addLast
              // highlight-canvasMenu-addAfter
              items.addAfter(id: CanvasMenu.Buttons.ID.bringForward) {
                CanvasMenu.Button(id: "my.package.canvasMenu.button.afterBringForward") { _ in
                  print("After Bring Forward action")
                } label: { _ in
                  Label("After Bring Forward", systemImage: "arrow.forward.square")
                }
              }
              // highlight-canvasMenu-addAfter
              // highlight-canvasMenu-addBefore
              items.addBefore(id: CanvasMenu.Buttons.ID.sendBackward) {
                CanvasMenu.Button(id: "my.package.canvasMenu.button.beforeSendBackward") { _ in
                  print("Before Send Backward action")
                } label: { _ in
                  Label("Before Send Backward", systemImage: "arrow.backward.square")
                }
              }
              // highlight-canvasMenu-addBefore
              // highlight-canvasMenu-replace
              items.replace(id: CanvasMenu.Buttons.ID.duplicate) {
                CanvasMenu.Button(id: "my.package.canvasMenu.button.replacedDuplicate") { _ in
                  print("Replaced Duplicate action")
                } label: { _ in
                  Label("Replaced Duplicate", systemImage: "arrow.uturn.down.square")
                }
              }
              // highlight-canvasMenu-replace
              // highlight-canvasMenu-remove
              items.remove(id: CanvasMenu.Buttons.ID.delete)
            }
            // highlight-canvasMenu-modifyCanvasMenuItems
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
  CanvasMenuEditorSolution()
}
