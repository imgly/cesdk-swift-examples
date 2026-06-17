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
            let basePath = try engine.editor.getSettingString("basePath")
            guard let baseURL = URL(string: basePath) else { return }
            let sourceIDs = [
              "ly.img.sticker", "ly.img.vector.shape", "ly.img.filter", "ly.img.color.palette",
              "ly.img.effect", "ly.img.blur", "ly.img.typeface", "ly.img.crop.presets",
              "ly.img.page.presets", "ly.img.text.presets", "ly.img.text.components",
              "ly.img.caption.presets", "ly.img.image",
            ]
            try await withThrowingTaskGroup(of: String.self) { group in
              for id in sourceIDs {
                group.addTask {
                  try await engine.asset.addLocalAssetSourceFromJSON(
                    baseURL.appendingPathComponent(id).appendingPathComponent("content.json"),
                  )
                }
              }
              for try await _ in group {}
            }
            try engine.asset.addLocalSource(
              sourceID: "ly.img.image.upload",
              supportedMimeTypes: ["image/jpeg", "image/png", "image/svg+xml", "image/gif", "image/apng", "image/bmp"],
            )
          }

          // highlight-forceCrop-setup
          builder.onLoaded { context, existing in
            guard let page = try context.engine.scene.getCurrentPage() else { return }

            let sourceID = "ly.img.crop.presets"

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
