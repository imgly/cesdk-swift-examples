import Foundation
import IMGLYEngine

/// The slideshow scene. The tracks are the single source of truth: every photo or clip is a sibling
/// on one media track, in slot order, and blends into the next through its style's transition.
///
/// Block IDs are never kept, because the engine can replace them on undo, redo or a scene reload.
/// Everything is found again through the role and slot metadata written here.
@MainActor
enum MemoriesScene {
  // MARK: - Metadata keys

  /// Slot order of a media clip.
  static let slotIndexKey = "index"
  /// Stable media item ID, so that the grid keeps its items across a reorder.
  private static let itemIDKey = "imgId"
  private static let creationDateKey = "creationDate"
  /// `"image"` or `"video"`.
  private static let mediaTypeKey = "mediaType"
  static let spacerTypeKey = "spacerType"
  private static let titleKey = "blockType"
  private static let titleValue = "title"

  /// Tagged on the slideshow tracks, so that ``findTracks(_:)`` locates them by role.
  private static let trackRoleKey = "trackRole"
  private enum TrackRole: String {
    case media, text, background
  }

  static let imageFillURI = "fill/image/imageFileURI"
  static let videoFillURI = "fill/video/fileURI"

  // MARK: - Tracks

  /// The named tracks of the slideshow. ``mediaTrack`` carries every clip and is `nil` before the
  /// first media is added. ``textTrack`` holds the title card.
  struct Tracks {
    var mediaTrack: DesignBlockID?
    var textTrack: DesignBlockID?
    var backgroundTrack: DesignBlockID?
  }

  /// Builds the slideshow scene in code: a video scene with one sized, black page.
  static func createScene(_ engine: Engine) throws -> DesignBlockID {
    let scene = try engine.scene.create()
    try engine.block.setEnum(scene, property: "scene/mode", value: "Video")
    let page = try engine.block.create(.page)
    try engine.block.setScopeEnabled(page, key: "editor/select", enabled: false)
    try engine.block.appendChild(to: scene, child: page)
    try engine.block.setWidth(page, value: MemoriesConstants.pageWidth)
    try engine.block.setHeight(page, value: MemoriesConstants.pageHeight)
    let fill = try engine.block.createFill(.color)
    try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0, g: 0, b: 0, a: 1))
    try engine.block.setFill(page, fill: fill)
    return page
  }

  /// Creates the background track with its hidden full-page backdrop, then the text track above it.
  /// The media track comes later and stacks on top. Returns the backdrop block.
  static func createBaseTracks(_ engine: Engine, page: DesignBlockID) throws -> (text: DesignBlockID,
                                                                                 backdrop: DesignBlockID) {
    let backgroundTrack = try createTrack(engine)
    let textTrack = try createTrack(engine)
    try engine.block.setMetadata(backgroundTrack, key: trackRoleKey, value: TrackRole.background.rawValue)
    try engine.block.setMetadata(textTrack, key: trackRoleKey, value: TrackRole.text.rawValue)
    try engine.block.appendChild(to: page, child: backgroundTrack)
    try engine.block.appendChild(to: page, child: textTrack)

    let backdrop = try createFullPageBlock(engine, page: page, fill: createClearFill(engine))
    try engine.block.setVisible(backdrop, visible: false)
    try engine.block.appendChild(to: backgroundTrack, child: backdrop)
    return (textTrack, backdrop)
  }

  /// Creates the full-page media track that carries every clip, offset by ``titleOffset(hasTitle:)``.
  static func createMediaTrack(_ engine: Engine, page: DesignBlockID, hasTitle: Bool) throws -> DesignBlockID {
    let track = try createTrack(engine)
    try engine.block.setMetadata(track, key: trackRoleKey, value: TrackRole.media.rawValue)
    try engine.block.appendChild(to: page, child: track)
    try engine.block.fillParent(track)
    try engine.block.setTimeOffset(track, offset: titleOffset(hasTitle: hasTitle))
    return track
  }

  /// A track spans the page, so a tap anywhere on the canvas would select it.
  static func createTrack(_ engine: Engine) throws -> DesignBlockID {
    let track = try engine.block.create(.track)
    try engine.block.setScopeEnabled(track, key: "editor/select", enabled: false)
    return track
  }

  /// Finds the slideshow tracks by their role. Returns `nil` only before the scene is built, so that
  /// media can still be added after the user removes every clip.
  static func findTracks(_ engine: Engine) throws -> Tracks? {
    var tracks = Tracks()
    // The timeline can nest tracks below other blocks, so search the scene, not the page children.
    for track in try engine.block.find(byType: .track) {
      guard try engine.block.hasMetadata(track, key: trackRoleKey) else { continue }
      switch TrackRole(rawValue: try engine.block.getMetadata(track, key: trackRoleKey)) {
      case .media: tracks.mediaTrack = track
      case .text: tracks.textTrack = track
      case .background: tracks.backgroundTrack = track
      case nil: break
      }
    }
    if tracks.mediaTrack == nil, tracks.textTrack == nil, tracks.backgroundTrack == nil {
      return nil
    }
    return tracks
  }

  /// The full-page backdrop that a style paints, the single child of the background track.
  static func backdrop(_ engine: Engine, tracks: Tracks) throws -> DesignBlockID? {
    guard let track = tracks.backgroundTrack else { return nil }
    return try engine.block.getChildren(track).first
  }

  /// The title text blocks on the text track.
  static func titleBlocks(_ engine: Engine, tracks: Tracks) throws -> [DesignBlockID] {
    guard let track = tracks.textTrack else { return [] }
    return try engine.block.getChildren(track).filter {
      try engine.block.hasMetadata($0, key: titleKey) && engine.block.getMetadata($0, key: titleKey) == titleValue
    }
  }

  static func markAsTitle(_ engine: Engine, block: DesignBlockID) throws {
    try engine.block.setMetadata(block, key: titleKey, value: titleValue)
  }

  /// Seconds the montage is pushed back so that it starts during the title card's last second.
  static func titleOffset(hasTitle: Bool) -> Double {
    hasTitle ? MemoriesConstants.titleDuration - 1 : 0
  }

  // MARK: - Clips

  /// The montage's clips in slot order, which is also the order they play.
  static func clips(_ engine: Engine, tracks: Tracks) throws -> [DesignBlockID] {
    guard let track = tracks.mediaTrack else { return [] }
    return try engine.block.getChildren(track).filter { try isClip(engine, $0) }
  }

  /// A media slot is a graphic block with a slot index and no spacer tag.
  private static func isClip(_ engine: Engine, _ block: DesignBlockID) throws -> Bool {
    try engine.block.getType(block) == DesignBlockType.graphic.rawValue
      && engine.block.hasMetadata(block, key: slotIndexKey)
      && !engine.block.hasMetadata(block, key: spacerTypeKey)
  }

  static func isVideoClip(_ engine: Engine, _ block: DesignBlockID) throws -> Bool {
    try engine.block.hasMetadata(block, key: mediaTypeKey)
      && engine.block.getMetadata(block, key: mediaTypeKey) == "video"
  }

  static func writeMetadata(_ engine: Engine, block: DesignBlockID, item: MemoriesMediaItem, index: Int) throws {
    try engine.block.setMetadata(block, key: slotIndexKey, value: "\(index)")
    try engine.block.setMetadata(block, key: itemIDKey, value: "\(item.id)")
    try engine.block.setMetadata(block, key: mediaTypeKey, value: item.isVideo ? "video" : "image")
    // A repainted slot keeps its metadata, so a missing date has to clear the previous photo's date.
    if let date = item.creationDate {
      try engine.block.setMetadata(block, key: creationDateKey, value: "\(date.timeIntervalSince1970)")
    } else if try engine.block.hasMetadata(block, key: creationDateKey) {
      try engine.block.removeMetadata(block, key: creationDateKey)
    }
  }

  /// The media URL of a slot's fill, and whether it is a video.
  static func mediaURL(_ engine: Engine, block: DesignBlockID) -> (url: URL, isVideo: Bool)? {
    guard let fill = try? engine.block.getFill(block) else { return nil }
    if let uri = try? engine.block.getString(fill, property: imageFillURI), let url = URL(string: uri) {
      return (url, false)
    }
    if let uri = try? engine.block.getString(fill, property: videoFillURI), let url = URL(string: uri) {
      return (url, true)
    }
    return nil
  }

  /// Rebuilds the editable media list from the clips on the media track.
  static func readMediaItems(_ engine: Engine, tracks: Tracks) throws -> [MemoriesMediaItem] {
    try clips(engine, tracks: tracks).enumerated().compactMap { position, block in
      guard let media = mediaURL(engine, block: block) else { return nil }
      let id = try engine.block.hasMetadata(block, key: itemIDKey)
        ? Int(engine.block.getMetadata(block, key: itemIDKey)) : nil
      let date = try engine.block.hasMetadata(block, key: creationDateKey)
        ? TimeInterval(engine.block.getMetadata(block, key: creationDateKey)).map(Date.init(timeIntervalSince1970:))
        : nil
      return MemoriesMediaItem(id: id ?? position + 1, url: media.url, creationDate: date, isVideo: media.isVideo)
    }
  }

  /// The editor trims a new soundtrack to the page, so it is stretched again whenever the montage
  /// changes length, otherwise the music ends before the slideshow. A song shorter than the page
  /// keeps its own length.
  static func fitSoundtrack(_ engine: Engine, page: DesignBlockID, duration: Double) throws {
    for audio in try engine.block.getChildren(page)
      where try engine.block.getType(audio) == DesignBlockType.audio.rawValue {
      let length = try max(duration - engine.block.getTimeOffset(audio), 0)
      let source = (try? engine.block.getAVResourceTotalDuration(audio)) ?? 0
      let available = try source > 0 ? source - engine.block.getTrimOffset(audio) : length
      try engine.block.setTrimLength(audio, length: min(length, available))
      try engine.block.setDuration(audio, duration: min(length, available))
    }
  }

  // MARK: - Blocks

  /// Every graphic block in the scene needs a fill, because the editor's timeline reads the fill of
  /// each clip and fails on a block without one.
  static func createFullPageBlock(_ engine: Engine, page: DesignBlockID, fill: DesignBlockID) throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setScopeEnabled(block, key: "editor/select", enabled: false)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setFill(block, fill: fill)
    try engine.block.setWidth(block, value: engine.block.getWidth(page))
    try engine.block.setHeight(block, value: engine.block.getHeight(page))
    return block
  }

  /// A transparent color fill for blocks that show nothing.
  static func createClearFill(_ engine: Engine) throws -> DesignBlockID {
    let fill = try engine.block.createFill(.color)
    try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0, g: 0, b: 0, a: 0))
    return fill
  }

  /// An empty full-page block that only takes up time. The title burst uses it to stagger its flashes.
  static func createSpacer(_ engine: Engine, page: DesignBlockID, duration: Double) throws -> DesignBlockID {
    let spacer = try createFullPageBlock(engine, page: page, fill: createClearFill(engine))
    try engine.block.setDuration(spacer, duration: duration)
    try engine.block.setMetadata(spacer, key: spacerTypeKey, value: "between")
    return spacer
  }
}
