import SwiftUI

struct AssetGrid: View {
  private let sourceID: String
  @Binding private var searchText: String

  init(sourceID: String, search: Binding<String> = .constant("")) {
    self.sourceID = sourceID
    _searchText = search
    _model = .init(initialValue: .search(search.wrappedValue))
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
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 108, maximum: 152), spacing: 2)], spacing: 2) {
        ForEach(assets) { asset in
          ReloadableAsyncImage(asset: asset, sourceID: sourceID)
            .onAppear {
              loadMoreContentIfNeeded(currentItem: asset)
            }
        }
        if case .loading = state {
          ProgressIndicator()
        }
      }
    }
  }

  @ViewBuilder private func label(_ title: LocalizedStringKey, systemImage: String) -> some View {
    VStack(spacing: 10) {
      Image(systemName: systemImage)
      Text(title)
    }
    .imageScale(.large)
    .foregroundColor(.secondary)
  }

  @ViewBuilder private var messageView: some View {
    Color.clear
      .overlay {
        switch state {
        case .loading: ProgressIndicator()
        case .loaded: label("No results found", systemImage: "magnifyingglass")
        case .error:
          VStack(spacing: 30) {
            label("Cannot connect to service", systemImage: "exclamationmark.triangle")
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

private extension AssetGrid {
  private struct ProgressIndicator: View {
    var body: some View {
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
  }

  private struct ReloadableAsyncImage: View {
    let asset: Asset
    let sourceID: String

    @EnvironmentObject private var interactor: Interactor
    @State private var url: URL?
    @State private var phase: AsyncImagePhase?

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

    @ViewBuilder func content(phase: AsyncImagePhase) -> some View {
      Group {
        if let image = phase.image {
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, minHeight: 0)
            .clipped()
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture {
              interactor.assetTapped(asset.result, from: sourceID)
            }
            .accessibilityLabel(asset.result.label ?? "")
        } else if phase.error != nil {
          imageError
            .onTapGesture {
              retry()
            }
        } else {
          ProgressIndicator()
        }
      }
      .onAppear {
        self.phase = phase
      }
    }

    private func retry() {
      url = nil
    }

    var body: some View {
      AsyncImage(url: url) { phase in
        content(phase: phase)
      }
      .onAppear {
        switch phase {
        case .none, .empty:
          // Init AsyncImage
          url = asset.url
        case let .failure(error as NSError):
          if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorCancelled, NSURLErrorNetworkConnectionLost:
              retry()
            default:
              break
            }
          }
        default:
          break
        }
      }
      .onChange(of: url) { newValue in
        if newValue == nil {
          // Reload AsyncImage
          url = asset.url
        }
      }
    }
  }

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

  struct Asset: Identifiable {
    let id = UUID()
    var url: URL? {
      guard let string = result.meta?["thumbUri"] ?? result.meta?["uri"] else {
        return nil
      }
      return URL(string: string)
    }

    let result: Interactor.AssetResult
  }

  enum Source {
    case loading(Query)
    case loaded(Result)
    case error(Error)
  }

  struct Model {
    let id: UUID
    let state: Source
    let assets: [Asset]

    private init(_ id: UUID, _ source: Source, _ assets: [Asset]) {
      self.id = id
      state = source
      self.assets = assets
    }

    static func search(_ text: String) -> Self {
      .init(UUID(), .loading(.init(text)), [])
    }

    mutating func search(_ text: String) {
      self = .search(text)
    }

    mutating func loaded(_ result: AssetGrid.Result) {
      let assets = assets + result.response.assets.map { .init(result: $0) }
      self = .init(id, .loaded(result), assets)
    }

    mutating func loadNextPage() {
      if case let .loaded(result) = state, result.hasNextPage {
        self = .init(UUID(), .loading(result.nextPage), assets)
      }
    }

    mutating func retry() {
      if case let .error(error) = state {
        self = .init(UUID(), .loading(error.query), assets)
      }
    }

    mutating func error(_ error: AssetGrid.Error) {
      self = .init(id, .error(error), assets)
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
