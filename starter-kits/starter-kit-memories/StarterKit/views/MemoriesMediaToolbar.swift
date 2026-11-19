import PhotosUI
import SwiftUI

/// The actions under a media grid: add, select, sort by date and delete, then proceed (on the selection
/// screen) or confirm the staged changes (in the editor).
struct MemoriesMediaToolbar: View {
  @Binding var draft: MemoriesMediaDraft
  let isImporting: Bool
  /// Shows a checkmark instead of an arrow on the proceed button.
  let confirms: Bool
  let onAdd: ([PhotosPickerItem]) -> Void
  let onProceed: () -> Void

  @State private var isDeleteAlertPresented = false
  @State private var pickerSelection: [PhotosPickerItem] = []

  var body: some View {
    HStack(spacing: 12) {
      HStack(spacing: 4) {
        if !draft.isMultiSelect {
          let icon = isImporting ? "hourglass" : "photo.badge.plus"
          PhotosPicker(selection: $pickerSelection, matching: .any(of: [.images, .videos])) {
            Image(systemName: icon)
              .font(.title3)
              .frame(width: 44, height: 44)
          }
          .disabled(isImporting)
          .accessibilityLabel("Add media")
          .onChange(of: pickerSelection) { items in
            guard !items.isEmpty else { return }
            // Starts empty again, so the next pick adds to the media instead of replacing it.
            pickerSelection = []
            onAdd(items)
          }
        }
        Button { draft.toggleMultiSelect() } label: {
          toolbarIcon("checkmark.circle", isOn: draft.isMultiSelect)
        }
        .accessibilityLabel(draft.isMultiSelect ? "Exit selection" : "Select media")
        Button { draft.toggleSort() } label: {
          toolbarIcon("arrow.up.arrow.down", isOn: draft.isSortEnabled)
            .scaleEffect(y: draft.isSortEnabled && !draft.isSortAscending ? -1 : 1)
        }
        .accessibilityLabel("Sort by date")
        Button { isDeleteAlertPresented = true } label: {
          toolbarIcon(draft.isMultiSelect ? "trash" : "trash.fill")
            .overlay(alignment: .topTrailing) {
              if draft.isMultiSelect {
                Text("\(draft.markedIDs.count)")
                  .font(.caption2.bold())
                  .foregroundStyle(.white)
                  .padding(4)
                  .background(Circle().fill(.red))
                  .offset(x: 2, y: -2)
              }
            }
        }
        .disabled(draft.isMultiSelect ? draft.markedIDs.isEmpty : draft.items.isEmpty)
        .accessibilityLabel(draft.isMultiSelect ? "Delete selected media" : "Delete all media")
      }
      .padding(.horizontal, 8)
      .frame(height: 64)
      .background(Capsule().fill(Color(.secondarySystemBackground)).shadow(radius: 3))

      Button(action: onProceed) {
        Image(systemName: confirms ? "checkmark" : "arrow.right")
          .font(.title3.bold())
          .frame(width: 56, height: 56)
          .foregroundStyle(canProceed ? Color.white : Color.secondary)
          .background(RoundedRectangle(cornerRadius: 14)
            .fill(canProceed ? Color.accentColor : Color(.secondarySystemBackground))
            .shadow(radius: 3))
      }
      .disabled(!canProceed)
      .accessibilityLabel(confirms ? "Apply changes" : "Proceed")
    }
    .alert(deleteTitle, isPresented: $isDeleteAlertPresented) {
      Button("Delete", role: .destructive) {
        if draft.isMultiSelect {
          draft.deleteMarked()
        } else {
          draft.deleteAll()
        }
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text(deleteMessage)
    }
  }

  /// The import adds its items only when the whole batch is done, so proceeding earlier drops them.
  private var canProceed: Bool {
    !draft.items.isEmpty && !isImporting
  }

  private func toolbarIcon(_ systemName: String, isOn: Bool = false) -> some View {
    Image(systemName: systemName)
      .font(.title3)
      .frame(width: 44, height: 44)
      .background(Circle().fill(isOn ? Color.accentColor.opacity(0.2) : .clear))
  }

  private var deleteTitle: String {
    draft.isMultiSelect ? "Delete selected media?" : "Delete all media?"
  }

  private var deleteMessage: String {
    let count = draft.isMultiSelect ? draft.markedIDs.count : draft.items.count
    let noun = count == 1 ? "item" : "items"
    return draft.isMultiSelect
      ? "Remove \(count) selected \(noun)? This can't be undone."
      : "Remove all \(count) \(noun)? This can't be undone."
  }
}
