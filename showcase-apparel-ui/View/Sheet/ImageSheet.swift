import SwiftUI

struct ImageSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  @State private var showImagePicker = false
  @State private var showCamera = false

  @ViewBuilder var addButton: some View {
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
      SheetMode.add.label
        .labelStyle(.titleAndIcon)
    }
    .imagePicker(isPresented: $showImagePicker) { result in
      if let url = try? result.get() {
        interactor.assetTapped(.init(url: url, label: ""))
      }
    }
    .camera(isPresented: $showCamera) { result in
      if let url = try? result.get() {
        interactor.assetTapped(.init(url: url, label: ""))
      }
    }
  }

  @ViewBuilder var imageGrid: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 150))]) {
        ForEach(assets.images) { asset in
          AsyncImage(url: asset.url) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(minWidth: 0, minHeight: 0)
              .clipped()
              .aspectRatio(1, contentMode: .fit)
              .onTapGesture {
                interactor.assetTapped(asset)
              }
              .accessibilityLabel(asset.label)
          } placeholder: {
            ProgressView()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .aspectRatio(1, contentMode: .fit)
          }
        }
      }
    }
    .opacity(interactor.isAddingAsset ? 0.5 : 1)
    .disabled(interactor.isAddingAsset)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        addButton
      }
    }
  }

  var body: some View {
    BottomSheet(title: Text(sheet.localizedStringKey)) {
      switch sheet.mode {
      case .add: EmptyView()
      default: SheetModePicker(sheet: $interactor.sheet.model, modes: [.replace, .arrange])
      }
    } content: {
      switch sheet.mode {
      case .add, .replace: imageGrid
      case .arrange: ArrangeOptions()
      default: EmptyView()
      }
    }
  }
}

struct ImageSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .image))
  }
}
