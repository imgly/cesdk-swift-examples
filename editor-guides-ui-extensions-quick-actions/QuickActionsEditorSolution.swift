import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating quick actions: one-tap buttons whose handler runs an
/// engine edit on the current selection, with no panel in between.
///
/// This example shows how to:
/// - Surface the predefined quick actions (duplicate, delete)
/// - Build a custom one-tap action that edits the selected block
/// - Combine several engine calls into a single quick action
/// - Gate an action to the block types where it applies
/// - Reuse the same action from the inspector bar
///
/// The highlighted regions are the lesson. The `onLoaded` block is demo
/// scaffolding (not part of the lesson): it creates a graphic block and selects
/// it so the canvas menu and inspector bar are visible the moment the showcase
/// opens.
struct QuickActionsEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.canvasMenu { canvasMenu in
            canvasMenu.items { _ in
              // highlight-quickActions-builtIn
              CanvasMenu.Buttons.duplicate()
              CanvasMenu.Buttons.delete()
              // highlight-quickActions-builtIn

              CanvasMenu.Divider()

              // highlight-quickActions-customAction
              CanvasMenu.Button(
                id: "my.app.quickAction.flip",
                action: { context in
                  try flipHorizontally(context.engine, context.selection.block)
                },
                label: { _ in
                  Label("Flip", systemImage: "arrow.left.and.right")
                },
                // highlight-quickActions-gating
                isVisible: { context in
                  context.selection.type == .graphic
                },
                // highlight-quickActions-gating
              )
              // highlight-quickActions-customAction

              // highlight-quickActions-compoundAction
              CanvasMenu.Button(
                id: "my.app.quickAction.resetOrientation",
                action: { context in
                  let engine = context.engine
                  let block = context.selection.block
                  try engine.block.setRotation(block, radians: 0)
                  try engine.block.setFlipHorizontal(block, flip: false)
                  try engine.editor.addUndoStep() // one step reverts both edits together
                },
                label: { _ in
                  Label("Reset", systemImage: "arrow.counterclockwise")
                },
                isVisible: { context in
                  context.selection.type == .graphic
                },
              )
              // highlight-quickActions-compoundAction
            }
          }

          // highlight-quickActions-inspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Button(
                id: "my.app.inspectorBar.quickAction.flip",
                action: { context in
                  try flipHorizontally(context.engine, context.selection.block)
                },
                label: { _ in
                  Label("Flip", systemImage: "arrow.left.and.right")
                },
                isVisible: { context in
                  context.selection.type == .graphic
                },
              )
            }
          }
          // highlight-quickActions-inspectorBar

          // Demo scaffolding (not part of the lesson): create a graphic block and
          // select it so the quick actions appear as soon as the editor loads.
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

// highlight-quickActions-sharedHelper
/// A reusable one-tap edit: mirror the selected block horizontally. Engine calls
/// run on the main actor, so the helper is annotated to match.
///
/// The handler edits the engine directly, so it commits an undo step when it
/// finishes — otherwise the change wouldn't become a discrete entry in the
/// editor's undo/redo history. The built-in quick actions do this for you.
@MainActor
private func flipHorizontally(_ engine: Engine, _ block: DesignBlockID) throws {
  try engine.block.setFlipHorizontal(block, flip: !engine.block.getFlipHorizontal(block))
  try engine.editor.addUndoStep()
}

// highlight-quickActions-sharedHelper

#Preview {
  QuickActionsEditorSolution()
}
