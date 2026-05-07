import IMGLYEditor
import IMGLYEngine
import UIKit

// MARK: - Default OnCreate

public extension VideoEditorConfiguration {
  /// The default `onCreate` handler.
  internal static var defaultOnCreateHandler: OnCreate.Handler {
    { engine, _ in
      try await defaultOnCreate()(engine)
    }
  }

  /// Default video editor specific `OnCreate.Callback` implementation with solution specific settings, scene
  /// and editor creation setup.
  /// - Parameters:
  ///   - preCreateScene: Callback to do any pre scene loading tasks such as applying settings.
  ///   Defaults to `VideoEditorConfiguration.defaultPreCreateScene`.
  ///   - createScene: Callback to load/create the scene and load asset sources. Defaults to
  /// `VideoEditorConfiguration.defaultCreateScene`.
  ///   - loadAssetSources: Callback to load any asset sources. Defaults to
  /// `VideoEditorConfiguration.defaultLoadAssetSources`.
  ///   - postCreateScene: Callback to do any post scene loading tasks. Defaults to
  ///   `VideoEditorConfiguration.defaultPostCreateScene`.
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
  /// Sets editor role, touch gestures, camera clamping, gizmo handles, and global scopes.
  static let defaultPreCreateScene: OnCreate.Callback = { engine in
    try engine.editor.setRole("Adopter")
    try engine.editor.setSettingEnum("camera/clamping/overshootMode", value: "Center")

    let highlightColor: IMGLYEngine.Color = try engine.editor.getSettingColor("highlightColor")
    try engine.editor.setSettingColor("placeholderHighlightColor", color: highlightColor)

    try engine.editor.setSettingBool("touch/singlePointPanning", value: false)
    try engine.editor.setSettingBool("touch/dragStartCanSelect", value: false)
    try engine.editor.setSettingEnum("touch/pinchAction", value: "Scale")

    try engine.editor.setSettingBool("controlGizmo/showMoveHandles", value: false)
    try engine.editor.setSettingBool("controlGizmo/showRotateHandles", value: false)
    try engine.editor.setSettingBool("controlGizmo/showScaleHandles", value: false)

    try engine.editor.setSettingColor(
      "page/innerBorderColor",
      color: .init(cgColor: UIColor.lightGray.withAlphaComponent(0.5).cgColor)!,
    )

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

  /// Loads the built-in empty video scene.
  static let defaultCreateScene: OnCreate.Callback = { engine in
    // highlight-starter-kit-on-create-scene
    let sceneURL = Bundle(for: VideoEditorConfiguration.self).url(forResource: "video-empty", withExtension: "scene")!
    try await engine.scene.load(from: sceneURL)
    // highlight-starter-kit-on-create-scene
  }

  /// Registers all default and demo asset sources, plus text and photo roll sources.
  static let defaultLoadAssetSources: OnCreate.Callback = { engine in
    // highlight-starter-kit-on-load-asset-sources
    let assetSources: [String: URL] = [
      Engine.DefaultAssetSource.sticker.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.vectorPath.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.filterLut.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.filterDuotone.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.colorsDefaultPalette.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.effect.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.blur.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.typeface.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.cropPresets.rawValue: Engine.assetBaseURL,
      Engine.DefaultAssetSource.pagePresets.rawValue: Engine.assetBaseURL,

      Engine.DemoAssetSource.image.rawValue: Engine.assetBaseURL,
      Engine.DemoAssetSource.video.rawValue: Engine.assetBaseURL,
      Engine.DemoAssetSource.audio.rawValue: Engine.assetBaseURL,
      Engine.DemoAssetSource.textComponents.rawValue: Engine.assetBaseURL,
    ]

    try await withThrowingTaskGroup(of: Void.self) { group in
      for assetSource in assetSources {
        group.addTask {
          try await engine.populateAssetSource(id: assetSource.key, baseURL: assetSource.value)
        }
      }
      try await group.waitForAll()
    }

    let localAssetSources: [Engine.DemoAssetSource] = [
      .imageUpload,
      .audioUpload,
      .videoUpload,
    ]

    for localAssetSource in localAssetSources {
      try engine.asset.addLocalSource(
        sourceID: localAssetSource.rawValue,
        supportedMimeTypes: localAssetSource.mimeTypes,
      )
    }

    try await engine.asset.addSource(TextAssetSource(engine: engine))
    try engine.asset.addSource(PhotoRollAssetSource(engine: engine))
    // highlight-starter-kit-on-load-asset-sources
  }

  /// No additional post-scene configuration needed for video editor.
  static let defaultPostCreateScene: OnCreate.Callback = { _ in }
}
