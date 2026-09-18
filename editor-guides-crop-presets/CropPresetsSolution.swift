import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating how to customize the crop presets shown in the crop UI.
///
/// The `editor` view shows the lesson — what the documentation renders: an
/// inspector bar with a crop button, plus loading and extending the crop preset
/// source. The `body` uses `demoEditor`, which adds a sample image and opens the
/// crop sheet so the captured hero shows the preset strip.
struct CropPresetsSolution: View {
  var settings: EngineSettings {
    EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>",
                   baseURL: secrets.baseURL) // pass nil for evaluation with the IMG.LY CDN
  }

  // highlight-cropPresets-free
  static let unconstrained = AssetDefinition(
    id: "custom-unconstrained",
    payload: AssetPayload(transformPreset: .freeAspectRatio),
    label: ["en": "Unconstrained", "de": "Unbeschränkt"],
  )
  // highlight-cropPresets-free

  // highlight-cropPresets-fixedRatio
  static let cinemascope = AssetDefinition(
    id: "custom-cinemascope",
    payload: AssetPayload(transformPreset: .fixedAspectRatio(width: 21, height: 9)),
    label: ["en": "21:9", "de": "21:9"],
  )
  // highlight-cropPresets-fixedRatio

  // highlight-cropPresets-contentRatio
  static let matchContent = AssetDefinition(
    id: "custom-match-content",
    payload: AssetPayload(transformPreset: .contentAspectRatio),
    label: ["en": "Match Content", "de": "Inhalt"],
  )
  // highlight-cropPresets-contentRatio

  // highlight-cropPresets-fixedSize
  static func squarePost(thumbURL: URL) -> AssetDefinition {
    AssetDefinition(
      id: "custom-square-1080",
      meta: ["thumbUri": thumbURL.absoluteString],
      payload: AssetPayload(
        transformPreset: .fixedSize(width: 1080, height: 1080, designUnit: .px),
      ),
      label: ["en": "Square Post", "de": "Quadratisch"],
    )
  }

  // highlight-cropPresets-fixedSize

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-cropPresets-inspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.crop()
              InspectorBar.Buttons.delete()
            }
          }
          // highlight-cropPresets-inspectorBar

          builder.onCreate { engine, _ in
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            // highlight-cropPresets-loadDefaults
            // Resolve the crop preset `content.json` against the engine's `basePath`
            // setting (initialized from `EngineSettings.baseURL`) so it follows your
            // asset host instead of pinning a fixed version.
            let basePath = try engine.editor.getSettingString("basePath")
            let cropPresetsURL = URL(string: "\(basePath)/ly.img.crop.presets/content.json")!
            let sourceID = try await engine.asset.addLocalAssetSourceFromJSON(cropPresetsURL)
            // highlight-cropPresets-loadDefaults

            // highlight-cropPresets-addAsset
            let squareThumbURL = URL(string: "\(basePath)/ly.img.crop.presets/thumbnails/ratio-1-1.png")!
            try engine.asset.addAsset(to: sourceID, asset: Self.unconstrained)
            try engine.asset.addAsset(to: sourceID, asset: Self.cinemascope)
            try engine.asset.addAsset(to: sourceID, asset: Self.matchContent)
            try engine.asset.addAsset(to: sourceID, asset: Self.squarePost(thumbURL: squareThumbURL))
            // highlight-cropPresets-addAsset
          }
        }
      }
  }

  // Approach 2 — filter the default content.json at load time. Pass a matcher of
  // glob patterns; an asset loads if its id matches any pattern. This keeps only
  // Free, 1:1, 16:9, and 9:16 from the shipped presets.
  // highlight-cropPresets-matcher
  static func loadFilteredCropPresets(_ engine: Engine) async throws -> String {
    let basePath = try engine.editor.getSettingString("basePath")
    let cropPresetsURL = URL(string: "\(basePath)/ly.img.crop.presets/content.json")!
    return try await engine.asset.addLocalAssetSourceFromJSON(
      cropPresetsURL,
      matcher: [
        "ly.img.crop.presets.fixed-ratio.free",
        "ly.img.crop.presets.fixed-ratio.1_1",
        "ly.img.crop.presets.fixed-ratio.16_9",
        "ly.img.crop.presets.fixed-ratio.9_16",
      ],
    )
  }

  // highlight-cropPresets-matcher

  // Register an empty source under the ly.img.crop.presets ID and add only typed
  // presets — no JSON file — to replace the defaults entirely.
  // highlight-cropPresets-fromScratch
  static func registerCustomCropPresets(_ engine: Engine) throws {
    let sourceID = "ly.img.crop.presets"
    try engine.asset.addLocalSource(sourceID: sourceID)
    let basePath = try engine.editor.getSettingString("basePath")
    let squareThumbURL = URL(string: "\(basePath)/ly.img.crop.presets/thumbnails/ratio-1-1.png")!
    try engine.asset.addAsset(to: sourceID, asset: unconstrained)
    try engine.asset.addAsset(to: sourceID, asset: cinemascope)
    try engine.asset.addAsset(to: sourceID, asset: matchContent)
    try engine.asset.addAsset(to: sourceID, asset: squarePost(thumbURL: squareThumbURL))
  }

  // highlight-cropPresets-fromScratch

  // Demo scaffolding (not part of the lesson). Adds a selectable image block and
  // the same crop preset setup, then pre-selects the block so the inspector bar
  // surfaces its Crop button. The screenshot test taps that button to open the
  // crop sheet; in a real app the user selects the block and taps Crop themselves.
  private var demoEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.crop()
              InspectorBar.Buttons.delete()
            }
          }
          builder.onCreate { engine, _ in
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            let basePath = try engine.editor.getSettingString("basePath")
            let cropPresetsURL = URL(string: "\(basePath)/ly.img.crop.presets/content.json")!
            let sourceID = try await engine.asset.addLocalAssetSourceFromJSON(cropPresetsURL)
            let squareThumbURL = URL(string: "\(basePath)/ly.img.crop.presets/thumbnails/ratio-1-1.png")!
            try engine.asset.addAsset(to: sourceID, asset: Self.unconstrained)
            try engine.asset.addAsset(to: sourceID, asset: Self.cinemascope)
            try engine.asset.addAsset(to: sourceID, asset: Self.matchContent)
            try engine.asset.addAsset(to: sourceID, asset: Self.squarePost(thumbURL: squareThumbURL))
          }
          builder.onLoaded { context, _ in
            // Add an image block and select it once the editor is ready, so the
            // inspector bar surfaces its Crop button. Selecting in onLoaded (not
            // onCreate) keeps the selection after the editor finishes loading.
            let engine = context.engine
            guard let page = try engine.scene.getCurrentPage() else { return }
            let imageURL = Bundle.main.url(forResource: "sample_image", withExtension: "jpg")!
            let block = try engine.block.create(.graphic)
            try engine.block.setShape(block, shape: engine.block.createShape(.rect))
            let fill = try engine.block.createFill(.image)
            try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: imageURL)
            try engine.block.setFill(block, fill: fill)
            try engine.block.appendChild(to: page, child: block)
            try engine.block.setWidth(block, value: 1080)
            try engine.block.setHeight(block, value: 1080)
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
  CropPresetsSolution()
}
