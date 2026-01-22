// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
import SwiftUI

struct CanvasMenuItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    DesignEditor(settings)
      .imgly.canvasMenuItems { context in
        // highlight-canvasMenu-predefinedButton
        CanvasMenu.Buttons.duplicate()

        // highlight-canvasMenu-customizePredefinedButton
        CanvasMenu.Buttons.delete(
          // highlight-canvasMenu-customizePredefinedButton-action
          action: { context in
            context.eventHandler.send(.deleteSelection)
          },
          // highlight-canvasMenu-customizePredefinedButton-action
          // highlight-canvasMenu-customizePredefinedButton-label
          label: { context in
            Label { Text("Delete") } icon: { Image.imgly.delete }
          },
          // highlight-canvasMenu-customizePredefinedButton-label
          // highlight-canvasMenu-customizePredefinedButton-isEnabled
          isEnabled: { context in true },
          // highlight-canvasMenu-customizePredefinedButton-isVisible
          isVisible: { context in
            try context.engine.block.isAllowedByScope(context.selection.block, key: "lifecycle/destroy")
          },
          // highlight-canvasMenu-customizePredefinedButton-isVisible
        )
        // highlight-canvasMenu-customizePredefinedButton

        // highlight-canvasMenu-newButton
        CanvasMenu.Button(
          // highlight-canvasMenu-newButton-id
          id: "my.package.canvasMenu.button.newButton",
          // highlight-canvasMenu-newButton-action
        ) { context in
          print("New Button action")
          // highlight-canvasMenu-newButton-action
          // highlight-canvasMenu-newButton-label
        } label: { context in
          Label("New Button", systemImage: "star.circle")
          // highlight-canvasMenu-newButton-label
          // highlight-canvasMenu-newButton-isEnabled
        } isEnabled: { context in
          true
          // highlight-canvasMenu-newButton-isEnabled
          // highlight-canvasMenu-newButton-isVisible
        } isVisible: { context in
          true
        }
        // highlight-canvasMenu-newButton-isVisible
        // highlight-canvasMenu-newButton

        // highlight-canvasMenu-newCustomItem
        CustomCanvasMenuItem()
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

// highlight-canvasMenu-newCustomItemConformance
private struct CustomCanvasMenuItem: CanvasMenu.Item {
  // highlight-canvasMenu-newCustomItem-id
  var id: EditorComponentID { "my.package.canvasMenu.newCustomItem" }

  // highlight-canvasMenu-newCustomItem-body
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

  // highlight-canvasMenu-newCustomItem-body
  // highlight-canvasMenu-newCustomItem-isVisible
  func isVisible(_ context: CanvasMenu.Context) throws -> Bool {
    true
  }
  // highlight-canvasMenu-newCustomItem-isVisible
}

// highlight-canvasMenu-newCustomItemConformance

#Preview {
  CanvasMenuItemEditorSolution()
}
