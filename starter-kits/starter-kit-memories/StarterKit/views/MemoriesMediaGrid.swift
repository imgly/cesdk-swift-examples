import SwiftUI
import UniformTypeIdentifiers

/// The picked media in slot order. Long press and drag a tile to move it; while selecting, a tap marks
/// a tile for deletion.
struct MemoriesMediaGrid: View {
  @Binding var draft: MemoriesMediaDraft
  @State private var draggedID: Int?

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(Array(draft.items.enumerated()), id: \.element.id) { index, item in
          MemoriesMediaTile(item: item, position: index + 1, isSelecting: draft.isMultiSelect,
                            isMarked: draft.markedIDs.contains(item.id))
            .onTapGesture {
              if draft.isMultiSelect {
                draft.toggleMark(item.id)
              }
            }
            .onDrag {
              draggedID = item.id
              return NSItemProvider(object: "\(item.id)" as NSString)
            }
            .onDrop(of: [.text], delegate: ReorderDelegate(targetID: item.id, draggedID: $draggedID,
                                                           draft: $draft))
        }
      }
      .padding(.horizontal)
      // Room for the toolbar that floats over the bottom of the grid.
      .padding(.bottom, 96)
    }
  }

  /// Moves the dragged tile into the slot it hovers, so the grid shows the new order while dragging.
  @MainActor
  private struct ReorderDelegate: DropDelegate {
    let targetID: Int
    @Binding var draggedID: Int?
    @Binding var draft: MemoriesMediaDraft

    func dropEntered(info _: DropInfo) {
      guard let draggedID, draggedID != targetID else { return }
      withAnimation {
        draft.move(fromID: draggedID, toID: targetID)
      }
    }

    func dropUpdated(info _: DropInfo) -> DropProposal? {
      DropProposal(operation: .move)
    }

    func performDrop(info _: DropInfo) -> Bool {
      draggedID = nil
      return true
    }
  }
}

private struct MemoriesMediaTile: View {
  let item: MemoriesMediaItem
  let position: Int
  let isSelecting: Bool
  let isMarked: Bool

  var body: some View {
    MemoriesThumbnailView(item: item)
      .aspectRatio(4 / 5, contentMode: .fit)
      .overlay {
        if item.isVideo {
          MemoriesPlayBadge(size: 34)
        }
      }
      .overlay {
        if isMarked {
          Color.accentColor.opacity(0.25)
        }
      }
      .overlay(alignment: .bottomLeading) {
        Text("\(position)")
          .font(.caption.bold())
          .foregroundStyle(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 4))
          .padding(4)
      }
      .overlay(alignment: .topTrailing) {
        if isSelecting {
          Image(systemName: isMarked ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(isMarked ? Color.accentColor : .white)
            .background(Circle().fill(isMarked ? .white : .black.opacity(0.35)))
            .padding(6)
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay {
        if isMarked {
          RoundedRectangle(cornerRadius: 8).strokeBorder(Color.accentColor, lineWidth: 3)
        }
      }
      .contentShape(RoundedRectangle(cornerRadius: 8))
  }
}

/// The circled play symbol that marks a video.
struct MemoriesPlayBadge: View {
  let size: CGFloat

  var body: some View {
    Image(systemName: "play.fill")
      .font(.system(size: size * 0.45))
      .foregroundStyle(.white)
      .frame(width: size, height: size)
      .background(.black.opacity(0.45), in: Circle())
  }
}
