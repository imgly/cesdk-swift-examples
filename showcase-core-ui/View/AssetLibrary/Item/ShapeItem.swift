import SwiftUI

struct ShapeItem: View {
  let asset: AssetItem

  var body: some View {
    switch asset {
    case let .asset(asset):
      ReloadableAsyncImage(asset: asset) { image in
        image
          .resizable()
          .renderingMode(.template)
          .aspectRatio(contentMode: .fit)
          .aspectRatio(1, contentMode: .fit)
          .padding(8)
      }
    case .placeholder:
      GridItemBackground()
        .aspectRatio(1, contentMode: .fit)
    }
  }
}

struct ShapeItem_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
