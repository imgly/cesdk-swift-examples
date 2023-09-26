import IMGLYEngine
import SwiftUI

public struct TextList<Empty: View>: View {
  @ViewBuilder private let empty: (_ search: String) -> Empty

  public init(@ViewBuilder empty: @escaping (_ search: String) -> Empty = { _ in Message.noElements }) {
    self.empty = empty
  }

  public var body: some View {
    AssetGrid { asset in
      TextItem(asset: asset)
    } empty: {
      empty($0)
    }
    .assetGrid(axis: .vertical)
    .assetGrid(items: [GridItem(.flexible(), spacing: 8)])
    .assetGrid(spacing: 8)
    .assetGrid(padding: 16)
    .assetLoader()
  }
}

struct TextList_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
