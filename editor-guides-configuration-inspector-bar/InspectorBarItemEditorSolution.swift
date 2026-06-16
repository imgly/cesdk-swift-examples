import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating the four ways to build an inspector bar item.
///
/// The `editor` view shows the lesson — what the documentation renders.
/// The `body` uses `demoEditor`, which extends the same `GuideEditorConfiguration`
/// with a pre-selected text block so the showcase opens with the inspector bar
/// visible.
struct InspectorBarItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              // highlight-inspectorBar-predefinedButton
              InspectorBar.Buttons.layer()

              // highlight-inspectorBar-customizePredefinedButton
              InspectorBar.Buttons.formatText(
                // highlight-inspectorBar-customizePredefinedButton-action
                action: { context in
                  context.eventHandler.send(.openSheet(type: .formatText()))
                },
                // highlight-inspectorBar-customizePredefinedButton-action
                // highlight-inspectorBar-customizePredefinedButton-title
                title: { _ in
                  // Rebuild the button's default localized title so styling
                  // changes keep the translated wording instead of a literal.
                  Text(.imgly.localized("ly_img_editor_inspector_bar_button_format_text"))
                    .fontWeight(.semibold)
                },
                // highlight-inspectorBar-customizePredefinedButton-title
                // highlight-inspectorBar-customizePredefinedButton-icon
                icon: { _ in Image.imgly.formatText },
                // highlight-inspectorBar-customizePredefinedButton-icon
                // highlight-inspectorBar-customizePredefinedButton-isEnabled
                isEnabled: { _ in true },
                // highlight-inspectorBar-customizePredefinedButton-isEnabled
                // highlight-inspectorBar-customizePredefinedButton-isVisible
                isVisible: { context in
                  try context.selection.type == .text &&
                    context.engine.block.isAllowedByScope(context.selection.block, key: "text/character")
                },
                // highlight-inspectorBar-customizePredefinedButton-isVisible
              )
              // highlight-inspectorBar-customizePredefinedButton

              // highlight-inspectorBar-newButton
              InspectorBar.Button(
                // highlight-inspectorBar-newButton-id
                id: "my.package.inspectorBar.button.newButton",
                // highlight-inspectorBar-newButton-action
              ) { _ in
                print("New Button action")
                // highlight-inspectorBar-newButton-action
                // highlight-inspectorBar-newButton-label
              } label: { _ in
                Label("New Button", systemImage: "star.circle")
                // highlight-inspectorBar-newButton-label
                // highlight-inspectorBar-newButton-isEnabled
              } isEnabled: { _ in
                true
                // highlight-inspectorBar-newButton-isEnabled
                // highlight-inspectorBar-newButton-isVisible
              } isVisible: { _ in
                true
              }
              // highlight-inspectorBar-newButton-isVisible
              // highlight-inspectorBar-newButton

              // highlight-inspectorBar-newCustomItem
              CustomInspectorBarItem()
            }
          }
        }
      }
  }

  // Demo scaffolding (not part of the lesson). Builds on `GuideEditorConfiguration`
  // and pre-selects a text block so the showcase opens with the inspector bar
  // visible. The default `onCreate` builds the 1080×1080 scene.
  private var demoEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.formatText()
              InspectorBar.Buttons.layer()
              InspectorBar.Buttons.duplicate()
              InspectorBar.Buttons.delete()
            }
          }
          builder.onLoaded { context, _ in
            let engine = context.engine
            guard let page = try engine.scene.getCurrentPage() else { return }
            let block = try engine.block.create(.text)
            try engine.block.replaceText(block, text: "Headline")
            try engine.block.setWidthMode(block, mode: .auto)
            try engine.block.setHeightMode(block, mode: .auto)
            try engine.block.setPositionX(block, value: 120)
            try engine.block.setPositionY(block, value: 480)
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
        demoEditor
      }
    }
  }
}

// highlight-inspectorBar-newCustomItem-conformance
private struct CustomInspectorBarItem: InspectorBar.Item {
  // highlight-inspectorBar-newCustomItem-id
  var id: EditorComponentID { "my.package.inspectorBar.newCustomItem" }

  // highlight-inspectorBar-newCustomItem-body
  func body(_: InspectorBar.Context) throws -> some View {
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

  // highlight-inspectorBar-newCustomItem-body
  // highlight-inspectorBar-newCustomItem-isVisible
  func isVisible(_: InspectorBar.Context) throws -> Bool {
    true
  }
  // highlight-inspectorBar-newCustomItem-isVisible
}

// highlight-inspectorBar-newCustomItem-conformance

#Preview {
  InspectorBarItemEditorSolution()
}
