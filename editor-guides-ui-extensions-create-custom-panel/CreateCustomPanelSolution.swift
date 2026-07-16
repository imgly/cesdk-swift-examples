import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Demonstrates how to build a functional custom panel — a property editor that opens
/// from an inspector bar button, edits the selected block, and writes changes back to the scene.
///
/// The `body` uses `demoEditor`, which extends the same `GuideEditorConfiguration` as the
/// highlighted `editor` lesson and adds the minimum the showcase needs: a pre-selected
/// graphic block so the inspector bar and panel have content to edit.
struct CreateCustomPanelSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-createCustomPanel-inspectorButton
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Button(id: "open_property_panel") { context in
                let block = context.selection.block
                context.eventHandler.send(.openSheet(style: .default(), content: {
                  PropertyPanel(
                    engine: context.engine,
                    block: block,
                    eventHandler: context.eventHandler,
                  )
                }))
              } label: { _ in
                Label("Properties", systemImage: "slider.horizontal.3")
              }
            }
          }
          // highlight-createCustomPanel-inspectorButton
        }
      }
  }

  // Extends the lesson with a pre-selected block so the showcase opens with the inspector
  // bar visible. The default `onCreate` builds the 1080×1080 scene; the block is created and
  // selected in `onLoaded` because a selection set in `onCreate` is cleared by the load flow.
  private var demoEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Button(id: "open_property_panel") { context in
                let block = context.selection.block
                context.eventHandler.send(.openSheet(style: .default(), content: {
                  PropertyPanel(
                    engine: context.engine,
                    block: block,
                    eventHandler: context.eventHandler,
                  )
                }))
              } label: { _ in
                Label("Properties", systemImage: "slider.horizontal.3")
              }
            }
          }
          builder.onLoaded { context, _ in
            let engine = context.engine
            guard let page = try engine.scene.getCurrentPage() else { return }
            let banner = try engine.block.create(.graphic)
            try engine.block.setShape(banner, shape: engine.block.createShape(.rect))
            let fill = try engine.block.createFill(.color)
            try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.23, g: 0.51, b: 0.96, a: 1))
            try engine.block.setFill(banner, fill: fill)
            try engine.block.setName(banner, name: "Banner")
            try engine.block.setWidth(banner, value: 720)
            try engine.block.setHeight(banner, value: 480)
            try engine.block.setPositionX(banner, value: 180)
            try engine.block.setPositionY(banner, value: 300)
            try engine.block.appendChild(to: page, child: banner)
            try engine.block.setSelected(banner, selected: true)
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

// highlight-createCustomPanel-panelContent
struct PropertyPanel: View {
  let engine: Engine
  let block: DesignBlockID
  let eventHandler: EditorEventHandler

  @State private var name: String
  @State private var opacity: Float

  init(engine: Engine, block: DesignBlockID, eventHandler: EditorEventHandler) {
    self.engine = engine
    self.block = block
    self.eventHandler = eventHandler
    _name = State(initialValue: (try? engine.block.getName(block)) ?? "")
    _opacity = State(initialValue: (try? engine.block.getOpacity(block)) ?? 1)
  }

  var body: some View {
    NavigationStack {
      Form {
        HStack {
          Text("Name")
          Spacer()
          TextField("Block name", text: $name)
            .multilineTextAlignment(.trailing)
        }
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Text("Opacity")
            Spacer()
            Text("\(Int(opacity * 100))%")
              .foregroundStyle(.secondary)
          }
          Slider(value: $opacity, in: 0 ... 1)
        }
      }
      .navigationTitle("Properties")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          // highlight-createCustomPanel-apply
          Button("Done") {
            try? engine.block.setName(block, name: name)
            try? engine.block.setOpacity(block, value: opacity)
            eventHandler.send(.closeSheet)
          }
          // highlight-createCustomPanel-apply
        }
      }
    }
  }
}

// highlight-createCustomPanel-panelContent

#Preview {
  CreateCustomPanelSolution()
}
