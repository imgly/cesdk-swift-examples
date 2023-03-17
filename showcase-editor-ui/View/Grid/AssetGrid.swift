import Kingfisher
import SwiftUI

struct Message: View {
  static let noResults = Message("No results found", systemImage: "magnifyingglass")
  static let noService = Message("Cannot connect to service", systemImage: "exclamationmark.triangle")

  private let title: LocalizedStringKey
  private let systemImage: String

  init(_ title: LocalizedStringKey, systemImage: String) {
    self.title = title
    self.systemImage = systemImage
  }

  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: systemImage)
      Text(title)
    }
    .imageScale(.large)
    .foregroundColor(.secondary)
  }
}

struct AssetGrid<Item: View, Empty: View>: View {
  private let sourceID: String
  @Binding private var searchText: String
  private let columns: [GridItem]
  private let spacing: CGFloat?
  private let padding: CGFloat?
  @ViewBuilder private let item: (Asset) -> Item
  @ViewBuilder private let empty: (_ search: String) -> Empty

  init(sourceID: String, search: Binding<String> = .constant(""),
       columns: [GridItem], spacing: CGFloat? = nil, padding: CGFloat? = nil,
       @ViewBuilder item: @escaping (Asset) -> Item,
       @ViewBuilder empty: @escaping (_ search: String) -> Empty = { _ in Message.noResults }) {
    self.sourceID = sourceID
    _searchText = search
    _model = .init(initialValue: .search(search.wrappedValue))
    self.columns = columns
    self.spacing = spacing
    self.padding = padding
    self.item = item
    self.empty = empty
  }

  @EnvironmentObject private var interactor: Interactor

  @State private var model: Model
  private var state: Source { model.state }
  private var assets: [Asset] { model.assets }

  private func search(_ text: String) {
    model.search(text)
  }

  private func retry() {
    model.retry()
  }

  private func loadMoreContentIfNeeded(currentItem asset: Asset) {
    let threshold = assets.dropLast(20).last ?? assets.last
    if asset.id == threshold?.id {
      model.loadNextPage()
    }
  }

  @ViewBuilder private var scrollView: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: spacing) {
        ForEach(assets) { asset in
          item(asset)
            .onAppear {
              loadMoreContentIfNeeded(currentItem: asset)
            }
        }
        if case .loading = state {
          ProgressIndicator()
        }
      }
      .padding(.all, padding)
    }
  }

  @ViewBuilder private var messageView: some View {
    Color.clear
      .overlay {
        switch state {
        case .loading: ProgressIndicator()
        case .loaded: empty(searchText)
        case .error:
          VStack(spacing: 30) {
            Message.noService
            Button {
              retry()
            } label: {
              Label("Retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
          }
        }
      }
  }

  var body: some View {
    Group {
      if model.isValid {
        scrollView
      } else {
        messageView
      }
    }
    .onChange(of: searchText) { newValue in
      search(newValue)
    }
    .onReceive(.AssetSourceDidChange) { notification in
      guard let userInfo = notification.userInfo,
            let sourceID = userInfo["sourceID"] as? String, sourceID == self.sourceID else {
        return
      }
      search(searchText)
    }
    .task(id: model.id) {
      let id = model.id
      guard case let .loading(query) = model.state, !Task.isCancelled else {
        return
      }
      do {
        let response = try await interactor.findAssets(sourceID: sourceID, query: query.request)
        if Task.isCancelled {
          return
        }
        assert(id == model.id)
        model.loaded(.init(query: query, response: response))
      } catch {
        if Task.isCancelled {
          return
        }
        assert(id == model.id)
        model.error(.init(query: query, error: error))
      }
    }
    .disabled(interactor.isAddingAsset)
  }
}

struct Asset: Identifiable {
  var id: String { result.id }

  var thumbURL: URL? {
    result.thumbURL ?? result.url
  }

  let result: Interactor.AssetResult
}

private struct ProgressIndicator: View {
  var body: some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fit)
  }
}

struct ReloadableAsyncImage<Content: View>: View {
  let asset: Asset
  let sourceID: String
  @ViewBuilder let content: (KFImage) -> Content

  @EnvironmentObject private var interactor: Interactor
  @State private var failed = false

  @ViewBuilder private var progressView: some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fit)
  }

  @ViewBuilder private var imageError: some View {
    Image("custom.photo.badge.exclamationmark", bundle: Bundle.bundle)
      .imageScale(.large)
      .foregroundColor(.secondary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fit)
  }

  var body: some View {
    if failed {
      imageError
    } else {
      content(
        KFImage(asset.thumbURL)
          .retry(maxCount: 3)
          .placeholder { _ in
            progressView.allowsHitTesting(false)
          }
          .onFailure { _ in
            failed = true
          }
          .fade(duration: 0.15)
      )
      .onTapGesture {
        interactor.assetTapped(asset.result, from: sourceID)
      }
      .allowsHitTesting(!failed)
      .accessibilityLabel(asset.result.label ?? "")
    }
  }
}

private extension AssetGrid {
  struct Query: Equatable {
    let text: String
    let page: Int

    init(_ text: String = "", page: Int = 0) {
      self.text = text
      self.page = page
    }

    var request: Interactor.AssetQueryData {
      .init(query: text, page: page, locale: "en", perPage: 30)
    }
  }

  struct Result {
    /// The used `query` that produced the `response`.
    let query: Query
    let response: Interactor.AssetQueryResult

    var hasNextPage: Bool {
      response.nextPage > 0
    }

    var nextPage: AssetGrid.Query {
      .init(query.text, page: response.nextPage)
    }
  }

  struct Error {
    /// The used `query` that produced the `error`.
    let query: Query
    let error: Swift.Error
  }

  enum Source {
    case loading(Query)
    case loaded(Result)
    case error(Error)
  }

  struct Assets {
    var ids: Set<String>
    var assets: [Asset]

    init() {
      ids = []
      assets = []
    }

    init(_ result: AssetGrid.Result) {
      var ids = Set<String>()
      var assets = [Asset]()

      result.response.assets
        .map { Asset(result: $0) }
        .forEach {
          if ids.contains($0.id) {
            print("Ignoring duplicate asset with id: \($0.id)")
          } else {
            ids.insert($0.id)
            assets.append($0)
          }
        }

      self.ids = ids
      self.assets = assets
    }

    mutating func append(_ other: Assets) {
      assets.append(contentsOf: other.assets.filter {
        if ids.contains($0.id) {
          print("Ignoring duplicate asset with id: \($0.id)")
          return false
        } else {
          return true
        }
      })
      ids = ids.union(other.ids)
    }
  }

  struct Model {
    let id: UUID
    let state: Source
    private let _assets: Assets
    var assets: [Asset] { _assets.assets }

    private init(_ id: UUID, _ source: Source, _ assets: Assets) {
      self.id = id
      state = source
      _assets = assets
    }

    static func search(_ text: String) -> Self {
      .init(UUID(), .loading(.init(text)), AssetGrid.Assets())
    }

    mutating func search(_ text: String) {
      self = .search(text)
    }

    mutating func loaded(_ result: AssetGrid.Result) {
      var assets = _assets
      assets.append(AssetGrid.Assets(result))
      self = .init(id, .loaded(result), assets)
    }

    mutating func loadNextPage() {
      if case let .loaded(result) = state, result.hasNextPage {
        self = .init(UUID(), .loading(result.nextPage), _assets)
      }
    }

    mutating func retry() {
      if case let .error(error) = state {
        self = .init(UUID(), .loading(error.query), _assets)
      }
    }

    mutating func error(_ error: AssetGrid.Error) {
      self = .init(id, .error(error), _assets)
    }

    var isValid: Bool {
      if case .error = state {
        return false
      } else {
        return !assets.isEmpty
      }
    }
  }
}
