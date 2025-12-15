import IMGLYEngine
import IMGLYPhotoEditor
import SwiftUI
@_spi(Internal) import IMGLYEditor

struct ForceCropSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey)

  var editor: some View {
    PhotoEditor(settings)
      // highlight-onLoaded
      .imgly.onLoaded { context in
        let pages = try context.engine.scene.getPages()
        if let page = pages.first {
          // highlight-preset
          // Create a custom 1:1 aspect ratio preset
          let preset = AssetDefinition(
            id: "custom-preset-1-1",
            payload: .init(
              transformPreset: .fixedAspectRatio(width: 1, height: 1),
            ),
            label: ["en": "Square"],
          )
          // highlight-preset

          // highlight-source
          // Isolate the forced preset in the source
          let sourceID = Engine.DefaultAssetSource.pagePresets.rawValue
          try context.engine.asset.removeSource(sourceID: sourceID)
          try context.engine.asset.addLocalSource(sourceID: sourceID)
          try context.engine.asset.addAsset(to: sourceID, asset: preset)
          // highlight-source

          // highlight-apply
          // Apply force crop
          context.eventHandler.send(.applyForceCrop(
            to: page,
            with: [ForceCropPreset(sourceID: sourceID, presetID: preset.id)],
            mode: .always,
          ))
          // highlight-apply
        }
        try await OnLoaded.photoEditorDefault(context)
      }
    // highlight-onLoaded
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
