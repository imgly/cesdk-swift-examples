import IMGLYEditor
import IMGLYEngine
import SwiftUI

struct PageFormatSolution: View {
  var settings: EngineSettings {
    EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>",
                   baseURL: secrets.baseURL) // pass nil for evaluation with the IMG.LY CDN
  }

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-pageFormat-onCreate
          builder.onCreate { engine, _ in
            // Set up a scene the editor can render
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
            try engine.block.setWidth(page, value: 1080)
            try engine.block.setHeight(page, value: 1080)

            // Register the page presets source the resize sheet reads from,
            // resolving its manifest against the engine's `basePath` (initialized
            // from `EngineSettings.baseURL`) so it follows your asset host.
            let basePath = try engine.editor.getSettingString("basePath")
            let presetsURL = URL(string: "\(basePath)/ly.img.page.presets/content.json")!
            let presetsSourceID = try await engine.asset.addLocalAssetSourceFromJSON(presetsURL)

            // Pixel preset — use .px for digital formats such as social posts
            try engine.asset.addAsset(
              to: presetsSourceID,
              asset: AssetDefinition(
                id: "brand-square-post",
                groups: ["social"],
                meta: ["thumbUri": "https://your-cdn.example.com/thumbnails/brand-square.png"],
                payload: AssetPayload(
                  transformPreset: .fixedSize(width: 1080, height: 1080, designUnit: .px),
                ),
                label: ["en": "Brand Square (1:1)"],
              ),
            )

            // Millimeter preset — use .mm for international print formats
            try engine.asset.addAsset(
              to: presetsSourceID,
              asset: AssetDefinition(
                id: "brand-din-a4",
                groups: ["print"],
                meta: ["thumbUri": "https://your-cdn.example.com/thumbnails/din-a4.png"],
                payload: AssetPayload(
                  transformPreset: .fixedSize(width: 210, height: 297, designUnit: .mm),
                ),
                label: ["en": "DIN A4 (210 × 297 mm)"],
              ),
            )

            // Inch preset — use .in for imperial print formats
            try engine.asset.addAsset(
              to: presetsSourceID,
              asset: AssetDefinition(
                id: "brand-us-letter",
                groups: ["print"],
                meta: ["thumbUri": "https://your-cdn.example.com/thumbnails/us-letter.png"],
                payload: AssetPayload(
                  transformPreset: .fixedSize(width: 8.5, height: 11, designUnit: .in),
                ),
                label: ["en": "US Letter (8.5 × 11 in)"],
              ),
            )
          }
          // highlight-pageFormat-onCreate

          // highlight-pageFormat-dock
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.resize()
            }
          }
          // highlight-pageFormat-dock
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
  PageFormatSolution()
}
