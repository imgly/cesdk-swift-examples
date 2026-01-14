// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
import SwiftUI

struct RearrangeButtonsEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    DesignEditor(settings)
      // highlight-rearrange-navbar
      .imgly.modifyNavigationBarItems { context, items in
        // Move undo/redo to the leading position
        items.remove(id: NavigationBar.Buttons.ID.undo)
        items.remove(id: NavigationBar.Buttons.ID.redo)
        items.addFirst(placement: .topBarLeading) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
        }
      }
      // highlight-rearrange-navbar
      // highlight-rearrange-canvas-menu
      .imgly.modifyCanvasMenuItems { context, items in
        // Keep only duplicate and delete, removing layer ordering options
        items.remove(id: CanvasMenu.Buttons.ID.bringForward)
        items.remove(id: CanvasMenu.Buttons.ID.sendBackward)
        items.remove(id: CanvasMenu.Buttons.ID.selectGroup)
      }
      // highlight-rearrange-canvas-menu
      // highlight-rearrange-dock
      .imgly.modifyDockItems { context, items in
        // Move text library to the beginning for text-focused workflows
        items.remove(id: Dock.Buttons.ID.textLibrary)
        items.addFirst {
          Dock.Buttons.textLibrary()
        }
      }
      // highlight-rearrange-dock
      // highlight-rearrange-inspector-bar
      .imgly.modifyInspectorBarItems { context, items in
        // Move duplicate button to appear before layer options
        items.remove(id: InspectorBar.Buttons.ID.duplicate)
        items.addBefore(id: InspectorBar.Buttons.ID.layer) {
          InspectorBar.Buttons.duplicate()
        }
      }
    // highlight-rearrange-inspector-bar
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
