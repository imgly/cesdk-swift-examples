// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
import SwiftUI

struct CanvasMenuItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    DesignEditor(settings)
      // highlight-canvasMenuItems
      .imgly.canvasMenuItems { context in
        // highlight-predefinedButton
        CanvasMenu.Buttons.duplicate()

        // highlight-customizePredefinedButton
        CanvasMenu.Buttons.delete(
          // highlight-customizePredefinedButton-action
          action: { context in
            context.eventHandler.send(.deleteSelection)
          },
          // highlight-customizePredefinedButton-action
          // highlight-customizePredefinedButton-label
          label: { context in
            Label { Text("Delete") } icon: { Image.imgly.delete }
          },
          // highlight-customizePredefinedButton-label
          // highlight-customizePredefinedButton-isEnabled
          isEnabled: { context in true },
          // highlight-customizePredefinedButton-isVisible
          isVisible: { context in
            try context.engine.block.isAllowedByScope(context.selection.block, key: "lifecycle/destroy")
          },
          // highlight-customizePredefinedButton-isVisible
        )
        // highlight-customizePredefinedButton

        // highlight-newButton
        CanvasMenu.Button(
          // highlight-newButton-id
          id: "my.package.canvasMenu.button.newButton",
          // highlight-newButton-action
        ) { context in
          print("New Button action")
          // highlight-newButton-action
          // highlight-newButton-label
        } label: { context in
          Label("New Button", systemImage: "star.circle")
          // highlight-newButton-label
          // highlight-newButton-isEnabled
        } isEnabled: { context in
          true
          // highlight-newButton-isEnabled
          // highlight-newButton-isVisible
        } isVisible: { context in
          true
        }
        // highlight-newButton-isVisible
        // highlight-newButton

        // highlight-newCustomItem
        CustomCanvasMenuItem()
      }
    // highlight-canvasMenuItems
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
private struct CustomCanvasMenuItem: CanvasMenu.Item {
  // highlight-newCustomItem-id
  var id: EditorComponentID { "my.package.canvasMenu.newCustomItem" }

  // highlight-newCustomItem-body
  func body(_ context: CanvasMenu.Context) throws -> some View {
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
  func isVisible(_ context: CanvasMenu.Context) throws -> Bool {
    true
  }
  // highlight-newCustomItem-isVisible
}

// highlight-newCustomItem-conformance

#Preview {
  CanvasMenuItemEditorSolution()
}
