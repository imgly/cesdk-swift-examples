import IMGLYEditor
import IMGLYEngine
import SwiftUI

// CE.SDK Guide: Force Crop
//
// This example demonstrates how to enforce specific aspect ratios
// on design blocks using the force crop API.

// MARK: - Solution View

struct ForceCropSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  // highlight-forceCrop-editor
  var body: some View {
    Editor(settings)
      .imgly.configuration {
        EditorConfiguration { builder in
          builder.onCreate { engine, _ in
            let imageURL = Bundle.main.url(forResource: "sample_image", withExtension: "jpg")!
            try await engine.scene.create(fromImage: imageURL)
            try await engine.addDefaultAssetSources(baseURL: Engine.assetBaseURL)
            try await engine.addDemoAssetSources(withUploadAssetSources: true)
          }

          // highlight-forceCrop-setup
          builder.onLoaded { context, existing in
            guard let page = try context.engine.scene.getCurrentPage() else { return }

            let sourceID = Engine.DefaultAssetSource.cropPresets.rawValue

            // highlight-forceCrop-apply
            context.eventHandler.send(.applyForceCrop(
              to: page,
              with: [
                ForceCropPreset(sourceID: sourceID, presetID: "aspect-ratio-1-1"),
                ForceCropPreset(sourceID: sourceID, presetID: "aspect-ratio-16-9"),
                ForceCropPreset(sourceID: sourceID, presetID: "aspect-ratio-9-16"),
              ],
              mode: .ifNeeded,
            ))
            // highlight-forceCrop-apply

            try await existing()
          }
          // highlight-forceCrop-setup
        }
      }
  }
  // highlight-forceCrop-editor
}

// MARK: - Preview

#Preview {
  ForceCropSolution()
}
