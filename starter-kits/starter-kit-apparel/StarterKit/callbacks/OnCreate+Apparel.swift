import CoreGraphics
import Foundation
import IMGLYEditor
import IMGLYEngine

// MARK: - Default OnCreate

public extension ApparelEditorConfiguration {
  /// The default `onCreate` handler.
  internal static var defaultOnCreateHandler: OnCreate.Handler {
    { engine, _ in
      try await defaultOnCreate()(engine)
    }
  }

  /// Default apparel editor specific `OnCreate.Callback` implementation with solution specific settings, scene
  /// and editor creation setup.
  /// - Parameters:
  ///   - preCreateScene: Callback to do any pre scene loading tasks such as applying settings.
  ///   Defaults to `ApparelEditorConfiguration.defaultPreCreateScene`.
  ///   - createScene: Callback to load/create the scene and load asset sources. Defaults to
  /// `ApparelEditorConfiguration.defaultCreateScene`.
  ///   - loadAssetSources: Callback to load any asset sources. Defaults to
  /// `ApparelEditorConfiguration.defaultLoadAssetSources`.
  ///   - postCreateScene: Callback to do any post scene loading tasks. Defaults to
  ///   `ApparelEditorConfiguration.defaultPostCreateScene`.
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

  /// Loads the built-in empty apparel scene.
  static let defaultCreateScene: OnCreate.Callback = { engine in
    // highlight-starter-kit-on-create-scene
    let sceneURL = Bundle(for: ApparelEditorConfiguration.self).url(
      forResource: "apparel-ui-b-empty",
      withExtension: "scene",
    )!
    try await engine.scene.load(from: sceneURL)
    // highlight-starter-kit-on-create-scene
  }

  /// Registers all default and demo asset sources, plus text and photo roll sources.
  static let defaultLoadAssetSources: OnCreate.Callback = { engine in
    // highlight-starter-kit-on-load-asset-sources
    let basePath = try engine.editor.getSettingString("basePath")
    guard let baseURL = URL(string: basePath) else { return }
    let sourceIDs = [
      "ly.img.sticker", "ly.img.vector.shape", "ly.img.filter", "ly.img.color.palette",
      "ly.img.effect", "ly.img.blur", "ly.img.typeface", "ly.img.crop.presets",
      "ly.img.page.presets", "ly.img.text", "ly.img.text.components",
      "ly.img.caption.presets",
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

    try await engine.asset.addSource(TextAssetSource(engine: engine))
    try engine.asset.addSource(PhotoRollAssetSource(engine: engine))
    // highlight-starter-kit-on-load-asset-sources
  }

  /// Configures apparel-specific outline and page clipping behavior.
  static let defaultPostCreateScene: OnCreate.Callback = { engine in
    guard let scene = try engine.block.find(byType: .scene).first,
          let page = try engine.scene.getPages().first
    else {
      return
    }

    // Add outline block for apparel shape visualization.
    _ = try ApparelEditorConfiguration.addOutline(
      "always-on-top-page-outline", for: page, to: scene, engine: engine,
    )
    try ApparelEditorConfiguration.showOutline(false, engine: engine)

    // Temporarily enable scopes to configure page clipping.
    let isFillChangeEnabled = try engine.block.isScopeEnabled(page, key: "fill/change")
    let isLayerClippingEnabled = try engine.block.isScopeEnabled(page, key: "layer/clipping")
    try engine.block.setScopeEnabled(page, key: "fill/change", enabled: true)
    try engine.block.setScopeEnabled(page, key: "layer/clipping", enabled: true)

    // Configure page appearance and clipping for apparel editing.
    try engine.editor.setSettingBool("page/dimOutOfPageAreas", value: false)
    try engine.block.setClipped(page, clipped: true)
    try engine.block.setBool(page, property: "fill/enabled", value: false)
    try ApparelEditorConfiguration.showOutline(false, engine: engine)

    // Restore original scope states.
    try engine.block.setScopeEnabled(page, key: "fill/change", enabled: isFillChangeEnabled)
    try engine.block.setScopeEnabled(page, key: "layer/clipping", enabled: isLayerClippingEnabled)
  }

  // MARK: - Helpers

  /// Adds an outline block for apparel shape visualization.
  internal static func addOutline(
    _ name: String? = nil,
    for id: DesignBlockID,
    to parent: DesignBlockID,
    engine: Engine,
  ) throws -> DesignBlockID {
    let outline = try engine.block.create(.graphic)
    let rect = try engine.block.createShape(.rect)
    try engine.block.setShape(outline, shape: rect)

    let height = try engine.block.getHeight(id)
    let width = try engine.block.getWidth(id)

    if let name {
      try engine.block.setName(outline, name: name)
    }
    try engine.block.setHeightMode(outline, mode: .absolute)
    try engine.block.setHeight(outline, value: height)
    try engine.block.setWidthMode(outline, mode: .absolute)
    try engine.block.setWidth(outline, value: width)
    try engine.block.appendChild(to: parent, child: outline)

    try engine.block.setBool(outline, property: "fill/enabled", value: false)
    try engine.block.setBool(outline, property: "stroke/enabled", value: true)
    try engine.block.setStrokeStyle(outline, style: .dotted)
    try engine.block.setStrokeWidth(outline, width: 1.0)
    try engine.block.setBlendMode(outline, mode: .difference)
    try engine.block.setScopeEnabled(outline, key: "editor/select", enabled: false)
    if let color = Color(cgColor: CGColor.imgly.white) {
      try engine.block.setColor(outline, property: "stroke/color", color: color)
    }
    return outline
  }

  /// Shows or hides the outline block.
  internal static func showOutline(_ isVisible: Bool, engine: Engine) throws {
    guard let outline = engine.block.find(byName: "always-on-top-page-outline").first else {
      throw EditorError("No outline block was found.")
    }
    try engine.block.setVisible(outline, visible: isVisible)
    // Workaround: Trigger opacity to force refresh on "fast" devices.
    try engine.block.setOpacity(outline, value: isVisible ? 1 : 0)
  }
}
