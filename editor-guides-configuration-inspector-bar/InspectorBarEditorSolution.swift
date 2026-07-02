import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating how to customize the inspector bar.
///
/// The `editor` view shows the lesson — what the documentation renders.
/// The `body` uses `demoEditor`, which extends the same `GuideEditorConfiguration`
/// with a focused inspector bar and a pre-selected graphic block so the showcase
/// opens with the inspector bar visible.
struct InspectorBarEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.inspectorBar { inspectorBar in
            // highlight-inspectorBar-inspectorBarItems
            inspectorBar.items { _ in
              InspectorBar.Buttons.replace() // Page, Video, Image, Audio
              InspectorBar.Buttons.editText() // Text
              InspectorBar.Buttons.formatText() // Text
              InspectorBar.Buttons.fillStroke() // Page, Video, Image, Shape, Text
              InspectorBar.Buttons.crop() // Video, Image
              InspectorBar.Buttons.adjustments() // Video, Image
              InspectorBar.Buttons.filter() // Video, Image
              InspectorBar.Buttons.shape() // Video, Image, Shape
              InspectorBar.Buttons.layer() // Video, Image, Sticker, Shape, Text
              InspectorBar.Buttons.duplicate() // Video, Image, Sticker, Shape, Text, Audio
              InspectorBar.Buttons.delete() // Video, Image, Sticker, Shape, Text, Audio
            }
            // highlight-inspectorBar-inspectorBarItems
            // highlight-inspectorBar-modifyInspectorBarItems
            // highlight-inspectorBar-modifyInspectorBarItemsSignature
            inspectorBar.modify { _, items in
              // highlight-inspectorBar-modifyInspectorBarItemsSignature
              // highlight-inspectorBar-addFirst
              items.addFirst {
                InspectorBar.Button(id: "my.package.inspectorBar.button.first") { _ in
                  print("First Button action")
                } label: { _ in
                  Label("First Button", systemImage: "arrow.backward.circle")
                }
              }
              // highlight-inspectorBar-addFirst
              // highlight-inspectorBar-addLast
              items.addLast {
                InspectorBar.Button(id: "my.package.inspectorBar.button.last") { _ in
                  print("Last Button action")
                } label: { _ in
                  Label("Last Button", systemImage: "arrow.forward.circle")
                }
              }
              // highlight-inspectorBar-addLast
              // highlight-inspectorBar-addAfter
              items.addAfter(id: InspectorBar.Buttons.ID.layer) {
                InspectorBar.Button(id: "my.package.inspectorBar.button.afterLayer") { _ in
                  print("After Layer action")
                } label: { _ in
                  Label("After Layer", systemImage: "arrow.forward.square")
                }
              }
              // highlight-inspectorBar-addAfter
              // highlight-inspectorBar-addBefore
              items.addBefore(id: InspectorBar.Buttons.ID.crop) {
                InspectorBar.Button(id: "my.package.inspectorBar.button.beforeCrop") { _ in
                  print("Before Crop action")
                } label: { _ in
                  Label("Before Crop", systemImage: "arrow.backward.square")
                }
              }
              // highlight-inspectorBar-addBefore
              // highlight-inspectorBar-replace
              items.replace(id: InspectorBar.Buttons.ID.formatText) {
                InspectorBar.Button(id: "my.package.inspectorBar.button.replacedFormatText") { _ in
                  print("Replaced Format action")
                } label: { _ in
                  Label("Replaced Format", systemImage: "arrow.uturn.down.square")
                }
              }
              // highlight-inspectorBar-replace
              // highlight-inspectorBar-remove
              items.remove(id: InspectorBar.Buttons.ID.delete)
              // highlight-inspectorBar-remove
            }
            // highlight-inspectorBar-modifyInspectorBarItems
          }
        }
      }
  }

  // Demo scaffolding (not part of the lesson). Builds on `GuideEditorConfiguration`
  // and adds the minimum needed for the showcase to open with the inspector bar
  // visible: a focused item list and a pre-selected graphic block. The default
  // `onCreate` builds the 1080×1080 scene, and the default Creator role keeps all
  // engine scopes allowed.
  private var demoEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.fillStroke()
              InspectorBar.Buttons.shape()
              InspectorBar.Buttons.layer()
              InspectorBar.Buttons.duplicate()
              InspectorBar.Buttons.delete()
            }
          }
          builder.onLoaded { context, _ in
            let engine = context.engine
            guard let page = try engine.scene.getCurrentPage() else { return }
            let block = try engine.block.create(.graphic)
            try engine.block.setShape(block, shape: engine.block.createShape(.rect))
            let fill = try engine.block.createFill(.color)
            try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.27, g: 0.52, b: 0.96, a: 1))
            try engine.block.setFill(block, fill: fill)
            try engine.block.setWidth(block, value: 600)
            try engine.block.setHeight(block, value: 400)
            try engine.block.setPositionX(block, value: 240)
            try engine.block.setPositionY(block, value: 340)
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

#Preview {
  InspectorBarEditorSolution()
}
