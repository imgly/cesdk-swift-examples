import IMGLYCore
import SwiftUI

public struct ShapeGrid: View {
  public init() {}

  public var body: some View {
    AssetGrid { asset in
      ShapeItem(asset: asset)
    }
    .assetGrid(axis: .vertical)
    .assetGrid(items: [GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 4)])
    .assetGrid(spacing: 4)
    .assetGrid(padding: 4)
    .assetGridPlaceholderCount { state, _ in
      state == .loading ? 4 : 0
    }
    .assetLoader()
  }
}

struct ShapeGrid_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
