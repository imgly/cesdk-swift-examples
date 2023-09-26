import IMGLYEngine
import SwiftUI

public struct AudioPreview: View {
  public init() {}

  public var body: some View {
    AudioList { _ in
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

struct AudioPreview_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
