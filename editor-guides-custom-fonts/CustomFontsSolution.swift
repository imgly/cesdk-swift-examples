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

  static let uploadedFontURL = URL(string: "https://fonts.gstatic.com/s/codystar/v19/FwZY7-Q1xVk-40qxOt6A.ttf")!

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

            try await Self.addFontFile(
              engine: engine,
              to: typefaceSourceID,
              fontFileURL: Self.uploadedFontURL,
            )
          }
        }
      }
  }

  // highlight-customFonts-registerFontFile
  static func addFontFile(engine: Engine, to sourceID: String, fontFileURL: URL) async throws {
    let info = try await engine.editor.getFontInfo(fontFileURI: fontFileURL.absoluteString)
    let typeface = Typeface(
      name: info.family,
      fonts: [
        Font(uri: fontFileURL, subFamily: info.subFamily, weight: info.fontWeight, style: info.style),
      ],
    )
    try engine.asset.addAsset(
      to: sourceID,
      asset: AssetDefinition(
        id: fontFileURL.absoluteString,
        payload: AssetPayload(typeface: typeface),
        label: ["en": info.family],
      ),
    )
  }

  // highlight-customFonts-registerFontFile

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

  // highlight-customFonts-fontRequest
  @MainActor
  private static func applyStoredFontRequest(
    engine: Engine,
    textBlock: DesignBlockID,
    typeface: Typeface,
    font: IMGLYEngine.Font,
    sourceID: String,
  ) async throws {
    try engine.editor.setTypefaceResolver { request in
      request.family == typeface.name ? FontResolverResult(typeface: typeface, font: font) : nil
    }
    defer { try? engine.editor.setTypefaceResolver(nil) }
    let request = FontRequest(
      family: typeface.name,
      subFamily: font.subFamily,
      weight: font.weight,
      style: font.style,
      assetSourceID: sourceID,
      assetID: "orbitron",
    )
    try engine.block.setFontRequest(textBlock, request: request)
    try await engine.block.forceLoadResources([textBlock])
    print("Stored requests: \(try engine.block.getFontRequests(textBlock))")
  }

  // highlight-customFonts-fontRequest

  // highlight-customFonts-renderDiagnostics
  @MainActor
  private static func inspectTextRendering(engine: Engine, textBlock: DesignBlockID) async throws {
    // Wait for font resources when the application needs a settled snapshot.
    try await engine.block.forceLoadResources([textBlock])
    let diagnostics = try engine.block.getTextRenderDiagnostics(textBlock)
    print("Rendered text: \(diagnostics.fontUsage.text); state: \(diagnostics.fontUsage.state)")
    for run in diagnostics.fontUsage.runs {
      print("[\(run.from), \(run.to)): \(run.requestedFontFileURI) -> \(run.actualFontFileURI ?? "unresolved"); " +
        "\(run.status); effective font size: \(run.effectiveFontSize)")
    }
    print("Missing glyph ranges: \(diagnostics.missingGlyphRanges)")
    if let layout = diagnostics.layout {
      print("Lines: \(layout.visibleLineCount)/\(layout.totalLineCount) visible, " +
        "\(layout.clippedLineCount) clipped; required height: \(layout.requiredHeight); " +
        "font scale: \(layout.fontScale); overshoot: \(layout.overshoot)")
    }
  }

  // highlight-customFonts-renderDiagnostics

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
            try await Self.addFontFile(
              engine: engine,
              to: typefaceSourceID,
              fontFileURL: Self.uploadedFontURL,
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
            try await Self.applyStoredFontRequest(
              engine: engine,
              textBlock: text,
              typeface: Self.orbitron,
              font: Self.orbitron.fonts[1],
              sourceID: typefaceSourceID,
            )
            try await Self.inspectTextRendering(engine: engine, textBlock: text)
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
