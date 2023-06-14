import IMGLYCore
import Media
import SwiftUI

public struct UploadGrid: View {
  let interactor: AssetLibraryInteractor
  let sourceID: String
  @Binding var search: String

  public init(interactor: AssetLibraryInteractor, sourceID: String, search: Binding<String>) {
    self.interactor = interactor
    self.sourceID = sourceID
    _search = search
  }

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

  @MainActor
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
          interactor.uploadImage(sourceID: sourceID, url: url)
        }
      }
    }
  }

  public var body: some View {
    ImageGrid(interactor: interactor, sourceID: sourceID, search: $search) { search in
      if search.isEmpty {
        addImage
      } else {
        Message.noResults
      }
    }
  }
}
