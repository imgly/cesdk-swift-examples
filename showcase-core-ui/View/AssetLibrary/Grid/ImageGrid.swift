import IMGLYCore
import SwiftUI

public struct ImageGrid<Empty: View, First: View>: View {
  @ViewBuilder private let empty: (_ search: String) -> Empty
  @ViewBuilder private let first: () -> First

  public init(@ViewBuilder empty: @escaping (_ search: String) -> Empty = { _ in Message.noElements },
              @ViewBuilder first: @escaping () -> First = { EmptyView() }) {
    self.empty = empty
    self.first = first
  }

  public var body: some View {
    AssetGrid { asset in
      ImageItem(asset: asset)
    } empty: {
      empty($0)
    } first: {
      first()
    }
    .assetGrid(axis: .vertical)
    .assetGrid(items: [GridItem(.adaptive(minimum: 108, maximum: 152), spacing: 4)])
    .assetGrid(spacing: 4)
    .assetGrid(padding: 4)
    .assetGridPlaceholderCount { state, _ in
      state == .loading ? 3 : 0
    }
    .assetLoader()
  }
}

struct ImageGrid_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
