import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating how to use a variable font in CE.SDK.
///
/// A variable font packs several weights into one file. CE.SDK recognizes a
/// typeface as variable when multiple `Font` entries share the same `uri`, and
/// renders each variant by applying `wght`/`ital` axis values to that one file.
struct VariableFontsSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  // highlight-variableFonts-generateVariants
  // Jost is a variable font: one file covers all weights from 100 to 900.
  static let jostVariableFontURL = URL(
    string: "https://cdn.jsdelivr.net/fontsource/fonts/jost:vf@5/latin-wght-normal.woff2",
  )!

  /// The sub-family name CE.SDK shows for each of the nine standard weights.
  static let weightSubFamilies: [(weight: FontWeight, label: String)] = [
    (.thin, "Thin"),
    (.extraLight, "Extra Light"),
    (.light, "Light"),
    (.normal, "Regular"),
    (.medium, "Medium"),
    (.semiBold, "Semi Bold"),
    (.bold, "Bold"),
    (.extraBold, "Extra Bold"),
    (.heavy, "Heavy"),
  ]

  /// Builds one `Font` entry per weight and style combination. Every entry points
  /// at the same file, which is what marks the typeface as a variable font.
  ///
  /// `Font` is qualified with its module because SwiftUI declares a type of the
  /// same name.
  static func variableFontCombinations(
    uri: URL,
    variantWeight: Bool,
    variantItalic: Bool,
  ) -> [IMGLYEngine.Font] {
    let weights = variantWeight ? weightSubFamilies : [(weight: FontWeight.normal, label: "Regular")]
    let styles: [FontStyle] = variantItalic ? [.normal, .italic] : [.normal]

    return styles.flatMap { style in
      weights.map { weight, label in
        IMGLYEngine.Font(
          uri: uri,
          subFamily: style == .italic ? "\(label) Italic" : label,
          weight: weight,
          style: style,
        )
      }
    }
  }

  static let jost = Typeface(
    name: "Jost",
    fonts: variableFontCombinations(
      uri: jostVariableFontURL,
      variantWeight: true,
      // This file has no `ital` axis, so italic entries would render upright.
      variantItalic: false,
    ),
  )
  // highlight-variableFonts-generateVariants

  // highlight-variableFonts-applyWeights
  static let weightSamples: [(weight: FontWeight, label: String)] = [
    (.thin, "Thin 100"),
    (.normal, "Regular 400"),
    (.bold, "Bold 700"),
    (.heavy, "Heavy 900"),
  ]

  /// Creates one text block per sample weight. Every block renders from the same
  /// font file, because the typeface resolves the weight to an axis value instead
  /// of another file.
  @discardableResult
  static func createWeightSamples(engine: Engine, page: DesignBlockID) throws -> [DesignBlockID] {
    try weightSamples.enumerated().map { index, sample in
      let text = try engine.block.create(.text)
      try engine.block.appendChild(to: page, child: text)
      try engine.block.replaceText(text, text: sample.label)
      try engine.block.setTextFontSize(text, fontSize: 56)
      try engine.block.setTextHorizontalAlignment(text, alignment: .center)
      try engine.block.setWidthMode(text, mode: .absolute)
      try engine.block.setWidth(text, value: 700)
      try engine.block.setHeightMode(text, mode: .auto)
      try engine.block.setPositionX(text, value: 50)
      try engine.block.setPositionY(text, value: 200 + Float(index) * 105)

      try engine.block.setTypeface(text, typeface: jost)
      try engine.block.setTextFontWeight(text, fontWeight: sample.weight)
      return text
    }
  }

  // highlight-variableFonts-applyWeights

  // highlight-variableFonts-switchWeight
  /// Switches an existing text block to another weight. The engine resolves the
  /// matching variant from the typeface and renders it from the already loaded
  /// font file.
  @discardableResult
  static func switchHeadlineWeight(engine: Engine, headline: DesignBlockID) throws -> [FontWeight] {
    try engine.block.setTextFontWeight(headline, fontWeight: .extraBold)

    // If the font file also provides an `ital` axis, styles switch the same way:
    // try engine.block.setTextFontStyle(headline, fontStyle: .italic)

    return try engine.block.getTextFontWeights(headline)
  }

  // highlight-variableFonts-switchWeight

  /// Demo scaffolding: builds the sample page and the headline the
  /// weight-switching snippet operates on. Replace this with your own scene setup.
  private static func createSampleScene(engine: Engine) throws -> (page: DesignBlockID, headline: DesignBlockID) {
    // A Pixel design unit also makes font sizes pixel-based, so the page size and
    // the font sizes below share one unit.
    let scene = try engine.scene.create(designUnit: .px)
    let page = try engine.block.create(.page)
    try engine.block.appendChild(to: scene, child: page)
    try engine.block.setWidth(page, value: 800)
    try engine.block.setHeight(page, value: 600)

    let headline = try engine.block.create(.text)
    try engine.block.appendChild(to: page, child: headline)
    try engine.block.replaceText(headline, text: "Variable Fonts")
    try engine.block.setTextFontSize(headline, fontSize: 64)
    try engine.block.setTextHorizontalAlignment(headline, alignment: .center)
    try engine.block.setWidthMode(headline, mode: .absolute)
    try engine.block.setWidth(headline, value: 700)
    try engine.block.setHeightMode(headline, mode: .auto)
    try engine.block.setPositionX(headline, value: 50)
    try engine.block.setPositionY(headline, value: 48)
    try engine.block.setTypeface(headline, typeface: jost)

    return (page, headline)
  }

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            let (page, headline) = try Self.createSampleScene(engine: engine)

            // highlight-variableFonts-registerTypeface
            // Load the bundled typeface content so the built-in typefaces stay in
            // the font library, then add the variable font to the same source.
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
                id: "jost",
                groups: ["latin"],
                payload: AssetPayload(typeface: Self.jost),
                label: ["en": "Jost"],
              ),
            )
            // highlight-variableFonts-registerTypeface

            try Self.createWeightSamples(engine: engine, page: page)
            try Self.switchHeadlineWeight(engine: engine, headline: headline)
          }

          // Select the headline after loading so the inspector bar surfaces and the
          // captured hero can open the font sheet.
          builder.onLoaded { context, _ in
            if let headline = try context.engine.block.find(byType: .text).first {
              try context.engine.block.setSelected(headline, selected: true)
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
      ModalEditor { editor }
    }
  }
}

#Preview {
  VariableFontsSolution()
}
