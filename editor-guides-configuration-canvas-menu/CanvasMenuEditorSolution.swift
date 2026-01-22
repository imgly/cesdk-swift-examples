// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
import SwiftUI

struct CanvasMenuEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor
    DesignEditor(settings)
      // highlight-canvasMenu-canvasMenuItems
      .imgly.canvasMenuItems { context in
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
      .imgly.modifyCanvasMenuItems { context, items in
        // highlight-canvasMenu-modifyCanvasMenuItemsSignature
        // highlight-canvasMenu-addFirst
        items.addFirst {
          CanvasMenu.Button(id: "my.package.canvasMenu.button.first") { context in
            print("First Button action")
          } label: { context in
            Label("First Button", systemImage: "arrow.backward.circle")
          }
        }
        // highlight-canvasMenu-addFirst
        // highlight-canvasMenu-addLast
        items.addLast {
          CanvasMenu.Button(id: "my.package.canvasMenu.button.last") { context in
            print("Last Button action")
          } label: { context in
            Label("Last Button", systemImage: "arrow.forward.circle")
          }
        }
        // highlight-canvasMenu-addLast
        // highlight-canvasMenu-addAfter
        items.addAfter(id: CanvasMenu.Buttons.ID.bringForward) {
          CanvasMenu.Button(id: "my.package.canvasMenu.button.afterBringForward") { context in
            print("After Bring Forward action")
          } label: { context in
            Label("After Bring Forward", systemImage: "arrow.forward.square")
          }
        }
        // highlight-canvasMenu-addAfter
        // highlight-canvasMenu-addBefore
        items.addBefore(id: CanvasMenu.Buttons.ID.sendBackward) {
          CanvasMenu.Button(id: "my.package.canvasMenu.button.beforeSendBackward") { context in
            print("Before Send Backward action")
          } label: { context in
            Label("Before Send Backward", systemImage: "arrow.backward.square")
          }
        }
        // highlight-canvasMenu-addBefore
        // highlight-canvasMenu-replace
        items.replace(id: CanvasMenu.Buttons.ID.duplicate) {
          CanvasMenu.Button(id: "my.package.canvasMenu.button.replacedDuplicate") { context in
            print("Replaced Duplicate action")
          } label: { context in
            Label("Replaced Duplicate", systemImage: "arrow.uturn.down.square")
          }
        }
        // highlight-canvasMenu-replace
        // highlight-canvasMenu-remove
        items.remove(id: CanvasMenu.Buttons.ID.delete)
      }
    // highlight-canvasMenu-modifyCanvasMenuItems
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
