import Media
import SwiftUI

struct AddImageButton<Label: View>: View {
  @EnvironmentObject private var interactor: Interactor

  @State private var showImagePicker = false
  @State private var showCamera = false

  @ViewBuilder private let label: () -> Label

  init(@ViewBuilder label: @escaping () -> Label = {
    SwiftUI.Label {
      Text(SheetMode.add.localizedStringKey)
    } icon: {
      Image("custom.photo.badge.plus", bundle: Bundle.bundle)
    }
    .labelStyle(.titleAndIcon)
  }) {
    self.label = label
  }

  var body: some View {
    Menu {
      Button {
        showImagePicker.toggle()
      } label: {
        SwiftUI.Label("Choose Photo", systemImage: "photo.on.rectangle")
      }
      Button {
        showCamera.toggle()
      } label: {
        SwiftUI.Label("Take Photo", systemImage: "camera")
      }
    } label: {
      label()
    }
    .imagePicker(isPresented: $showImagePicker) { result in
      if let url = try? result.get() {
        interactor.uploadImage(sourceID: ImageSource.uploads.sourceID, url: url)
      }
    }
    .camera(isPresented: $showCamera) { result in
      if let url = try? result.get() {
        interactor.uploadImage(sourceID: ImageSource.uploads.sourceID, url: url)
      }
    }
  }
}
