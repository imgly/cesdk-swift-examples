import SwiftUI

public struct AssetLibraryMoreTab<Content: View>: View {
  @ViewBuilder private let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  private let title: String = "More"
  var localizedTitle: LocalizedStringKey { .init(title) }
  @Environment(\.dismissButtonView) private var dismissButtonView

  public var body: some View {
    NavigationView {
      MoreList(content: content)
        .navigationTitle(localizedTitle)
        .toolbar {
          ToolbarItem {
            dismissButtonView
          }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    .navigationViewStyle(.stack)
    .searchableAssetLibraryTab()
    .tabItem {
      Label(localizedTitle, systemImage: "ellipsis")
    }
    .tag(title)
  }
}

private struct MoreList<Content: View>: View {
  @ViewBuilder let content: () -> Content

  @EnvironmentObject private var searchQuery: AssetLibrary.SearchQuery

  var body: some View {
    List {
      content()
        .environment(\.isAssetLibraryMoreTab, true)
    }
    .listStyle(.inset)
    .onAppear {
      searchQuery.value = .init()
    }
  }
}

struct AssetLibraryMoreTabKey: EnvironmentKey {
  static let defaultValue: Bool = false
}

extension EnvironmentValues {
  var isAssetLibraryMoreTab: Bool {
    get { self[AssetLibraryMoreTabKey.self] }
    set { self[AssetLibraryMoreTabKey.self] = newValue }
  }
}

struct AssetLibraryMoreTab_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
