import IMGLYCore
import IMGLYEngine
import SwiftUI

public struct AssetLoader: ViewModifier {
  private let sources: [SourceData]
  @Binding private var search: QueryData

  init(sources: [SourceData], search: Binding<QueryData>) {
    self.sources = sources
    _search = search
    _data = .init(wrappedValue: AssetLoader.Data(model: .search(sources, for: search.wrappedValue)))
  }

  @EnvironmentObject private var interactor: AnyAssetLibraryInteractor
  @StateObject private var data: AssetLoader.Data

  private func search(_ query: QueryData) {
    data.model.search(sources, for: query)
  }

  public func body(content: Content) -> some View {
    content
      .environmentObject(data)
      .preference(key: AssetLoader.TotalResultsKey.self, value: data.model.total)
      .onChange(of: search) { newValue in
        search(newValue)
      }
      .onReceive(.AssetSourceDidChange) { notification in
        guard let userInfo = notification.userInfo,
              let sourceID = userInfo["sourceID"] as? String, sources.contains(where: {
                sourceID == $0.id
              }) else {
          return
        }
        search(search)
      }
      .task(id: data.model.id) {
        let interactor = interactor
        let id = data.model.id
        let results = await withTaskGroup(of: (UUID, AssetLoader.Model)?.self) { group in
          for (uuid, model) in data.model.models {
            guard case let .loading(query) = model.state, !Task.isCancelled else {
              continue
            }
            group.addTask {
              var model = model
              do {
                let response = try await interactor.findAssets(sourceID: query.source.id, query: query.request)
                if Task.isCancelled {
                  return nil
                }
                model.loaded(.init(query: query, response: response))
                return (uuid, model)
              } catch {
                if Task.isCancelled {
                  return nil
                }
                model.error(.init(query: query, error: error))
                return (uuid, model)
              }
            }
          }

          var results = [UUID: Model]()
          results.reserveCapacity(data.model.sources.count)
          for await result in group {
            if Task.isCancelled {
              return results
            }
            if let result {
              results[result.0] = result.1
            }
          }
          return results
        }

        if Task.isCancelled {
          return
        }
        assert(id == data.model.id)
        data.model.fetched(results)
      }
  }
}

public extension AssetLoader {
  struct SourceData: Hashable, Sendable {
    public let id: String
    public let config: QueryData
    let expandGroups: Bool

    public init(id: String, config: QueryData = .init()) {
      self.id = id
      self.config = config
      expandGroups = false
    }

    private init(_ other: Self, expandGroups: Bool) {
      id = other.id
      config = other.config
      self.expandGroups = expandGroups
    }

    func expandedGroups(_ value: Bool) -> Self {
      .init(self, expandGroups: value)
    }

    /// Limits source to `group` and disables `expandGroups`.
    func narrowed(to group: String) -> Self {
      .init(id: id, config: config.narrowed(by: .init(groups: [group])))
    }
  }

  struct QueryData: Hashable, Sendable {
    public let query: String?
    public let tags: [String]?
    public let groups: IMGLYEngine.Groups?
    public let excludedGroups: IMGLYEngine.Groups?
    public let locale: IMGLYEngine.Locale?

    public init(query: String? = nil, tags: [String]? = nil,
                groups: IMGLYEngine.Groups? = nil, excludedGroups: IMGLYEngine.Groups? = nil,
                locale: IMGLYEngine.Locale? = "en") {
      self.query = query
      self.tags = tags
      self.groups = groups
      self.excludedGroups = excludedGroups
      self.locale = locale
    }

    func narrowed(by other: Self) -> Self {
      func intersection(_ lhs: [String]?, _ rhs: [String]?) -> [String]? {
        if let rhs {
          let set = Set<String>(rhs)
          return lhs?.filter { set.contains($0) } ?? rhs
        } else {
          return lhs
        }
      }

      func union(_ lhs: [String]?, _ rhs: [String]?) -> [String]? {
        if let rhs {
          return lhs ?? [] + rhs
        } else {
          return lhs
        }
      }

      return .init(
        query: other.query ?? query,
        tags: intersection(other.tags, tags),
        groups: intersection(other.groups, groups),
        excludedGroups: union(other.excludedGroups, excludedGroups),
        locale: other.locale ?? locale
      )
    }
  }

  struct TotalResultsKey: PreferenceKey {
    public static let defaultValue: Int? = nil
    public static func reduce(value: inout Int?, nextValue: () -> Int?) {
      let lhs = value ?? 0
      let rhs = nextValue() ?? 0
      if lhs < 0 || rhs < 0 {
        value = -1
      } else {
        value = lhs + rhs
      }
    }
  }

  class Data: ObservableObject {
    @Published public var model: Models

    init(model: Models) {
      _model = .init(initialValue: model)
    }
  }

  struct Models {
    // swiftlint:disable:next nesting
    public enum State {
      case loading, loaded, error
    }

    fileprivate let id: UUID

    let sources: [(UUID, SourceData)]
    let models: [UUID: Model]
    public let search: QueryData
    public let state: State

    private init(_ id: UUID, _ sources: [(UUID, SourceData)], _ models: [UUID: Model],
                 _ state: Models.State, _ search: QueryData) {
      self.id = id
      self.sources = sources
      self.models = models
      self.state = state
      self.search = search

      let orderedAssetsBySources = sources.compactMap { uuid, _ in
        if let model = models[uuid] {
          return model.assets
        } else {
          return nil
        }
      }
      assets = Self.alternatingElements(of: orderedAssetsBySources)
    }

    fileprivate static func search(_ sources: [AssetLoader.SourceData], for query: AssetLoader.QueryData) -> Self {
      let sources = sources.map { (UUID(), $0) }
      var models = [UUID: AssetLoader.Model]()
      for source in sources {
        models[source.0] = .search(source.1, query)
      }
      return .init(UUID(), sources, models, .loading, query)
    }

    fileprivate mutating func search(_ sources: [AssetLoader.SourceData], for query: AssetLoader.QueryData) {
      self = .search(sources, for: query)
    }

    fileprivate mutating func fetched(_ results: [UUID: AssetLoader.Model]) {
      let results = models.merging(results) { _, new in new }
      let error = results.allSatisfy { _, result in
        if case .error = result.state {
          return true
        } else {
          return false
        }
      }
      if error {
        self = .init(id, sources, results, .error, search)
      } else {
        self = .init(id, sources, results, .loaded, search)
      }
    }

    public mutating func loadNextPage() {
      var models = models
      var willLoadNextPage = false
      for (uuid, _) in sources {
        willLoadNextPage = willLoadNextPage || models[uuid]?.loadNextPage() ?? false
      }
      if willLoadNextPage {
        self = .init(UUID(), sources, models, .loading, search)
      }
    }

    public mutating func retry() {
      var models = models
      var willRetry = false
      for (uuid, _) in sources {
        willRetry = willRetry || models[uuid]?.retry() ?? false
      }
      if willRetry {
        self = .init(UUID(), sources, models, .loading, search)
      }
    }

    public let assets: [AssetLoader.Asset]

    private static func alternatingElements<T>(of arrays: [[T]]) -> [T] {
      let maxCount = arrays.reduce(0) { max($0, $1.count) }
      let totalCount = arrays.reduce(0) { $0 + $1.count }
      var result = [T]()
      result.reserveCapacity(totalCount)

      for i in 0 ..< maxCount {
        for array in arrays where i < array.count {
          result.append(array[i])
        }
      }

      return result
    }

    public var isValid: Bool {
      models.contains { $0.value.isValid }
    }

    public var total: Int {
      models.reduce(0) {
        if $0 < 0 || $1.value.total < 0 {
          return -1
        } else {
          return $0 + $1.value.total
        }
      }
    }
  }

  struct Model: Sendable {
    fileprivate let id: UUID
    public let state: Source
    private let _assets: Assets
    public var assets: [AssetLoader.Asset] { _assets.assets }

    private init(_ id: UUID, _ source: Source, _ assets: Assets) {
      self.id = id
      state = source
      _assets = assets
    }

    fileprivate static func search(_ source: AssetLoader.SourceData, _ data: AssetLoader.QueryData) -> Self {
      .init(UUID(), .loading(.init(source, data)), AssetLoader.Assets())
    }

    fileprivate mutating func search(_ source: AssetLoader.SourceData, _ data: AssetLoader.QueryData) {
      self = .search(source, data)
    }

    fileprivate mutating func loaded(_ result: AssetLoader.Result) {
      var assets = _assets
      assets.append(AssetLoader.Assets(result))
      self = .init(id, .loaded(result), assets)
    }

    public mutating func loadNextPage() -> Bool {
      if case let .loaded(result) = state, result.hasNextPage {
        self = .init(UUID(), .loading(result.nextPage), _assets)
        return true
      } else {
        return false
      }
    }

    public mutating func retry() -> Bool {
      if case let .error(error) = state {
        self = .init(UUID(), .loading(error.query), _assets)
        return true
      } else {
        return false
      }
    }

    fileprivate mutating func error(_ error: AssetLoader.Error) {
      self = .init(id, .error(error), _assets)
    }

    public var isValid: Bool {
      if case .error = state {
        return false
      } else {
        return !assets.isEmpty
      }
    }

    public var total: Int {
      if case let .loaded(result) = state {
        return result.response.total
      } else {
        return 0
      }
    }
  }

  struct Query: Equatable, Sendable {
    public let source: SourceData
    public let data: QueryData
    fileprivate let page: Int
    fileprivate let perPage: Int

    fileprivate init(_ source: SourceData, _ data: QueryData, page: Int = 0, perPage: Int = 30) {
      self.source = source
      self.data = data
      self.page = page
      self.perPage = perPage
    }

    fileprivate var request: AssetQueryData {
      let data = data.narrowed(by: source.config)
      return .init(query: data.query, page: page,
                   tags: data.tags, groups: data.groups, excludedGroups: data.excludedGroups,
                   locale: data.locale, perPage: perPage)
    }
  }

  struct Result: Sendable {
    /// The used `query` that produced the `response`.
    public let query: Query
    public let response: AssetQueryResult

    public var hasNextPage: Bool {
      response.nextPage > 0
    }

    fileprivate var nextPage: AssetLoader.Query {
      .init(query.source, query.data, page: response.nextPage, perPage: query.perPage)
    }
  }

  struct Error: Sendable {
    /// The used `query` that produced the `error`.
    public let query: Query
    public let error: Swift.Error
  }

  enum Source: Sendable {
    case loading(Query)
    case loaded(Result)
    case error(Error)
  }

  struct Asset: Identifiable, Sendable {
    // Don't rely on `result.context.sourceID` as this value depends on the (user) implementation of `findAssets`.
    public let sourceID: String
    public let result: AssetResult

    public var thumbURLorURL: URL? {
      result.thumbURL ?? result.url
    }

    public var id: String {
      sourceID + result.id // Make sure that id is really unique across sources.
    }
  }
}

private extension AssetLoader {
  struct Assets: Sendable {
    private var ids: Set<String>
    var assets: [Asset]

    init() {
      ids = []
      assets = []
    }

    init(_ result: AssetLoader.Result) {
      var ids = Set<String>()
      var assets = [Asset]()

      result.response.assets
        .map { Asset(sourceID: result.query.source.id, result: $0) }
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
}

struct AssetLoader_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
