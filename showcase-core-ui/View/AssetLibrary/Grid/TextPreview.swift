import IMGLYEngine
import SwiftUI

public struct TextPreview: View {
  public init() {}

  public var body: some View {
    TextList { _ in
      Message.noElements
    }
    .assetGrid(edges: [.leading, .trailing])
    .assetGrid(maxItemCount: 3)
    .assetGridPlaceholderCount { _, maxItemCount in
      maxItemCount
    }
    .assetGrid(messageTextOnly: true)
  }
}

struct TextPreview_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
