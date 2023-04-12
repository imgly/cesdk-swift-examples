import Media
import SwiftUI

struct UploadGrid: View {
  let sourceID: String
  @Binding var search: String

  @EnvironmentObject private var interactor: Interactor
  @State private var showImagePicker = false

  @ViewBuilder var mesage: some View {
    VStack(spacing: 10) {
      Image(systemName: "folder")
        .font(.largeTitle.weight(.thin))
      Text("Nothing here yet")
    }
    .imageScale(.large)
    .foregroundColor(.secondary)
  }

  @ViewBuilder var addImage: some View {
    VStack(spacing: 30) {
      mesage

      Button {
        showImagePicker.toggle()
      } label: {
        Label {
          Text("Add Image")
        } icon: {
          Image("custom.photo.badge.plus", bundle: Bundle.bundle)
        }
        .padding([.leading, .trailing], 40)
        .padding([.top, .bottom], 6)
        .labelStyle(.titleOnly)
      }
      .buttonStyle(.bordered)
      .font(.headline)
      .tint(.accentColor)
      .imagePicker(isPresented: $showImagePicker) { result in
        if let url = try? result.get() {
          interactor.uploadImage(url)
        }
      }
    }
  }

  var body: some View {
    ImageGrid(sourceID: sourceID, search: $search) { search in
      if search.isEmpty {
        addImage
      } else {
        Message.noResults
      }
    }
  }
}
