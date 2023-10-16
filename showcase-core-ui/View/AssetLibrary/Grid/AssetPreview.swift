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
      let designBlockType = asset.result.blockType ?? ""
      switch designBlockType {
      case DesignBlockType.image.rawValue:
        ImageItem(asset: assetItem)
      case DesignBlockType.video.rawValue, "//ly.img.ubq/fill/video":
        ImageItem(asset: assetItem)
      case DesignBlockType.audio.rawValue:
        ImageItem(asset: assetItem)
      case _ where designBlockType.hasPrefix("//ly.img.ubq/shapes/"):
        ShapeItem(asset: assetItem)
      case DesignBlockType.vectorPath.rawValue:
        ShapeItem(asset: assetItem)
      case DesignBlockType.sticker.rawValue:
        StickerItem(asset: assetItem)
      default:
        ImageItem(asset: assetItem) // Not asigned fallback.
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
