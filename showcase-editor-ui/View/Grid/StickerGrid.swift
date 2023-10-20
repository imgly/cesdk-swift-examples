import SwiftUI

struct StickerGrid: View {
  let sourceID: String
  @Binding var search: String

  var body: some View {
    AssetGrid(sourceID: sourceID, search: $search,
              columns: [GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)],
              spacing: 8, padding: 8) { asset in
      ZStack {
        GridItemBackground()
          .aspectRatio(1, contentMode: .fit)
        ReloadableAsyncImage(asset: asset, sourceID: sourceID) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .aspectRatio(1, contentMode: .fit)
        }
        .padding(8)
      }
    }
  }
}
