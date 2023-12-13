import IMGLYCore
import IMGLYEngine
import SwiftUI

public struct AssetPreview: View {
  @Environment(\.seeAllView) private var seeAllView
  private let height: CGFloat?

  public init(height: CGFloat?) {
    self.height = height
  }

  @ViewBuilder func item(_ assetItem: AssetItem) -> some View {
    if case let .asset(asset) = assetItem {
      // If not set assume the default engine value.
      let designBlockType = asset.result.blockType ?? DesignBlockType.graphic.rawValue
      if designBlockType == DesignBlockType.graphic.rawValue {
        let fillType = asset.result.fillType ?? ""
        let designBlockKind = asset.result.blockKind ?? ""

        switch fillType {
        case FillType.video.rawValue:
          ImageItem(asset: assetItem)
        case FillType.image.rawValue:
          if designBlockKind == BlockKind.key(.sticker).rawValue {
            StickerItem(asset: assetItem)
          } else {
            ImageItem(asset: assetItem)
          }
        case FillType.color.rawValue, FillType.linearGradient.rawValue,
             FillType.radialGradient.rawValue, FillType.conicalGradient.rawValue:
          ShapeItem(asset: assetItem)
        default:
          if designBlockKind == BlockKind.key(.shape).rawValue {
            ShapeItem(asset: assetItem)
          } else {
            ImageItem(asset: assetItem)
          }
        }
      } else {
        ImageItem(asset: assetItem)
      }
    } else {
      ImageItem(asset: assetItem)
    }
  }

  public var body: some View {
    AssetGrid { asset in
      item(asset)
    } empty: { _ in
      Message.noElements
    } more: {
      seeAllView
    }
    .assetGrid(axis: .horizontal)
    .assetGrid(items: [GridItem(.adaptive(minimum: 108, maximum: 152), spacing: 4)])
    .assetGrid(spacing: 4)
    .assetGrid(edges: [.leading, .trailing])
    .assetGrid(padding: 16)
    .assetGrid(maxItemCount: 10)
    .assetGridPlaceholderCount { _, maxItemCount in
      maxItemCount
    }
    .assetGrid(messageTextOnly: true)
    .assetLoader()
    .frame(height: height)
  }
}

struct AssetPreview_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
