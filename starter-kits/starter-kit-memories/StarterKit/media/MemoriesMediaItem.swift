import Foundation

/// A photo or video clip picked for the slideshow.
struct MemoriesMediaItem: Identifiable, Equatable, Sendable {
  /// Stable ID, so the grids keep track of an item while it is reordered.
  let id: Int
  let url: URL
  /// When the photo was taken, or `nil` when the file has no capture date.
  var creationDate: Date?
  var isVideo = false
}

extension [MemoriesMediaItem] {
  /// Sorted by capture date. Items without a date go last when ascending and first when descending.
  func sortedByDate(ascending: Bool) -> Self {
    sorted { lhs, rhs in
      let missing = ascending ? Date.distantFuture : Date.distantPast
      let lhsDate = lhs.creationDate ?? missing
      let rhsDate = rhs.creationDate ?? missing
      if lhsDate != rhsDate {
        return ascending ? lhsDate < rhsDate : lhsDate > rhsDate
      }
      return ascending ? lhs.id < rhs.id : lhs.id > rhs.id
    }
  }

  /// `true` when already oldest first, `false` when newest first, and `nil` when unsorted or too
  /// short to tell. Items without a date fall back to ID order, so a fresh batch reads as ascending.
  var detectedSortOrder: Bool? {
    guard count > 1 else { return nil }
    if self == sortedByDate(ascending: true) {
      return true
    }
    if self == sortedByDate(ascending: false) {
      return false
    }
    return nil
  }
}

/// The editable media list behind a grid: the picker screen and the in-editor overlay each own one.
///
/// The sort button reflects the list: on, with its direction, while the items are in date order, and
/// off once a drag puts them out of order. Off keeps the last direction, so the next tap restores it.
struct MemoriesMediaDraft {
  private(set) var items: [MemoriesMediaItem] = []
  private(set) var isSortEnabled = false
  private(set) var isSortAscending = true
  private(set) var isMultiSelect = false
  /// IDs marked for deletion while ``isMultiSelect`` is on.
  private(set) var markedIDs: Set<Int> = []

  /// An ID no current item uses, also after deletions.
  var nextID: Int {
    (items.map(\.id).max() ?? 0) + 1
  }

  init(items: [MemoriesMediaItem] = []) {
    self.items = items
    refreshSortState()
  }

  /// Appends new items, in date order when sorting is on.
  mutating func add(_ newItems: [MemoriesMediaItem]) {
    guard !newItems.isEmpty else { return }
    let combined = items + newItems
    items = isSortEnabled ? combined.sortedByDate(ascending: isSortAscending) : combined
    refreshSortState()
  }

  mutating func move(fromID: Int, toID: Int) {
    guard let from = items.firstIndex(where: { $0.id == fromID }),
          let to = items.firstIndex(where: { $0.id == toID }), from != to else { return }
    items.insert(items.remove(at: from), at: to)
    refreshSortState()
  }

  /// Flips the direction while sorted. Out of order, the first tap restores the last direction.
  mutating func toggleSort() {
    if isSortEnabled {
      isSortAscending.toggle()
    } else {
      isSortEnabled = true
    }
    items = items.sortedByDate(ascending: isSortAscending)
  }

  /// Either way, the marked items are cleared.
  mutating func toggleMultiSelect() {
    isMultiSelect.toggle()
    markedIDs = []
  }

  mutating func toggleMark(_ id: Int) {
    if markedIDs.remove(id) == nil {
      markedIDs.insert(id)
    }
  }

  mutating func deleteMarked() {
    items.removeAll { markedIDs.contains($0.id) }
    markedIDs = []
    refreshSortState()
  }

  mutating func deleteAll() {
    items = []
    markedIDs = []
    refreshSortState()
  }

  private mutating func refreshSortState() {
    if let ascending = items.detectedSortOrder {
      isSortEnabled = true
      isSortAscending = ascending
    } else {
      isSortEnabled = false
    }
  }
}
