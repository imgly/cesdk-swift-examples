import Foundation
import IMGLYEngine

// MARK: - Moderation Scanner

/// Scans a scene for video clips, images and text, and checks each one against a
/// ``VideoModerationService``.
public enum VideoModerationScanner {
  /// Checks every video clip, image and text block in the scene for inappropriate
  /// content.
  ///
  /// The service scores the whole source file of a clip. Each clip then keeps only the
  /// frames inside the part that plays, so a frame the user trimmed away does not flag
  /// the clip. A split clip, or the same file on two tracks, is checked once.
  ///
  /// Blocks the service reports it cannot check — see
  /// ``VideoModerationService/canCheck(_:)`` — are reported as unchecked instead of
  /// being silently skipped.
  @MainActor
  public static func checkContent(
    engine: Engine,
    service: VideoModerationService,
  ) async throws -> VideoModerationScanOutcome {
    // A clip whose file cannot load is reported as unchecked; it does not end the whole check.
    let clips = await loadClips(engine: engine)
    let blocks = try clips.loaded + imageBlocks(engine: engine) + textBlocks(engine: engine)

    // The service decides what it can reach: the default gateway service uploads local
    // files so they can be checked too, while a service that only fetches remote URLs
    // answers `false` for them. Anything it cannot check is reported as unchecked
    // rather than quietly treated as clean.
    let checkable = Dictionary(grouping: blocks) { service.canCheck($0.content) }
    let checkableBlocks = checkable[true] ?? []
    let uncheckedBlocks = checkable[false] ?? []

    // Images and texts first, a few at a time: a scene with many text blocks would
    // otherwise open one request per block at once and be rate-limited. Then one
    // request per video file, one after another: the gateway answers a video request
    // that overlaps any other request with "busy". Each content is checked on its own,
    // so one failure does not discard the verdicts for the others.
    let stills = Set(checkableBlocks.map(\.content).filter {
      if case .video = $0 {
        false
      } else {
        true
      }
    })
    var outcomes = await checkStills(Array(stills), service: service)
    for content in Set(checkableBlocks.map(\.content)).subtracting(stills) {
      outcomes[content] = await check(content, service: service)
    }
    try Task.checkCancellation()

    let results = checkableBlocks.flatMap { block in
      outcomes[block.content]?.frames.map { Self.results(for: block, frames: $0) } ?? []
    }
    let failedBlocks = checkableBlocks.filter { outcomes[$0.content]?.failure != nil }

    return VideoModerationScanOutcome(
      results: results,
      uncheckedBlocks: clips.unloaded + uncheckedBlocks + failedBlocks,
      failures: clips.failures + outcomes.values.compactMap(\.failure),
      authenticationFailed: outcomes.values.contains(where: \.authenticationFailed),
    )
  }

  /// The frames of one content, or why its check failed. Carries the failure as a
  /// `String` rather than an `Error` so it can cross the task group's isolation boundary.
  private struct ContentCheck: Sendable {
    var frames: [VideoModerationFrame]?
    var failure: String?
    /// Whether the check failed because the service rejected the credentials.
    var authenticationFailed = false
  }

  private static let maxConcurrentStillChecks = 4

  /// Checks images and texts with at most ``maxConcurrentStillChecks`` in flight.
  private static func checkStills(
    _ contents: [VideoModerationContent],
    service: VideoModerationService,
  ) async -> [VideoModerationContent: ContentCheck] {
    await withTaskGroup(of: (VideoModerationContent, ContentCheck).self) { group in
      var pending = contents.makeIterator()
      for _ in 0 ..< maxConcurrentStillChecks {
        guard let content = pending.next() else { break }
        group.addTask { await (content, check(content, service: service)) }
      }
      var outcomes: [VideoModerationContent: ContentCheck] = [:]
      while let (content, outcome) = await group.next() {
        outcomes[content] = outcome
        if let queued = pending.next() {
          group.addTask { await (queued, check(queued, service: service)) }
        }
      }
      return outcomes
    }
  }

  private static func check(_ content: VideoModerationContent, service: VideoModerationService) async -> ContentCheck {
    do {
      let frames = try await service.check(content)
      // An empty result is not an all-clear. The service scored nothing, so the content
      // is unknown — and a service that returns `[]` to mean "nothing detected" would
      // otherwise certify every block it never looked at.
      guard !frames.isEmpty else {
        return ContentCheck(failure: "The moderation service returned no categories.")
      }
      return ContentCheck(frames: frames)
    } catch {
      return ContentCheck(
        failure: error.localizedDescription,
        authenticationFailed: (error as? VideoModerationServiceError)?.isAuthenticationFailure ?? false,
      )
    }
  }

  /// A fingerprint of everything in the scene that gets moderated: which blocks exist,
  /// which file each clip or image shows and which part of a clip plays, and what each
  /// text block says.
  ///
  /// Compared against the fingerprint recorded at validation time to detect whether the
  /// video changed in a way that invalidates the last result. A move along the timeline
  /// changes no verdict, so it does not invalidate it.
  ///
  /// A clip whose file has not loaded has no trim to read, so it is fingerprinted by its
  /// block and file alone. Call ``loadClips(engine:)`` first for a fingerprint that
  /// matches the one taken after a check.
  @MainActor
  public static func contentFingerprint(engine: Engine) -> Set<String> {
    let clips = ((try? engine.block.find(byType: .graphic)) ?? []).compactMap { blockID in
      (try? clip(engine: engine, blockID: blockID)) ?? unloadedClip(engine: engine, blockID: blockID)
    }
    let blocks = clips + ((try? imageBlocks(engine: engine)) ?? []) + ((try? textBlocks(engine: engine)) ?? [])
    return Set(blocks.map { "\($0.blockID)|\($0.content)|\($0.played)|\($0.speed)" })
  }

  /// The video clips of a scene: the ones whose file loaded, with the part that plays,
  /// and the ones whose file could not load, with the reason.
  public struct Clips: Sendable {
    public var loaded: [VideoModerationBlock] = []
    public var unloaded: [VideoModerationBlock] = []
    public var failures: [String] = []
  }

  /// Loads the file of every graphic block in the scene that carries a video fill, and
  /// reads the part of it that plays.
  @MainActor
  public static func loadClips(engine: Engine) async -> Clips {
    var clips = Clips()
    for blockID in (try? engine.block.find(byType: .graphic)) ?? [] {
      guard let fill = videoFill(engine: engine, blockID: blockID),
            let unloaded = unloadedClip(engine: engine, blockID: blockID) else { continue }
      do {
        // The trim getters need the loaded resource.
        try await engine.block.forceLoadAVResource(fill)
        if let clip = try clip(engine: engine, blockID: blockID) {
          clips.loaded.append(clip)
        }
      } catch {
        clips.unloaded.append(unloaded)
        clips.failures.append(error.localizedDescription)
      }
    }
    return clips
  }

  /// Every graphic block in the scene that carries an image fill.
  @MainActor
  public static func imageBlocks(engine: Engine) throws -> [VideoModerationBlock] {
    try engine.block.find(byType: .graphic).compactMap { blockID in
      guard let url = imageURL(engine: engine, blockID: blockID) else { return nil }
      return VideoModerationBlock(
        blockID: blockID,
        blockName: blockName(engine: engine, blockID: blockID),
        content: .image(url),
      )
    }
  }

  /// Every text block and every caption in the scene that carries non-empty text.
  ///
  /// Blank blocks are skipped rather than sent: they cannot violate a policy, and each
  /// one would otherwise cost a request to be told so.
  @MainActor
  public static func textBlocks(engine: Engine) throws -> [VideoModerationBlock] {
    try textBlocks(engine: engine, type: .text, property: "text/text")
      + textBlocks(engine: engine, type: .caption, property: "caption/text")
  }

  @MainActor
  private static func textBlocks(
    engine: Engine,
    type: DesignBlockType,
    property: String,
  ) throws -> [VideoModerationBlock] {
    try engine.block.find(byType: type).compactMap { blockID in
      let text = (try? engine.block.getString(blockID, property: property)) ?? ""
      guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
      return VideoModerationBlock(
        blockID: blockID,
        blockName: blockName(engine: engine, blockID: blockID),
        content: .text(text),
      )
    }
  }

  /// Selects the block and moves the playhead to `clipTime` seconds after the block
  /// starts on the page.
  ///
  /// The results sheet floats over a timeline the user can still edit, so the block may
  /// already be gone or moved by the time its row is tapped. The playhead time uses the
  /// block's current place on the page.
  @MainActor
  public static func select(engine: Engine, blockID: DesignBlockID, at clipTime: TimeInterval) throws {
    guard engine.block.isValid(blockID) else { return }
    if try engine.block.isAllowedByScope(blockID, key: "editor/select") {
      for selected in engine.block.findAllSelected() {
        try engine.block.setSelected(selected, selected: false)
      }
      try engine.block.setSelected(blockID, selected: true)
    }
    guard let page = try engine.scene.getCurrentPage() else { return }
    try engine.block.setPlaybackTime(page, time: pageTimeOffset(engine: engine, blockID: blockID) + clipTime)
  }

  // MARK: - Private

  /// Keeps the frames that cover the part of the clip that plays and reports, per
  /// category, the worst state among them and the parts of the clip where it is
  /// flagged. An image or a text has a single frame and no time of its own, so its
  /// categories are reported as they are, with no flagged times.
  ///
  /// A frame stands for the time from its position to the next frame's position, so a
  /// clip shorter than the sampling interval still gets the frame that covers it. The
  /// interval is not assumed to be fixed.
  private static func results(
    for clip: VideoModerationBlock,
    frames: [VideoModerationFrame],
  ) -> [VideoModerationResult] {
    guard case .video = clip.content else {
      return frames.flatMap(\.checks).map { check in
        VideoModerationResult(
          id: "\(clip.blockID)-\(check.name)",
          blockID: clip.blockID,
          blockName: clip.blockName,
          blockDisplayName: clip.displayName,
          check: check,
          flaggedRanges: [],
        )
      }
    }
    let sorted = frames.sorted { $0.position < $1.position }
    let covering: [(range: ClosedRange<TimeInterval>, frame: VideoModerationFrame)] =
      sorted.indices.compactMap { index in
        let coverEnd = index + 1 < sorted.count ? sorted[index + 1].position : .infinity
        let start = max(sorted[index].position, clip.played.lowerBound)
        let end = min(coverEnd, clip.played.upperBound)
        return start < end ? (start ... end, sorted[index]) : nil
      }

    var names: [String] = []
    for name in covering.flatMap({ $0.frame.checks.map(\.name) }) where !names.contains(name) {
      names.append(name)
    }
    return names.compactMap { name in
      let scored = covering.compactMap { entry in
        entry.frame.checks.first { $0.name == name }.map { (range: entry.range, check: $0) }
      }
      guard let worst = scored.max(by: { $0.check.state < $1.check.state })?.check else { return nil }
      let flagged = mergeAdjacent(scored.filter { $0.check.state != .success }.map(\.range))
      return VideoModerationResult(
        id: "\(clip.blockID)-\(name)",
        blockID: clip.blockID,
        blockName: clip.blockName,
        blockDisplayName: clip.displayName,
        check: worst,
        flaggedRanges: flagged.map {
          clip.clipTime(ofSourceTime: $0.lowerBound) ... clip.clipTime(ofSourceTime: $0.upperBound)
        },
      )
    }
  }

  /// Joins ranges that touch, so three flagged frames in a row read as one range.
  private static func mergeAdjacent(_ ranges: [ClosedRange<TimeInterval>]) -> [ClosedRange<TimeInterval>] {
    var merged: [ClosedRange<TimeInterval>] = []
    for range in ranges {
      if let last = merged.last, range.lowerBound <= last.upperBound {
        merged[merged.count - 1] = last.lowerBound ... max(last.upperBound, range.upperBound)
      } else {
        merged.append(range)
      }
    }
    return merged
  }

  /// Reads a clip's file and the part of it that plays. Trim offset and length are
  /// timeline seconds, so playing at speed 2 covers twice the source.
  @MainActor
  private static func clip(engine: Engine, blockID: DesignBlockID) throws -> VideoModerationBlock? {
    guard let fill = videoFill(engine: engine, blockID: blockID),
          let url = try? engine.block.getURL(fill, property: "fill/video/fileURI") else {
      return nil
    }
    let speed = try Double(engine.block.getPlaybackSpeed(fill))
    let trimOffset = try engine.block.getTrimOffset(fill)
    let duration = try engine.block.getDuration(blockID)
    let trimLength = try engine.block.getTrimLength(fill)
    let played = min(trimLength > 0 ? trimLength : duration, duration)
    return VideoModerationBlock(
      blockID: blockID,
      blockName: blockName(engine: engine, blockID: blockID),
      content: .video(url),
      played: trimOffset * speed ... (trimOffset + played) * speed,
      speed: speed,
    )
  }

  /// A clip before its file has loaded: its block and file, with no part that plays.
  @MainActor
  private static func unloadedClip(engine: Engine, blockID: DesignBlockID) -> VideoModerationBlock? {
    guard let fill = videoFill(engine: engine, blockID: blockID),
          let url = try? engine.block.getURL(fill, property: "fill/video/fileURI") else {
      return nil
    }
    return VideoModerationBlock(
      blockID: blockID,
      blockName: blockName(engine: engine, blockID: blockID),
      content: .video(url),
    )
  }

  /// Returns the image URL for a graphic block, or `nil` when the block's fill is not an
  /// image fill.
  @MainActor
  private static func imageURL(engine: Engine, blockID: DesignBlockID) -> URL? {
    guard let fill = try? engine.block.getFill(blockID),
          (try? engine.block.getType(fill)) == FillType.image.rawValue else {
      return nil
    }
    if let url = try? engine.block.getURL(fill, property: "fill/image/imageFileURI") {
      return url
    }
    return (try? engine.block.getSourceSet(fill, property: "fill/image/sourceSet"))?.first?.uri
  }

  /// Returns the block's name, or an empty string when it has none.
  @MainActor
  private static func blockName(engine: Engine, blockID: DesignBlockID) -> String {
    (try? engine.block.getName(blockID)) ?? ""
  }

  /// Returns the block's fill when it is a video fill.
  @MainActor
  private static func videoFill(engine: Engine, blockID: DesignBlockID) -> DesignBlockID? {
    guard let fill = try? engine.block.getFill(blockID),
          (try? engine.block.getType(fill)) == FillType.video.rawValue else {
      return nil
    }
    return fill
  }

  /// The time at which the block starts on the page. A time offset is relative to the
  /// parent, so a clip inside a track adds the track's offset.
  @MainActor
  private static func pageTimeOffset(engine: Engine, blockID: DesignBlockID) throws -> TimeInterval {
    var offset: TimeInterval = 0
    var current: DesignBlockID? = blockID
    while let block = current, try engine.block.getType(block) != DesignBlockType.page.rawValue {
      offset += try engine.block.getTimeOffset(block)
      current = try engine.block.getParent(block)
    }
    return offset
  }
}
