import SwiftUI

struct SearchedAssetLoader: ViewModifier {
  @Environment(\.assetLibrarySources) private var sources
  @EnvironmentObject private var search: AssetLibrary.SearchQuery

  func body(content: Content) -> some View {
    content
      .assetLoader(sources: sources, search: $search.debouncedValue)
  }
}

struct SearchedAssetLoader_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
