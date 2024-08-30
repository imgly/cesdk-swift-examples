import SwiftUI

struct ImageGrid<Empty: View>: View {
  private let sourceID: String
  @Binding private var search: String
  @ViewBuilder private let empty: (_ search: String) -> Empty

  init(sourceID: String, search: Binding<String>,
       @ViewBuilder empty: @escaping (_ search: String) -> Empty = { _ in Message.noResults }) {
    self.sourceID = sourceID
    _search = search
    self.empty = empty
  }

  var body: some View {
    AssetGrid(sourceID: sourceID, search: $search,
              columns: [GridItem(.adaptive(minimum: 108, maximum: 152), spacing: 2)],
              spacing: 2, padding: 0) { asset in
      ReloadableAsyncImage(asset: asset, sourceID: sourceID) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(minWidth: 0, minHeight: 0)
          .clipped()
          .aspectRatio(1, contentMode: .fit)
      }
    } empty: {
      empty($0)
    }
  }
}
