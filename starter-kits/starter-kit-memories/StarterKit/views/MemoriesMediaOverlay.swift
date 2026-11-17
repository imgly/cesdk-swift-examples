import SwiftUI

/// The media grid over the editor. Adding, sorting, moving and deleting are staged, and reach the
/// tracks only when the user confirms. Closing discards them.
struct MemoriesMediaOverlay: View {
  @ObservedObject var model: MemoriesModel

  var body: some View {
    MemoriesMediaGrid(draft: $model.mediaOverlay)
      .padding(.top, 72)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.systemBackground))
      .overlay(alignment: .topTrailing) {
        Button { model.cancelMediaOverlay() } label: {
          Image(systemName: "xmark")
            .font(.headline)
            .frame(width: 44, height: 44)
            .background(Circle().fill(Color(.secondarySystemBackground)))
        }
        .accessibilityLabel("Cancel")
        .padding()
      }
      .overlay(alignment: .bottom) {
        MemoriesMediaToolbar(draft: $model.mediaOverlay, isImporting: model.isImporting, confirms: true) { items in
          Task { await model.importMedia(items, into: \.mediaOverlay) }
        } onProceed: {
          Task { await model.applyMediaOverlay() }
        }
        .disabled(model.isApplying)
        .padding(.horizontal)
      }
  }
}
