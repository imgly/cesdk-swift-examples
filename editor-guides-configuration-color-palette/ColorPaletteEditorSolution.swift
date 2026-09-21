import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating how to customize the color palette.
///
/// The `editor` view shows the lesson — what the documentation renders.
/// The `body` uses `demoEditor`, which extends the same `GuideEditorConfiguration`
/// with an inspector bar and a pre-selected graphic block so the showcase can
/// navigate to a color picker that surfaces the custom palette.
struct ColorPaletteEditorSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  // highlight-palette
  static let palette: [NamedColor] = [
    .init("Blue", .imgly.blue),
    .init("Green", .imgly.green),
    .init("Yellow", .imgly.yellow),
    .init("Red", .imgly.red),
    .init("Black", .imgly.black),
    .init("White", .imgly.white),
    .init("Gray", .imgly.gray),
  ]
  // highlight-palette

  var editor: some View {
    // highlight-editor
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.colorPalette(Self.palette)
        }
      }
    // highlight-editor
  }

  // Demo scaffolding (not part of the lesson). Builds on `GuideEditorConfiguration`
  // and adds the minimum needed to reach a color picker that surfaces the palette:
  // an inspector bar item and a pre-selected graphic block. The default `onCreate`
  // builds the scene, and the default Creator role keeps all engine scopes allowed.
  private var demoEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.colorPalette(Self.palette)
          builder.inspectorBar { ib in
            ib.items { _ in
              InspectorBar.Buttons.fillStroke()
              InspectorBar.Buttons.delete()
            }
          }
          builder.onLoaded { context, _ in
            let engine = context.engine
            guard let page = try engine.scene.getCurrentPage() else { return }
            let block = try engine.block.create(.graphic)
            try engine.block.setShape(block, shape: engine.block.createShape(.rect))
            try engine.block.setFill(block, fill: engine.block.createFill(.color))
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
  ColorPaletteEditorSolution()
}
