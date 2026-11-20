import SwiftUI

/// One thumbnail of the strip. `media` is `nil` for the title card.
struct MemoriesStripItem {
  let media: MemoriesMediaItem?
  let startTime: Double
  let endTime: Double
  /// Where a tap or a drag onto this item seeks.
  let seekTarget: Double
  /// From this playback time on, the item is the current one and its played overlay fills.
  let currentThreshold: Double
}

/// A row of every clip, plus the title card, with the current one centered. Playback moves the row,
/// and a drag or a tap seeks. Each thumbnail fills as it plays.
struct MemoriesTimelineStrip: View {
  @ObservedObject var model: MemoriesModel

  /// The centered index when the drag began, or `nil` while not dragging.
  @State private var dragStartIndex: Int?
  @State private var dragOffset: CGFloat = 0
  @State private var lastDragIndex: Int?

  private let itemHeight: CGFloat = 60
  private let itemWidth: CGFloat = 60 * 9 / 16
  private let spacing: CGFloat = 8
  private var step: CGFloat {
    itemWidth + spacing
  }

  var body: some View {
    let items = model.stripItems
    // The current item is the last one past its threshold, the middle of its incoming blend, so the
    // strip follows a clip as it comes into view instead of after.
    let playbackIndex = items.lastIndex { model.playbackTime >= $0.currentThreshold } ?? 0
    let position = CGFloat(dragStartIndex ?? playbackIndex) - dragOffset / step

    GeometryReader { geometry in
      let itemsToEdge = max(geometry.size.width / 2 / itemWidth, 1)
      HStack(spacing: spacing) {
        ForEach(items.indices, id: \.self) { index in
          let distance = abs(CGFloat(index) - position)
          thumbnail(items[index], edgeFraction: min(distance / itemsToEdge, 1), isCurrent: distance < 0.5)
            .onTapGesture { model.seek(to: items[index].seekTarget) }
        }
      }
      .fixedSize()
      .offset(x: geometry.size.width / 2 - itemWidth / 2 - position * step)
      .animation(dragStartIndex == nil ? .easeOut(duration: 0.25) : nil, value: position)
    }
    .frame(height: itemHeight)
    .padding(.vertical, 8)
    .contentShape(Rectangle())
    .clipped()
    .gesture(drag(items: items, playbackIndex: playbackIndex))
  }

  /// Seeks live as a new item reaches the center under the finger, then settles where a fling ends.
  private func drag(items: [MemoriesStripItem], playbackIndex: Int) -> some Gesture {
    DragGesture(minimumDistance: 4)
      .onChanged { value in
        guard !items.isEmpty else { return }
        let start = dragStartIndex ?? playbackIndex
        dragStartIndex = start
        dragOffset = value.translation.width
        let index = clampedIndex(CGFloat(start) - dragOffset / step, count: items.count)
        if index != lastDragIndex {
          lastDragIndex = index
          UISelectionFeedbackGenerator().selectionChanged()
          model.seek(to: items[index].seekTarget)
        }
      }
      .onEnded { value in
        let start = dragStartIndex ?? playbackIndex
        let index = clampedIndex(CGFloat(start) - value.predictedEndTranslation.width / step, count: items.count)
        if !items.isEmpty {
          model.seek(to: items[index].seekTarget)
        }
        dragStartIndex = nil
        dragOffset = 0
        lastDragIndex = nil
      }
  }

  private func clampedIndex(_ position: CGFloat, count: Int) -> Int {
    min(max(Int(position.rounded()), 0), max(count - 1, 0))
  }

  private func thumbnail(_ item: MemoriesStripItem, edgeFraction: CGFloat, isCurrent: Bool) -> some View {
    let time = model.playbackTime
    let window = max(item.endTime - item.currentThreshold, 0.0001)
    let played = time >= item.endTime ? 1 : max(0, min(1, (time - item.currentThreshold) / window))
    return Group {
      if let media = item.media {
        MemoriesThumbnailView(item: media)
      } else {
        Color.accentColor.opacity(0.2)
          .overlay { Image(systemName: "textformat").foregroundStyle(Color.accentColor) }
      }
    }
    .overlay(alignment: .leading) {
      GeometryReader { geometry in
        Color.accentColor.opacity(0.28)
          .frame(width: geometry.size.width * played)
      }
    }
    .overlay {
      if item.media?.isVideo == true {
        MemoriesPlayBadge(size: 20)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .padding(.vertical, isCurrent ? 0 : 8)
    .frame(width: itemWidth, height: itemHeight)
    .opacity(1 - 0.75 * edgeFraction)
    .animation(.easeOut(duration: 0.2), value: isCurrent)
  }
}

extension MemoriesStripItem {
  /// An optional leading title item, then one item per clip. `titleClearTime` is `nil` without a title.
  static func items(clips: [MemoriesTimelineClip], titleClearTime: Double?) -> [MemoriesStripItem] {
    var items: [MemoriesStripItem] = []
    if let titleClearTime {
      items.append(MemoriesStripItem(media: nil, startTime: 0, endTime: clips.first?.startTime ?? titleClearTime + 1,
                                     seekTarget: titleClearTime, currentThreshold: 0))
    }
    for (index, clip) in clips.enumerated() {
      // A clip becomes current halfway through the overlap with the previous clip. A clip that nothing
      // overlaps is current from its own start.
      let previous = index > 0 ? clips[index - 1] : nil
      let threshold = if let previous, previous.endTime > clip.startTime {
        (clip.startTime + previous.endTime) / 2
      } else {
        clip.startTime
      }
      // A video seeks to where its incoming blend ends, so that a tap plays it from its opening frame.
      // A photo seeks to its clearest moment.
      let seekTarget = clip.isVideo ? max(clip.startTime, previous?.endTime ?? clip.startTime) : clip.clearTime
      items.append(MemoriesStripItem(media: MemoriesMediaItem(id: index, url: clip.url, isVideo: clip.isVideo),
                                     startTime: clip.startTime, endTime: clip.endTime,
                                     seekTarget: seekTarget, currentThreshold: threshold))
    }
    return items
  }
}
