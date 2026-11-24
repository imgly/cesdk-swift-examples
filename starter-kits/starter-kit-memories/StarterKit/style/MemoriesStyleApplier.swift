import Foundation
import IMGLYEditor
import IMGLYEngine

/// Applies a ``MemoriesStyle`` to the scene, and serves the bundled style assets.
@MainActor
enum MemoriesStyleApplier {
  // MARK: - Style asset source

  /// The local asset source with the looping backdrops and the picker thumbnails, described by
  /// `ly.img.memories.style/content.json`. Styles refer to its assets by ID instead of file paths.
  static let sourceID = "ly.img.memories.style"

  /// Registers ``sourceID`` from the bundled `content.json`, once.
  static func registerAssetSource(_ engine: Engine) throws {
    guard !engine.asset.findAllSources().contains(sourceID) else { return }
    guard let folder = Bundle(for: MemoriesEditorConfiguration.self).url(forResource: sourceID,
                                                                         withExtension: nil) else {
      throw EditorError("The \(sourceID) folder is missing from the app bundle.")
    }
    let json = try String(contentsOf: folder.appendingPathComponent("content.json"), encoding: .utf8)
    // `{{base_url}}` in content.json names the folder above `ly.img.memories.style`, as on Android.
    let basePath = folder.deletingLastPathComponent().absoluteString
    _ = try engine.asset.addLocalAssetSourceFromJSON(json, basePath: String(basePath.dropLast()))
  }

  /// The picker thumbnail of each style, keyed by style ID. The default style has none.
  static func thumbnails(_ engine: Engine) async throws -> [String: URL] {
    let result = try await engine.asset.findAssets(sourceID: sourceID,
                                                   query: .init(query: nil, page: 0, perPage: 100))
    return result.assets.reduce(into: [:]) { thumbnails, asset in
      thumbnails[asset.id] = asset.meta?["thumbUri"].flatMap(URL.init(string:))
    }
  }

  // MARK: - Applying a style

  /// Page metadata that names the applied style, so that Undo and Redo restore it with the scene.
  private static let styleIDKey = "ly.img.memories.styleID"

  /// The ID of the style the scene carries, ``MemoriesStyles/default`` until one is applied.
  static func appliedStyleID(_ engine: Engine, page: DesignBlockID) -> String {
    guard (try? engine.block.hasMetadata(page, key: styleIDKey)) == true,
          let id = try? engine.block.getMetadata(page, key: styleIDKey) else { return MemoriesStyles.default.id }
    return id
  }

  /// Applies `style` to the whole slideshow as one undo step: filters and scales every clip, blends
  /// the clips with the style's transition, paints the backdrop and restyles the title.
  static func apply(_ style: MemoriesStyle, engine: Engine, page: DesignBlockID) async throws {
    guard let tracks = try MemoriesScene.findTracks(engine) else { return }
    let clips = try MemoriesScene.clips(engine, tracks: tracks)
    for clip in clips {
      if try engine.block.supportsEffects(clip) {
        for index in try engine.block.getEffects(clip).indices.reversed() {
          try engine.block.removeEffect(clip, index: index)
        }
        try applyEffects(style, engine: engine, block: clip)
      }
      try applyMediaScale(style, engine: engine, block: clip, page: page)
    }

    // Styles overlap their slides by different amounts, so the montage ends somewhere new.
    try MemoriesScene.wireTransitions(engine, clips: clips, transition: style.transition)
    let hasTitle = try !MemoriesScene.titleBlocks(engine, tracks: tracks).isEmpty
    let duration = try tracks.mediaTrack.map {
      try MemoriesScene.reflowedEndTime(engine, track: $0, clips: clips, hasTitle: hasTitle)
    } ?? engine.block.getDuration(page)
    try engine.block.setDuration(page, duration: duration)
    try MemoriesScene.fitSoundtrack(engine, page: page, duration: duration)

    if let backdrop = try MemoriesScene.backdrop(engine, tracks: tracks) {
      try await applyBackground(style, engine: engine, backdrop: backdrop, duration: duration)
    }
    for title in try MemoriesScene.titleBlocks(engine, tracks: tracks) {
      try await styleTitle(engine, block: title, style: style)
    }
    try engine.block.setMetadata(page, key: styleIDKey, value: style.id)
    try engine.editor.addUndoStep()
  }

  private static func applyEffects(_ style: MemoriesStyle, engine: Engine, block: DesignBlockID) throws {
    guard !style.adjustments.isEmpty else { return }
    let adjustments = try engine.block.createEffect(.adjustments)
    try engine.block.appendEffect(block, effectID: adjustments)
    for adjustment in style.adjustments {
      try engine.block.setFloat(adjustments, property: adjustment.property, value: adjustment.value)
    }
  }

  /// Sizes and centers a clip for the style's ``MemoriesStyle/mediaScale``. This sets the size and
  /// position instead of a scale transform, so it can reset the base frame first: applying a style
  /// again never compounds the scale. The Ken Burns zoom-out compensation is applied again on top.
  private static func applyMediaScale(_ style: MemoriesStyle, engine: Engine, block: DesignBlockID,
                                      page: DesignBlockID) throws {
    let pageWidth = try engine.block.getWidth(page)
    let pageHeight = try engine.block.getHeight(page)
    let scale = min(max(style.mediaScale, 0.1), 1)
    try engine.block.setWidth(block, value: pageWidth * scale)
    try engine.block.setHeight(block, value: pageHeight * scale)
    try engine.block.setPositionX(block, value: pageWidth * (1 - scale) / 2)
    try engine.block.setPositionY(block, value: pageHeight * (1 - scale) / 2)
    try MemoriesScene.prescaleForZoomOut(engine, block: block)
  }

  /// Paints the persistent backdrop: hidden, a flat color, or a muted looping clip. It is stretched to
  /// the page first, otherwise a longer montage outruns it and its tail shows the black page.
  private static func applyBackground(_ style: MemoriesStyle, engine: Engine, backdrop: DesignBlockID,
                                      duration: Double) async throws {
    try engine.block.setDuration(backdrop, duration: duration)
    switch style.background {
    case .none:
      try engine.block.setVisible(backdrop, visible: false)
    case let .solid(color):
      let fill = try ensureFill(engine, block: backdrop, type: .color)
      try engine.block.setColor(fill, property: "fill/color/value", color: color)
      try engine.block.setOpacity(backdrop, value: 1)
      try engine.block.setVisible(backdrop, visible: true)
    case let .video(assetID, opacity):
      guard let uri = try await engine.asset.fetchAsset(sourceID: sourceID, assetID: assetID)?.meta?["uri"] else {
        try engine.block.setVisible(backdrop, visible: false)
        return
      }
      let fill = try ensureFill(engine, block: backdrop, type: .video)
      // Reloading the same backdrop again costs a decode, so only a new source loads.
      if (try? engine.block.getString(fill, property: MemoriesScene.videoFillURI)) != uri {
        try engine.block.setString(fill, property: MemoriesScene.videoFillURI, value: uri)
        try await engine.block.forceLoadAVResource(fill)
      }
      let sourceDuration = (try? engine.block.getAVResourceTotalDuration(fill)) ?? 0
      try engine.block.setLooping(fill, looping: true)
      try engine.block.setMuted(fill, muted: true)
      try engine.block.setTrimOffset(fill, offset: 0)
      if sourceDuration > 0 {
        try engine.block.setTrimLength(fill, length: sourceDuration)
      }
      // The backdrop is the only block above the black page, so opacity darkens it.
      try engine.block.setOpacity(backdrop, value: min(max(opacity, 0), 1))
      try engine.block.setVisible(backdrop, visible: true)
    }
  }

  /// The block's fill when it already has `type`, otherwise a new fill of `type`. The replaced fill is
  /// destroyed, so the backdrop can switch between a color and a video without leaking.
  private static func ensureFill(_ engine: Engine, block: DesignBlockID, type: FillType) throws -> DesignBlockID {
    let existing = try? engine.block.getFill(block)
    if let existing, engine.block.isValid(existing), try engine.block.getType(existing) == type.rawValue {
      return existing
    }
    let fill = try engine.block.createFill(type)
    try engine.block.setFill(block, fill: fill)
    if let existing, engine.block.isValid(existing) {
      try engine.block.destroy(existing)
    }
    return fill
  }

  /// Sets the title's color and the style's font. A typeface missing from the asset source keeps the
  /// current font.
  static func styleTitle(_ engine: Engine, block: DesignBlockID, style: MemoriesStyle) async throws {
    try engine.block.setTextColor(block, color: style.titleColor)
    let result = try await engine.asset.findAssets(sourceID: "ly.img.typeface",
                                                   query: .init(query: style.typeface, page: 0, perPage: 100))
    guard let typeface = result.assets.first?.payload?.typeface else { return }
    let font = style.fontWeights.lazy.compactMap { weight in
      typeface.fonts.first { $0.subFamily == weight }
    }.first ?? typeface.fonts.first
    guard let font else { return }
    try engine.block.setFont(block, fontFileURL: font.uri, typeface: typeface)
  }
}
