import SwiftUI

struct SearchButton: View {
  @EnvironmentObject private var searchState: AssetLibrary.SearchState
  @EnvironmentObject private var searchQuery: AssetLibrary.SearchQuery

  var body: some View {
    Button {
      searchState.isPresented = true
    } label: {
      Label("Search", systemImage: "magnifyingglass")
        .font(.body.weight(.semibold))
    }
  }
}

struct SearchButton_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
