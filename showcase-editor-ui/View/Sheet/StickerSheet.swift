import SwiftUI

struct StickerSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  @ViewBuilder var stickerGrid: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)], spacing: 8) {
        ForEach(assets.stickers) { asset in
          ZStack {
            GridItemBackground()
              .aspectRatio(1, contentMode: .fit)
            Image(asset.imageName, bundle: Bundle.bundle, label: Text(asset.label))
              .resizable()
              .aspectRatio(contentMode: .fit)
              .aspectRatio(1, contentMode: .fit)
              .padding(8)
          }
          .onTapGesture {
            interactor.assetTapped(asset)
          }
        }
      }
      .padding(8)
    }
  }

  var body: some View {
    BottomSheet {
      switch sheet.mode {
      case .add, .replace: stickerGrid
      case .layer: LayerOptions()
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
