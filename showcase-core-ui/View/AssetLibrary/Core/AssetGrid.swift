import SwiftUI

struct AssetGridAxisKey: EnvironmentKey {
  static var defaultValue = Axis.vertical
}

struct AssetGridItemsKey: EnvironmentKey {
  static var defaultValue = [GridItem(.flexible())]
}

struct AssetGridSpacingKey: EnvironmentKey {
  static var defaultValue: CGFloat?
}

struct AssetGridEdgesKey: EnvironmentKey {
  static var defaultValue: Edge.Set = .all
}

struct AssetGridPaddingKey: EnvironmentKey {
  static var defaultValue: CGFloat?
}

struct AssetGridMessageTextOnlyKey: EnvironmentKey {
  static var defaultValue = false
}

struct AssetGridMaxItemCountKey: EnvironmentKey {
  static var defaultValue = Int.max
}

public typealias AssetGridPlaceholderCount = (_ state: AssetLoader.Models.State, _ maxItemCount: Int) -> Int

struct AssetGridPlaceholderCountKey: EnvironmentKey {
  static var defaultValue: AssetGridPlaceholderCount = { state, maxItemCount in
    state == .loading ? min(20, maxItemCount) : 0
  }
}

extension EnvironmentValues {
  var assetGridAxis: AssetGridAxisKey.Value {
    get { self[AssetGridAxisKey.self] }
    set { self[AssetGridAxisKey.self] = newValue }
  }

  var assetGridItems: AssetGridItemsKey.Value {
    get { self[AssetGridItemsKey.self] }
    set { self[AssetGridItemsKey.self] = newValue }
  }

  var assetGridSpacing: AssetGridSpacingKey.Value {
    get { self[AssetGridSpacingKey.self] }
    set { self[AssetGridSpacingKey.self] = newValue }
  }

  var assetGridEdges: AssetGridEdgesKey.Value {
    get { self[AssetGridEdgesKey.self] }
    set { self[AssetGridEdgesKey.self] = newValue }
  }

  var assetGridPadding: AssetGridPaddingKey.Value {
    get { self[AssetGridPaddingKey.self] }
    set { self[AssetGridPaddingKey.self] = newValue }
  }

  var assetGridMessageTextOnly: AssetGridMessageTextOnlyKey.Value {
    get { self[AssetGridMessageTextOnlyKey.self] }
    set { self[AssetGridMessageTextOnlyKey.self] = newValue }
  }

  var assetGridMaxItemCount: AssetGridMaxItemCountKey.Value {
    get { self[AssetGridMaxItemCountKey.self] }
    set { self[AssetGridMaxItemCountKey.self] = newValue }
  }

  var assetGridPlaceholderCount: AssetGridPlaceholderCountKey.Value {
    get { self[AssetGridPlaceholderCountKey.self] }
    set { self[AssetGridPlaceholderCountKey.self] = newValue }
  }
}

public struct AssetGrid<Item: View, Empty: View, First: View, More: View>: View {
  @EnvironmentObject private var interactor: AnyAssetLibraryInteractor
  @EnvironmentObject private var data: AssetLoader.Data
  @Environment(\.assetGridAxis) private var axis
  @Environment(\.assetGridItems) private var items
  @Environment(\.assetGridSpacing) private var spacing
  @Environment(\.assetGridEdges) private var edges
  @Environment(\.assetGridPadding) private var padding
  @Environment(\.assetGridMessageTextOnly) private var messageTextOnly
  @Environment(\.assetGridMaxItemCount) private var maxItemCount
  @Environment(\.assetGridPlaceholderCount) private var placeholderCount

  @ViewBuilder private let item: (AssetItem) -> Item
  @ViewBuilder private let empty: (_ search: String) -> Empty
  @ViewBuilder private let first: () -> First
  @ViewBuilder private let more: () -> More

  public init(
    @ViewBuilder item: @escaping (AssetItem) -> Item,
    @ViewBuilder empty: @escaping (_ search: String) -> Empty = { _ in Message.noElements },
    @ViewBuilder first: @escaping () -> First = { EmptyView() },
    @ViewBuilder more: @escaping () -> More = { EmptyView() }
  ) {
    self.item = item
    self.empty = empty
    self.first = first
    self.more = more
  }

  private func loadMoreContentIfNeeded(currentItem asset: AssetLoader.Asset) {
    guard data.model.assets.count <= maxItemCount else {
      return
    }
    let threshold = data.model.assets.dropLast(20).last ?? data.model.assets.last
    if asset.id == threshold?.id {
      data.model.loadNextPage()
    }
  }

  @ViewBuilder private func grid(@ViewBuilder content: () -> some View) -> some View {
    switch axis {
    case .horizontal:
      AssetLibraryScrollView(axis: .horizontal, showsIndicators: false) {
        LazyHGrid(rows: items, spacing: spacing) {
          content()
        }
        .padding(edges, padding)
      }
    case .vertical:
      AssetLibraryScrollView(axis: .vertical, showsIndicators: true) {
        LazyVGrid(columns: items, spacing: spacing) {
          content()
        }
        .padding(edges, padding)
      }
    }
  }

  @ViewBuilder private var placeholderView: some View {
    grid {
      ForEach(0 ..< placeholderCount(data.model.state, maxItemCount), id: \.self) { _ in
        item(.placeholder)
      }
    }
    .allowsHitTesting(false)
  }

  @ViewBuilder private var messageView: some View {
    switch data.model.state {
    case .loading:
      placeholderView
        .shimmer()
    case .loaded:
      placeholderView
        .mask {
          let colors: [Color] = [.black, .clear]
          Rectangle().fill(.linearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
            .flipsForRightToLeftLayoutDirection(true)
        }
        .overlay {
          empty(data.model.search.query ?? "")
        }
    case .error:
      placeholderView
        .mask {
          let colors: [Color] = [.black, .clear]
          Rectangle().fill(.linearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
            .flipsForRightToLeftLayoutDirection(true)
        }
        .overlay {
          VStack(spacing: 30) {
            Message.noService
            if !messageTextOnly {
              Button {
                data.model.retry()
              } label: {
                Label("Retry", systemImage: "arrow.clockwise")
              }
              .buttonStyle(.bordered)
              .tint(.secondary)
            }
          }
        }
    }
  }

  @ViewBuilder private var contentView: some View {
    grid {
      first()
      ForEach(data.model.assets.prefix(maxItemCount)) { asset in
        item(.asset(asset))
          .modifier(AttributionSheet(asset: asset))
          .onAppear {
            loadMoreContentIfNeeded(currentItem: asset)
          }
      }
      if case .loading = data.model.state {
        item(.placeholder)
          .shimmer()
      }
      if data.model.assets.count >= maxItemCount, data.model.total > maxItemCount || data.model.total < 0 {
        more()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .aspectRatio(1, contentMode: .fit)
      }
    }
    .allowsHitTesting(!interactor.isAddingAsset)
  }

  public var body: some View {
    if data.model.isValid {
      contentView
    } else {
      messageView
    }
  }
}

struct AssetGrid_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
