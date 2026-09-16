// swiftformat:disable unusedArguments
import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating how to declare and modify the canvas menu item list.
///
/// The highlighted regions are the lesson — what the documentation renders. The
/// `onLoaded` block below them is demo scaffolding (not part of the lesson): it
/// creates two graphic blocks and selects one so the canvas menu is visible the
/// moment the showcase opens. The default `onCreate` builds the 1080×1080 scene,
/// and the default Creator role keeps every engine scope allowed.
struct CanvasMenuEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
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
              // highlight-canvasMenu-remove
            }
            // highlight-canvasMenu-modifyCanvasMenuItems
          }
          // Demo scaffolding (not part of the lesson): create two graphic blocks
          // and select one so the canvas menu appears as soon as the editor loads.
          builder.onLoaded { context, _ in
            let engine = context.engine
            guard let page = try engine.scene.getCurrentPage() else { return }

            let back = try engine.block.create(.graphic)
            try engine.block.setShape(back, shape: engine.block.createShape(.rect))
            let backFill = try engine.block.createFill(.color)
            try engine.block.setColor(
              backFill,
              property: "fill/color/value",
              color: .rgba(r: 0.18, g: 0.4, b: 0.92, a: 1),
            )
            try engine.block.setFill(back, fill: backFill)
            try engine.block.setWidth(back, value: 480)
            try engine.block.setHeight(back, value: 480)
            try engine.block.setPositionX(back, value: 180)
            try engine.block.setPositionY(back, value: 200)
            try engine.block.appendChild(to: page, child: back)

            let front = try engine.block.create(.graphic)
            try engine.block.setShape(front, shape: engine.block.createShape(.rect))
            let frontFill = try engine.block.createFill(.color)
            try engine.block.setColor(
              frontFill,
              property: "fill/color/value",
              color: .rgba(r: 0.96, g: 0.6, b: 0.12, a: 1),
            )
            try engine.block.setFill(front, fill: frontFill)
            try engine.block.setWidth(front, value: 420)
            try engine.block.setHeight(front, value: 420)
            try engine.block.setPositionX(front, value: 420)
            try engine.block.setPositionY(front, value: 420)
            try engine.block.appendChild(to: page, child: front)

            try engine.block.setSelected(front, selected: true)
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
