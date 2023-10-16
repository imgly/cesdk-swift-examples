import SwiftUI

struct SearchableAssetLibraryTab: ViewModifier {
  @StateObject private var searchState = AssetLibrary.SearchState()
  @StateObject private var searchQuery = AssetLibrary.SearchQuery(initialValue: .init())

  func body(content: Content) -> some View {
    content
      .overlay(alignment: .top) {
        SearchOverlay()
      }
      .environmentObject(searchQuery)
      .environmentObject(searchState)
  }
}

struct SearchableAssetLibraryTab_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
