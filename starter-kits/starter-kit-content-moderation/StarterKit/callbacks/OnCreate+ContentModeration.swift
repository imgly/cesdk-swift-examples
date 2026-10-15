import Foundation
import IMGLYEditor
import IMGLYEngine

// MARK: - Default OnCreate

public extension ContentModerationEditorConfiguration {
  /// The default `onCreate` handler.
  ///
  /// Runs the create phases. Moderation state is reset from `onLoaded`, which runs
  /// after the engine exists and which a host can chain to rather than replace.
  internal static var defaultOnCreateHandler: OnCreate.Handler {
    { engine, _ in
      try await defaultOnCreate()(engine)
    }
  }

  /// Default content moderation editor specific `OnCreate.Callback` implementation with solution specific settings,
  /// scene and editor creation setup.
  /// - Parameters:
  ///   - preCreateScene: Callback to do any pre scene loading tasks such as applying settings.
  ///   Defaults to `ContentModerationEditorConfiguration.defaultPreCreateScene`.
  ///   - createScene: Callback to load/create the scene and load asset sources. Defaults to
  /// `ContentModerationEditorConfiguration.defaultCreateScene`.
  ///   - loadAssetSources: Callback to load any asset sources. Defaults to
  /// `ContentModerationEditorConfiguration.defaultLoadAssetSources`.
  ///   - postCreateScene: Callback to do any post scene loading tasks. Defaults to
  ///   `ContentModerationEditorConfiguration.defaultPostCreateScene`.
  /// - Returns: A composed `OnCreate.Callback`that sequentially executes all three initialization phases.
  static func defaultOnCreate(
    preCreateScene: @escaping OnCreate.Callback = defaultPreCreateScene,
    createScene: @escaping OnCreate.Callback = defaultCreateScene,
    loadAssetSources: @escaping OnCreate.Callback = defaultLoadAssetSources,
    postCreateScene: @escaping OnCreate.Callback = defaultPostCreateScene,
  ) -> OnCreate.Callback {
    { engine in
      try await preCreateScene(engine)
      try await createScene(engine)
      try await loadAssetSources(engine)
      try await postCreateScene(engine)
    }
  }

  /// Configures engine settings before scene loading.
  ///
  /// Sets editor role, touch gestures, camera clamping, and global scopes.
  static let defaultPreCreateScene: OnCreate.Callback = { engine in
    try engine.editor.setRole("Adopter")
    try engine.editor.setSettingEnum("camera/clamping/overshootMode", value: "Center")

    let highlightColor: IMGLYEngine.Color = try engine.editor.getSettingColor("highlightColor")
    try engine.editor.setSettingColor("placeholderHighlightColor", color: highlightColor)

    try engine.editor.setSettingBool("touch/dragStartCanSelect", value: false)
    try engine.editor.setSettingEnum("touch/pinchAction", value: "Zoom")
    try engine.editor.setSettingEnum("touch/rotateAction", value: "None")

    try ([
      "appearance/adjustments", "appearance/filter", "appearance/effect",
      "appearance/blur", "appearance/shadow",
      "editor/select",
      "fill/change", "fill/changeType",
      "layer/crop", "layer/move", "layer/resize", "layer/rotate", "layer/flip",
      "layer/opacity", "layer/blendMode", "layer/visibility", "layer/clipping",
      "lifecycle/destroy", "lifecycle/duplicate",
      "stroke/change", "shape/change",
      "text/edit", "text/character",
    ]).forEach { scope in
      try engine.editor.setGlobalScope(key: scope, value: .defer)
    }
  }

  /// Loads the bundled example scene.
  ///
  /// The example scene uses remotely hosted images so the moderation service
  /// can fetch and check them, and carries two captions written to trip the text
  /// categories. Both halves of a run therefore return findings immediately,
  /// without the user having to add anything.
  static let defaultCreateScene: OnCreate.Callback = { engine in
    // highlight-starter-kit-on-create-scene
    #if SWIFT_PACKAGE
      let bundle = Bundle.module
    #else
      let bundle = Bundle(for: ContentModerationEditorConfiguration.self)
    #endif
    let sceneURL = bundle.url(forResource: "content-moderation-example", withExtension: "scene")!
    try await engine.scene.load(from: sceneURL)
    // highlight-starter-kit-on-create-scene
  }

  /// Registers all default and demo asset sources, plus text and upload sources.
  static let defaultLoadAssetSources: OnCreate.Callback = { engine in
    // highlight-starter-kit-on-load-asset-sources
    let basePath = try engine.editor.getSettingString("basePath")
    guard let baseURL = URL(string: basePath) else { return }
    let sourceIDs = [
      "ly.img.sticker", "ly.img.vector.shape", "ly.img.filter", "ly.img.color.palette",
      "ly.img.effect", "ly.img.blur", "ly.img.typeface", "ly.img.crop.presets",
      "ly.img.page.presets", "ly.img.text", "ly.img.text.styles", "ly.img.text.curves", "ly.img.text.components",
      "ly.img.image",
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

    // Required even though the dock's photo roll button is omitted: the asset
    // library still shows a Photo Roll section, and `InspectorBar.Buttons.replace()`
    // offers it, so the source has to exist. Images added this way have local URIs
    // and are uploaded to the gateway before being checked, like any other image.
    try engine.asset.addSource(PhotoRollAssetSource(engine: engine))
    // highlight-starter-kit-on-load-asset-sources
  }

  /// Configures stack layout, clears selection, and enables page carousel.
  static let defaultPostCreateScene: OnCreate.Callback = { engine in
    if let stack = try engine.block.find(byType: .stack).first {
      try engine.block.setEnum(stack, property: "stack/axis", value: "Horizontal")
    }

    try engine.block.findAllSelected().forEach {
      try engine.block.setSelected($0, selected: false)
    }

    try engine.editor.setSettingBool("features/pageCarouselEnabled", value: true)
  }
}
