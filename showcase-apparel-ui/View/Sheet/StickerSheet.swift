import SwiftUI

struct StickerSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  @ViewBuilder var stickerGrid: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 150))]) {
        ForEach(assets.stickers) { asset in
          Image(asset.imageName, bundle: Bundle.bundle, label: Text(asset.label))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(maxHeight: 150)
            .onTapGesture {
              interactor.assetTapped(asset)
            }
        }
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
      case .add, .replace: stickerGrid
      case .arrange: ArrangeOptions()
      default: EmptyView()
      }
    }
  }
}

struct StickerSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .sticker))
  }
}
