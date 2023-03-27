import SwiftUI

struct AddImageButton: View {
  @EnvironmentObject private var interactor: Interactor

  @State private var showImagePicker = false
  @State private var showCamera = false

  var body: some View {
    Menu {
      Button {
        showImagePicker.toggle()
      } label: {
        Label("Choose Photo", systemImage: "photo.on.rectangle")
      }
      Button {
        showCamera.toggle()
      } label: {
        Label("Take Photo", systemImage: "camera")
      }
    } label: {
      Label {
        Text(SheetMode.add.localizedStringKey)
      } icon: {
        Image("custom.photo.badge.plus", bundle: Bundle.bundle)
      }
      .labelStyle(.titleAndIcon)
    }
    .imagePicker(isPresented: $showImagePicker) { result in
      if let url = try? result.get() {
        interactor.uploadImage(.init(url: url, label: ""))
      }
    }
    .camera(isPresented: $showCamera) { result in
      if let url = try? result.get() {
        interactor.uploadImage(.init(url: url, label: ""))
      }
    }
  }
}
