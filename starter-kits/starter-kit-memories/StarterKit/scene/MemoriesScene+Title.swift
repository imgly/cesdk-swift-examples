import Foundation
import IMGLYEngine

extension MemoriesScene {
  /// Creates the centered title card with a blur in and out. Returns whether a title was added.
  static func createTitle(_ engine: Engine, title: String, textTrack: DesignBlockID) async throws -> Bool {
    guard !title.isEmpty else { return false }
    let text = try engine.block.create(.text)
    try engine.block.setScopeEnabled(text, key: "editor/select", enabled: false)
    try engine.block.replaceText(text, text: title)
    try engine.block.setDuration(text, duration: MemoriesConstants.titleDuration)
    try engine.block.setTextFontSize(text, fontSize: MemoriesConstants.titleFontSize)
    try markAsTitle(engine, block: text)
    try await MemoriesStyleApplier.styleTitle(engine, block: text, style: MemoriesStyles.default)

    try engine.block.setInAnimation(text, animation: blurAnimation(engine, duration: 0.8))
    try engine.block.setOutAnimation(text, animation: blurAnimation(engine, duration: 0.6))
    try engine.block.appendChild(to: textTrack, child: text)
    try engine.block.setEnum(text, property: "text/horizontalAlignment", value: "Center")
    try engine.block.setEnum(text, property: "text/verticalAlignment", value: "Center")
    return true
  }

  private static func blurAnimation(_ engine: Engine, duration: Double) throws -> DesignBlockID {
    let animation = try engine.block.createAnimation(.blur)
    try engine.block.setDuration(animation, duration: duration)
    try engine.block.setEnum(animation, property: "textAnimationWritingStyle", value: "Character")
    return animation
  }

  /// Flashes random photos behind the title, each on its own track. An image fill cannot show a video,
  /// so a picked video flashes its middle frame instead, or is skipped when no frame decodes.
  static func createBurst(_ engine: Engine, page: DesignBlockID, items: [MemoriesMediaItem]) async throws {
    guard !items.isEmpty else { return }
    let count = MemoriesConstants.burstImageCount
    let shuffled = items.shuffled()
    let picks = (0 ..< count).map { shuffled[$0 % shuffled.count] }
    var urls: [URL] = []
    for item in picks {
      if !item.isVideo {
        urls.append(item.url)
      } else if let frame = await MemoriesThumbnails.videoFrameFile(for: item.url) {
        urls.append(frame)
      }
    }

    let flashDuration = MemoriesConstants.titleDuration * MemoriesConstants.burstTitleFraction / 6
    let pageWidth = try engine.block.getWidth(page)
    let pageHeight = try engine.block.getHeight(page)
    let size = min(pageWidth, pageHeight) * 0.6

    for (index, url) in urls.enumerated() {
      let track = try createTrack(engine)
      try engine.block.appendChild(to: page, child: track)

      let block = try engine.block.create(.graphic)
      try engine.block.setScopeEnabled(block, key: "editor/select", enabled: false)
      try engine.block.setWidth(block, value: size)
      try engine.block.setHeight(block, value: size)
      try engine.block.setPositionX(block, value: .random(in: -size / 2 ... pageWidth - size / 2))
      try engine.block.setPositionY(block, value: .random(in: -size / 2 ... pageHeight - size / 2))
      let fill = try engine.block.createFill(.image)
      try engine.block.setFill(block, fill: fill)
      try engine.block.setString(fill, property: imageFillURI, value: url.absoluteString)
      try engine.block.setShape(block, shape: engine.block.createShape(.rect))
      try engine.block.setDuration(block, duration: flashDuration)
      try engine.block.setInAnimation(block, animation: fadeAnimation(engine, duration: 0.1))
      try engine.block.setOutAnimation(block, animation: fadeAnimation(engine, duration: 0.15))

      let startDelay = Double(index) * flashDuration * 0.25
      if startDelay > 0 {
        try engine.block.appendChild(to: track, child: createSpacer(engine, page: page, duration: startDelay))
      }
      try engine.block.appendChild(to: track, child: block)
      let remaining = MemoriesConstants.titleDuration - startDelay - flashDuration
      if remaining > 0 {
        try engine.block.appendChild(to: track, child: createSpacer(engine, page: page, duration: remaining))
      }
    }
  }

  private static func fadeAnimation(_ engine: Engine, duration: Double) throws -> DesignBlockID {
    let animation = try engine.block.createAnimation(.fade)
    try engine.block.setDuration(animation, duration: duration)
    return animation
  }

  /// The time at which the burst has ended and the title shows unobstructed, or `nil` without a title.
  static func readTitleClearTime(_ engine: Engine, page: DesignBlockID, tracks: Tracks) throws -> Double? {
    guard try !titleBlocks(engine, tracks: tracks).isEmpty else { return nil }
    // Burst tracks are the page's tracks without a role. The full-length backdrop track must not count,
    // otherwise the title thumbnail seeks to the end of the montage.
    let known = Set([tracks.mediaTrack, tracks.textTrack, tracks.backgroundTrack].compactMap(\.self))
    var burstEnd = 0.0
    for track in try engine.block.getChildren(page)
      where try !known.contains(track) && engine.block.getType(track) == DesignBlockType.track.rawValue {
      var time = 0.0
      for block in try engine.block.getChildren(track) {
        time += try engine.block.getDuration(block)
        if try engine.block.getType(block) == DesignBlockType.graphic.rawValue,
           try !engine.block.hasMetadata(block, key: spacerTypeKey) {
          burstEnd = max(burstEnd, time)
        }
      }
    }
    return burstEnd
  }
}
