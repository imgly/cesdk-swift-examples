import Foundation
import IMGLYEditor
import IMGLYEngine

// MARK: - OnCreate

extension MemoriesEditorConfiguration {
  /// Builds the slideshow scene from the media and title on the selection screen.
  static func onCreateHandler(model: MemoriesModel) -> OnCreate.Handler {
    { engine, _ in
      // highlight-starter-kit-on-create-scene
      try lockCanvas(engine)
      let page = try MemoriesScene.createScene(engine)
      try await loadAssetSources(engine)
      try MemoriesStyleApplier.registerAssetSource(engine)
      await model.attach(engine)

      // Without this, restoring a snapshot (Undo) flattens the slideshow: the engine strips the
      // foreground tracks and moves their clips to the page. It must be set after the scene exists.
      try engine.editor.setSettingBool("features/removeForegroundTracksOnSceneLoad", value: false)

      let (textTrack, backdrop) = try MemoriesScene.createBaseTracks(engine, page: page)
      let items = model.picker.items
      let hasTitle = try await MemoriesScene.createTitle(engine, title: model.title, textTrack: textTrack)
      if hasTitle {
        try await MemoriesScene.createBurst(engine, page: page, items: items)
      }

      // A style chosen later blends the clips again, so nothing here assumes a particular overlap.
      let duration = try await MemoriesScene.createMontage(engine, page: page, items: items, hasTitle: hasTitle,
                                                           transition: MemoriesStyles.default.transition)
      try engine.block.setDuration(page, duration: duration)
      try engine.block.setDuration(backdrop, duration: duration)
      if let backgroundTrack = try engine.block.getParent(backdrop) {
        try engine.block.fillParent(backgroundTrack)
      }
      try engine.block.fillParent(textTrack)
      // highlight-starter-kit-on-create-scene
    }
  }

  /// The slideshow is edited through the dock and the timeline strip, so the canvas selects no block
  /// and does not pan, zoom or rotate.
  private static func lockCanvas(_ engine: Engine) throws {
    // The Creator role ignores block scopes, so the slideshow blocks stay selectable without Adopter.
    try engine.editor.setRole("Adopter")
    try engine.editor.setGlobalScope(key: "editor/select", value: .defer)
    try engine.editor.setSettingBool("touch/singlePointPanning", value: false)
    try engine.editor.setSettingEnum("touch/pinchAction", value: "None")
    try engine.editor.setSettingEnum("touch/rotateAction", value: "None")
  }

  /// Registers the typefaces that the styles use for the title, and the audio library with its
  /// upload source. Add the sources of any other library you open from the dock.
  private static func loadAssetSources(_ engine: Engine) async throws {
    // highlight-starter-kit-on-load-asset-sources
    let basePath = try engine.editor.getSettingString("basePath")
    guard let baseURL = URL(string: basePath) else { return }
    for id in ["ly.img.typeface", "ly.img.audio"] {
      _ = try await engine.asset.addLocalAssetSourceFromJSON(
        baseURL.appendingPathComponent(id).appendingPathComponent("content.json"),
      )
    }
    try engine.asset.addLocalSource(
      sourceID: "ly.img.audio.upload",
      supportedMimeTypes: ["audio/mpeg", "audio/mp4", "audio/wav", "audio/x-wav", "audio/aac"],
    )
    // highlight-starter-kit-on-load-asset-sources
  }
}
