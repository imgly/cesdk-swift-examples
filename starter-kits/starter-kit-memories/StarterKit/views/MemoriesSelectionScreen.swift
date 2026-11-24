import PhotosUI
import SwiftUI

/// The first screen: a title for the memory and the photos and videos to put in it.
struct MemoriesSelectionScreen: View {
  @ObservedObject var model: MemoriesModel
  let onExit: (() -> Void)?
  @State private var pickerSelection: [PhotosPickerItem] = []

  var body: some View {
    VStack(spacing: 12) {
      header
        .padding([.horizontal, .top])
      if model.picker.items.isEmpty {
        emptyState
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        MemoriesMediaGrid(draft: $model.picker)
      }
    }
    .overlay(alignment: .bottom) {
      if !model.picker.items.isEmpty {
        MemoriesMediaToolbar(draft: $model.picker, isImporting: model.isImporting, confirms: false) { items in
          Task { await model.importMedia(items, into: \.picker) }
        } onProceed: {
          model.openEditor()
        }
        .padding(.horizontal)
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let onExit {
        Button(action: onExit) {
          Image(systemName: "xmark")
            .font(.headline)
            .frame(width: 44, height: 44)
            .background(Circle().fill(Color(.secondarySystemBackground)))
        }
        .accessibilityLabel("Close")
      }
      Text("Create Your Video Memory")
        .font(.title2.bold())
      TextField("Add a title", text: $model.title, prompt: Text("My Amazing Memory"))
        .textFieldStyle(.roundedBorder)
        .submitLabel(.done)
    }
  }

  private var emptyState: some View {
    let isImporting = model.isImporting
    return PhotosPicker(selection: $pickerSelection, matching: .any(of: [.images, .videos])) {
      VStack(spacing: 16) {
        if isImporting {
          ProgressView()
        } else {
          Image(systemName: "photo.badge.plus")
            .font(.system(size: 44))
        }
        Text("Add your media")
      }
      .foregroundStyle(.secondary)
      .frame(width: 160, height: 160)
      .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
    .disabled(isImporting)
    .onChange(of: pickerSelection) { items in
      guard !items.isEmpty else { return }
      // Starts empty again, so the next pick adds to the media instead of replacing it.
      pickerSelection = []
      Task { await model.importMedia(items, into: \.picker) }
    }
  }
}
