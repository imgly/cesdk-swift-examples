import IMGLYEngine
import IMGLYPhotoEditor
import SwiftUI

struct ForceCropSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  // highlight-forceCrop-customPresets
  let squarePreset = AssetDefinition(
    id: "square",
    payload: AssetPayload(
      transformPreset: .fixedAspectRatio(width: 1, height: 1),
    ),
    label: ["en": "Square (1:1)"],
  )

  let portraitPreset = AssetDefinition(
    id: "portrait",
    payload: AssetPayload(
      transformPreset: .fixedAspectRatio(width: 4, height: 5),
    ),
    label: ["en": "Portrait (4:5)"],
  )

  // highlight-forceCrop-customPresets

  // highlight-forceCrop-fixedSize
  let profilePhotoPreset = AssetDefinition(
    id: "profile-photo",
    payload: AssetPayload(
      transformPreset: .fixedSize(width: 400, height: 400, designUnit: .px),
    ),
    label: ["en": "Profile Photo (400x400)"],
  )

  // highlight-forceCrop-fixedSize

  var editor: some View {
    PhotoEditor(settings)
      // highlight-forceCrop-setup
      .imgly.onLoaded { context in
        guard let page = try context.engine.scene.getCurrentPage() else { return }

        let sourceID = Engine.DefaultAssetSource.cropPresets.rawValue

        // Replace the default crop presets source with custom presets
        try context.engine.asset.removeSource(sourceID: sourceID)
        try context.engine.asset.addLocalSource(sourceID: sourceID)

        let presets = [squarePreset, portraitPreset]
        var presetCandidates: [ForceCropPreset] = []
        for preset in presets {
          try context.engine.asset.addAsset(to: sourceID, asset: preset)
          presetCandidates.append(ForceCropPreset(sourceID: sourceID, presetID: preset.id))
        }
        // highlight-forceCrop-setup

        // highlight-forceCrop-apply
        context.eventHandler.send(.applyForceCrop(
          to: page,
          with: presetCandidates,
          mode: .always,
        ))
        // highlight-forceCrop-apply
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
  ForceCropSolution()
}
