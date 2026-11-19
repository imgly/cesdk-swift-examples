import Foundation
import IMGLYEngine

/// A style's blend, applied to every boundary in the montage.
///
/// A transition belongs to the **outgoing** clip and blends it into the next clip on the same track.
/// Assigning one overlaps the pair and pulls every later clip earlier, so the engine owns the timeline
/// and nothing here computes a start time. The engine also clamps the overlap to half of the shorter
/// neighbour, so a 4 s video between 8 s photos gets 2 s blends without a special case.
struct MemoriesTransition {
  /// The blend the engine draws between two clips.
  let type: TransitionType
  /// Seconds the two clips overlap, before the engine's clamp applies.
  var duration = MemoriesConstants.overlapDuration
  /// Sets the type's own properties, keyed `transition/{type}/{property}`, on a new transition block.
  var configure: @MainActor (_ engine: Engine, _ transition: DesignBlockID) throws -> Void = { _, _ in }
}

/// A clip's window on the page timeline, for the thumbnail strip.
struct MemoriesTimelineClip {
  let url: URL
  let isVideo: Bool
  let startTime: Double
  let endTime: Double
  /// The middle of the window in which this clip is alone on screen. A clip too short for such a
  /// window keeps its own midpoint, its least-blended moment.
  var clearTime: Double
}

extension MemoriesScene {
  // MARK: - Montage

  /// Lays the media out on one media track in slot order and blends each clip into the next.
  /// Returns where the montage ends in page time.
  static func createMontage(
    _ engine: Engine,
    page: DesignBlockID,
    items: [MemoriesMediaItem],
    hasTitle: Bool,
    transition: MemoriesTransition,
  ) async throws -> Double {
    let track = try createMediaTrack(engine, page: page, hasTitle: hasTitle)
    var clips: [DesignBlockID] = []
    for (index, item) in items.enumerated() {
      let clip = try await createClip(engine, page: page, item: item, index: index)
      try engine.block.appendChild(to: track, child: clip)
      clips.append(clip)
    }
    try wireTransitions(engine, clips: clips, transition: transition)
    return try reflowedEndTime(engine, track: track, clips: clips, hasTitle: hasTitle)
  }

  /// Writes the staged media back into the media track in place. It adds no undo step: the style pass
  /// that has to follow it adds one for both, so that one Undo reverts the whole edit.
  ///
  /// - A photo slot that stays a photo is repainted, which keeps its style effects and loaded fill.
  /// - Any other kept slot is rebuilt at the same index, because a video's trim cannot be repainted.
  /// - Additions are appended and surplus clips are destroyed.
  static func applyDraft(
    _ engine: Engine,
    page: DesignBlockID,
    tracks: Tracks,
    items: [MemoriesMediaItem],
    hasTitle: Bool,
    transition: MemoriesTransition,
  ) async throws {
    let track = try tracks.mediaTrack ?? createMediaTrack(engine, page: page, hasTitle: hasTitle)
    let existing = try clips(engine, tracks: tracks)

    // Destroying a clip destroys its transition, but one left on a kept clip would blend into
    // whatever ends up next to it.
    try clearTransitions(engine, clips: existing)

    var clips: [DesignBlockID] = []
    for (index, item) in items.enumerated() {
      if index < existing.count {
        let block = existing[index]
        if !item.isVideo, try !isVideoClip(engine, block) {
          try engine.block.setString(
            engine.block.getFill(block),
            property: imageFillURI,
            value: item.url.absoluteString,
          )
          try applySlideAnimation(engine, block: block)
          try writeMetadata(engine, block: block, item: item, index: index)
          clips.append(block)
        } else {
          // Destroying the old clip shifts its siblings left, so `index` is where the replacement goes.
          try engine.block.destroy(block)
          let rebuilt = try await createClip(engine, page: page, item: item, index: index)
          try engine.block.insertChild(into: track, child: rebuilt, at: index)
          clips.append(rebuilt)
        }
      } else {
        let added = try await createClip(engine, page: page, item: item, index: index)
        try engine.block.appendChild(to: track, child: added)
        clips.append(added)
      }
    }
    for block in existing.dropFirst(items.count) {
      try engine.block.destroy(block)
    }

    try engine.block.setTimeOffset(track, offset: titleOffset(hasTitle: hasTitle))
    try wireTransitions(engine, clips: clips, transition: transition)
    try engine.block.setDuration(page, duration: reflowedEndTime(engine, track: track, clips: clips,
                                                                 hasTitle: hasTitle))
  }

  // MARK: - Transitions

  /// Blends each clip into the next. `clips` must be in slot order and already on the media track.
  /// Earlier transitions are detached and destroyed first, so wiring again is safe.
  static func wireTransitions(_ engine: Engine, clips: [DesignBlockID], transition: MemoriesTransition) throws {
    try clearTransitions(engine, clips: clips)
    for outgoing in clips.dropLast() where try engine.block.supportsTransition(outgoing) {
      let block = try engine.block.createTransition(transition.type)
      try engine.block.setDuration(block, duration: transition.duration)
      try transition.configure(engine, block)
      try engine.block.setTransition(outgoing, transition: block)
    }
  }

  /// `removeTransition` only detaches, so the block stays alive until it is destroyed. Without the
  /// destroy, each style change leaks one transition per clip.
  static func clearTransitions(_ engine: Engine, clips: [DesignBlockID]) throws {
    for clip in clips {
      guard let existing = try? engine.block.getTransition(clip), engine.block.isValid(existing) else { continue }
      try engine.block.removeTransition(clip)
      try engine.block.destroy(existing)
    }
  }

  /// Where the montage ends in page time, read back after the engine applied every overlap. The
  /// overlap of a boundary depends on the clamp, so the end cannot be computed from the durations.
  /// A title keeps a 1 s tail after the last clip; an empty montage keeps one slot of page.
  static func reflowedEndTime(_ engine: Engine, track: DesignBlockID, clips: [DesignBlockID],
                              hasTitle: Bool) throws -> Double {
    guard let last = clips.last else {
      return hasTitle ? MemoriesConstants.titleDuration : MemoriesConstants.imageDuration
    }
    // Read the track's offset first: asking a track for its offset runs the reflow, so the clip
    // values are stale until it returns.
    let trackOffset = try engine.block.getTimeOffset(track)
    let end = try trackOffset + engine.block.getTimeOffset(last) + engine.block.getDuration(last)
    return end + (hasTitle ? 1 : 0)
  }

  // MARK: - Clip creation

  static func createClip(_ engine: Engine, page: DesignBlockID, item: MemoriesMediaItem,
                         index: Int) async throws -> DesignBlockID {
    item.isVideo
      ? try await createVideoClip(engine, page: page, item: item, index: index)
      : try createImageClip(engine, page: page, item: item, index: index)
  }

  private static func createImageClip(_ engine: Engine, page: DesignBlockID, item: MemoriesMediaItem,
                                      index: Int) throws -> DesignBlockID {
    let fill = try engine.block.createFill(.image)
    try engine.block.setString(fill, property: imageFillURI, value: item.url.absoluteString)
    let block = try createFullPageBlock(engine, page: page, fill: fill)
    try engine.block.setDuration(block, duration: MemoriesConstants.imageDuration)
    try applySlideAnimation(engine, block: block)
    try writeMetadata(engine, block: block, item: item, index: index)
    return block
  }

  /// A video clip without a slide animation, because a video carries its own motion. Its trim follows
  /// the source length:
  /// - Shorter than a slot: plays once at its own length, and the clip shrinks to match.
  /// - Longer than a slot: plays the middle ``MemoriesConstants/imageDuration``, where the action is.
  /// - Unknown: plays one slot from the start and loops.
  private static func createVideoClip(_ engine: Engine, page: DesignBlockID, item: MemoriesMediaItem,
                                      index: Int) async throws -> DesignBlockID {
    let slot = MemoriesConstants.imageDuration
    let fill = try engine.block.createFill(.video)
    try engine.block.setString(fill, property: videoFillURI, value: item.url.absoluteString)
    let block = try createFullPageBlock(engine, page: page, fill: fill)
    try engine.block.setDuration(block, duration: slot)

    // The video needs the loaded resource to render and to report its duration.
    try await engine.block.forceLoadAVResource(fill)
    let sourceDuration = (try? engine.block.getAVResourceTotalDuration(fill)) ?? 0

    if sourceDuration > 0, sourceDuration <= slot {
      try engine.block.setTrimOffset(fill, offset: 0)
      try engine.block.setTrimLength(fill, length: sourceDuration)
      try engine.block.setLooping(fill, looping: false)
      try engine.block.setDuration(block, duration: sourceDuration)
    } else if sourceDuration > slot {
      try engine.block.setTrimOffset(fill, offset: (sourceDuration - slot) / 2)
      try engine.block.setTrimLength(fill, length: slot)
      try engine.block.setLooping(fill, looping: false)
    } else {
      try engine.block.setTrimOffset(fill, offset: 0)
      try engine.block.setTrimLength(fill, length: slot)
      try engine.block.setLooping(fill, looping: true)
    }
    try writeMetadata(engine, block: block, item: item, index: index)
    return block
  }

  // MARK: - Slide animation

  /// Gives a photo clip a fresh slide animation from ``MemoriesAnimations/recipes``. Animations the
  /// block already owns are destroyed first, because setting a new one does not destroy the old one.
  static func applySlideAnimation(_ engine: Engine, block: DesignBlockID) throws {
    guard let recipe = MemoriesAnimations.recipes.randomElement() else { return }
    for animation in [try? engine.block.getInAnimation(block), try? engine.block.getOutAnimation(block)] {
      if let animation, engine.block.isValid(animation) {
        try engine.block.destroy(animation)
      }
    }
    let inAnimation = try recipe.makeIn(engine)
    try engine.block.setInAnimation(block, animation: inAnimation)
    try prescaleForZoomOut(engine, block: block)
    if let makeOut = recipe.makeOut {
      try engine.block.setOutAnimation(block, animation: makeOut(engine))
    }
  }

  /// A Ken Burns zoom-out must start enlarged, otherwise its pan reveals the clip's edges. An
  /// animation without the property reads as no zoom-out.
  static func prescaleForZoomOut(_ engine: Engine, block: DesignBlockID) throws {
    guard let animation = try? engine.block.getInAnimation(block), engine.block.isValid(animation),
          let zoom = try? engine.block.getFloat(animation, property: "animation/ken_burns/zoomIntensity"),
          zoom < 0 else { return }
    try engine.block.scale(block, to: 1 + abs(zoom), anchorX: 0.5, anchorY: 0.5)
  }

  // MARK: - Reading the timeline

  /// Each clip's window on the page timeline, in slot order. A clip's offset is relative to the media
  /// track, which sits at the title offset, so the two add up to page time.
  static func readTimelineClips(_ engine: Engine, tracks: Tracks) throws -> [MemoriesTimelineClip] {
    guard let track = tracks.mediaTrack else { return [] }
    let trackOffset = try engine.block.getTimeOffset(track)
    let clips: [MemoriesTimelineClip] = try clips(engine, tracks: tracks).compactMap { block in
      guard let media = mediaURL(engine, block: block) else { return nil }
      let start = try trackOffset + engine.block.getTimeOffset(block)
      let end = try start + engine.block.getDuration(block)
      return MemoriesTimelineClip(url: media.url, isVideo: media.isVideo, startTime: start, endTime: end,
                                  clearTime: (start + end) / 2)
    }
    // A clip is alone on screen only between its neighbours' overlaps. The engine clamps each
    // overlap, so the window comes from the neighbours' real windows, not the requested duration.
    return clips.indices.map { index in
      var clip = clips[index]
      let clearFrom = max(clip.startTime, index > 0 ? clips[index - 1].endTime : clip.startTime)
      let clearTo = min(clip.endTime, index + 1 < clips.count ? clips[index + 1].startTime : clip.endTime)
      if clearFrom < clearTo {
        clip.clearTime = (clearFrom + clearTo) / 2
      }
      return clip
    }
  }
}
