// swiftformat:disable unusedArguments
import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating the range of canvas menu items: predefined buttons,
/// customized predefined buttons, new buttons, and fully custom items.
///
/// The highlighted regions are the lesson. The `onLoaded` block is demo
/// scaffolding (not part of the lesson): it creates a graphic block and selects
/// it so the canvas menu is visible the moment the showcase opens.
struct CanvasMenuItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.canvasMenu { canvasMenu in
            canvasMenu.items { _ in
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
                label: { _ in
                  Label {
                    Text(.imgly.localized("ly_img_editor_canvas_menu_button_delete"))
                  } icon: {
                    Image.imgly.delete
                  }
                },
                // highlight-canvasMenu-customizePredefinedButton-label
                // highlight-canvasMenu-customizePredefinedButton-isEnabled
                isEnabled: { _ in true },
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
              ) { _ in
                print("New Button action")
                // highlight-canvasMenu-newButton-action
                // highlight-canvasMenu-newButton-label
              } label: { _ in
                Label("New Button", systemImage: "star.circle")
                // highlight-canvasMenu-newButton-label
                // highlight-canvasMenu-newButton-isEnabled
              } isEnabled: { _ in
                true
                // highlight-canvasMenu-newButton-isEnabled
                // highlight-canvasMenu-newButton-isVisible
              } isVisible: { _ in
                true
              }
              // highlight-canvasMenu-newButton-isVisible
              // highlight-canvasMenu-newButton

              // highlight-canvasMenu-newCustomItem
              CustomCanvasMenuItem()
            }
          }
          // Demo scaffolding (not part of the lesson): create a graphic block and
          // select it so the canvas menu appears as soon as the editor loads.
          builder.onLoaded { context, _ in
            let engine = context.engine
            guard let page = try engine.scene.getCurrentPage() else { return }
            let block = try engine.block.create(.graphic)
            try engine.block.setShape(block, shape: engine.block.createShape(.rect))
            let fill = try engine.block.createFill(.color)
            try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.96, g: 0.6, b: 0.12, a: 1))
            try engine.block.setFill(block, fill: fill)
            try engine.block.setWidth(block, value: 540)
            try engine.block.setHeight(block, value: 540)
            try engine.block.setPositionX(block, value: 270)
            try engine.block.setPositionY(block, value: 270)
            try engine.block.appendChild(to: page, child: block)
            try engine.block.setSelected(block, selected: true)
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
