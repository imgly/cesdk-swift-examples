import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating how to load custom typefaces into the font library.
///
/// The iOS editor reads its font library from the asset source with ID
/// `"ly.img.typeface"`. Registering a local source under that ID — and adding
/// `AssetDefinition`s whose payload carries a `Typeface` — controls exactly
/// which fonts appear in the typeface picker.
///
/// `editor` is the lesson the docs render via highlight markers. `demoEditor`
/// is the runtime view used by the showcase: it shares the same typeface
/// registration and adds a dock + inspector bar + pre-selected text block so
/// the captured hero screenshot shows representative editor chrome.
struct CustomFontsSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  // Shared typeface definition used by both the lesson and the demo editor.
  static let orbitron = Typeface(
    name: "Orbitron",
    fonts: [
      Font(
        uri: URL(
          string: "https://fonts.gstatic.com/s/orbitron/v35/yMJMMIlzdpvBhQQL_SC3X9yhF25-T1nyGy6xpg.ttf",
        )!,
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
      Font(
        uri: URL(
          string: "https://fonts.gstatic.com/s/orbitron/v35/yMJMMIlzdpvBhQQL_SC3X9yhF25-T1ny_Cmxpg.ttf",
        )!,
        subFamily: "Bold",
        weight: .bold,
        style: .normal,
      ),
    ],
  )

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            // Scaffolding: overriding onCreate replaces OnCreate.default's
            // empty design scene, so recreate it here before registering
            // asset sources.
            let scene = try engine.scene.create(designUnit: .px)
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            // highlight-customFonts-loadTypefaceSource
            let basePath = try engine.editor.getSettingString("basePath")
            guard let baseURL = URL(string: basePath) else { return }
            let typefaceSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
              baseURL
                .appendingPathComponent("ly.img.typeface")
                .appendingPathComponent("content.json"),
            )
            // highlight-customFonts-loadTypefaceSource

            // highlight-customFonts-typefaceDefinition
            let orbitron = Typeface(
              name: "Orbitron",
              fonts: [
                Font(
                  uri: URL(
                    string: "https://fonts.gstatic.com/s/orbitron/v35/yMJMMIlzdpvBhQQL_SC3X9yhF25-T1nyGy6xpg.ttf",
                  )!,
                  subFamily: "Regular",
                  weight: .normal,
                  style: .normal,
                ),
                Font(
                  uri: URL(
                    string: "https://fonts.gstatic.com/s/orbitron/v35/yMJMMIlzdpvBhQQL_SC3X9yhF25-T1ny_Cmxpg.ttf",
                  )!,
                  subFamily: "Bold",
                  weight: .bold,
                  style: .normal,
                ),
              ],
            )
            // highlight-customFonts-typefaceDefinition

            // highlight-customFonts-addAsset
            try engine.asset.addAsset(
              to: typefaceSourceID,
              asset: AssetDefinition(
                id: "orbitron",
                groups: ["latin"],
                payload: AssetPayload(typeface: orbitron),
                label: ["en": "Orbitron"],
              ),
            )
            // highlight-customFonts-addAsset
          }
        }
      }
  }

  // Programmatic apply pattern shown in the docs. Highlight-only — the
  // example value flow above wires the editor; this helper documents how to
  // apply a typeface to a text block from app code.
  // highlight-customFonts-applyProgrammatically
  static func applyTypeface(engine: Engine, textBlock: DesignBlockID, typeface: Typeface) throws {
    try engine.block.setFont(
      textBlock,
      fontFileURL: typeface.fonts[0].uri,
      typeface: typeface,
    )
  }

  // highlight-customFonts-applyProgrammatically

  // Demo scaffolding: matches `editor`'s typeface registration and adds a
  // dock, inspector bar, and pre-selected text block so the captured hero
  // displays representative editor chrome around the registered typeface.
  private var demoEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            let scene = try engine.scene.create(designUnit: .px)
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            let basePath = try engine.editor.getSettingString("basePath")
            guard let baseURL = URL(string: basePath) else { return }
            let typefaceSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
              baseURL
                .appendingPathComponent("ly.img.typeface")
                .appendingPathComponent("content.json"),
            )
            try engine.asset.addAsset(
              to: typefaceSourceID,
              asset: AssetDefinition(
                id: "orbitron",
                groups: ["latin"],
                payload: AssetPayload(typeface: Self.orbitron),
                label: ["en": "Orbitron"],
              ),
            )

            // Pre-create a text block and apply Orbitron Bold so the hero
            // shows the registered typeface rendered on canvas.
            let text = try engine.block.create(.text)
            try engine.block.appendChild(to: page, child: text)
            try engine.block.replaceText(text, text: "Orbitron")
            try engine.block.setWidth(text, value: 600)
            try engine.block.setHeightMode(text, mode: .auto)
            try engine.block.setPositionX(text, value: 240)
            try engine.block.setPositionY(text, value: 460)
            try engine.block.setTextFontSize(text, fontSize: 64)
            try engine.block.setFont(
              text,
              fontFileURL: Self.orbitron.fonts[1].uri,
              typeface: Self.orbitron,
            )
          }

          // Select the text block after the editor has loaded so the inspector
          // bar surfaces immediately in the captured hero.
          builder.onLoaded { context, _ in
            if let text = try context.engine.block.find(byType: .text).first {
              try context.engine.block.setSelected(text, selected: true)
            }
          }

          builder.inspectorBar { inspector in
            inspector.items { _ in
              InspectorBar.Buttons.formatText()
            }
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
      ModalEditor { demoEditor }
    }
  }
}

#Preview {
  CustomFontsSolution()
}
