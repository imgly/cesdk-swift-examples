import Foundation
import IMGLYEngine

public final class RemoteAssetSource: NSObject {
  public enum Path: String, CaseIterable, Sendable {
    case imagePexels = "/api/assets/v1/image-pexels"
    case imageUnsplash = "/api/assets/v1/image-unsplash"
    case videoPexels = "/api/assets/v1/video-pexels"
    case videoGiphy = "/api/assets/v1/video-giphy"
  }

  private weak var engine: Engine?
  private let host: String
  private let path: String
  private let decoder = JSONDecoder()
  private let manifest: RAS.Manifest

  public convenience init(engine: Engine, host: String, path: Path) async throws {
    try await self.init(engine: engine, host: host, path: path.rawValue)
  }

  public init(engine: Engine, host: String, path: String) async throws {
    self.engine = engine
    self.host = host
    self.path = path

    let url = Endpoint.manifest.url(with: host, path: path)!
    let data = try await Self.get(url).0 // Should check HTTPURLResponse.statusCode
    manifest = try decoder.decode(RAS.ManifestData.self, from: data).data
  }

  private struct Endpoint {
    let path: String
    let query: [URLQueryItem]

    static var manifest: Self {
      .init(path: "/", query: [])
    }

    static func assets(queryData: AssetQueryData) -> Self {
      .init(path: "/assets", query: queryData.queryItems)
    }

    func url(with host: String, path: String) -> URL? {
      var components = URLComponents()
      components.scheme = "https"
      components.host = host
      components.path = path + self.path
      components.queryItems = query
      return components.url
    }
  }

  // Silences warning: "Non-sendable type '(any URLSessionTaskDelegate)?' exiting main actor-isolated context in call to
  // non-isolated instance method 'data(from:delegate:)' cannot cross actor boundary"
  private static let get: (URL) async throws -> (Data, URLResponse) = URLSession.shared.data
}

// MARK: - AssetSource

extension RemoteAssetSource: AssetSource, Sendable {
  public var id: String { manifest.id }

  public func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    let url = Endpoint.assets(queryData: queryData).url(with: host, path: path)!
    let data = try await Self.get(url).0 // Should check HTTPURLResponse.statusCode
    let result = try decoder.decode(RAS.AssetQueryResultData.self, from: data).data
    return .init(ras: result, sourceID: id)
  }

  @MainActor
  public func apply(asset: AssetResult) async throws -> NSNumber? {
    guard let engine, let id = try await engine.asset.defaultApplyAsset(assetResult: asset) else {
      return nil
    }

    try await engine.block.ensureAssetDuration(id, asset: asset)
    try engine.block.ensureMetadataKeys(id, asset: asset, sourceID: manifest.id)

    return .init(value: id)
  }

  @MainActor
  public func applyToBlock(asset: AssetResult, block: DesignBlockID) async throws {
    guard let engine else {
      return
    }

    try await engine.asset.defaultApplyAssetToBlock(assetResult: asset, block: block)
    try engine.block.ensureMetadataKeys(block, asset: asset, sourceID: manifest.id)
  }

  public var supportedMIMETypes: [String]? { manifest.supportedMimeTypes }

  public var credits: AssetCredits? { .init(ras: manifest.credits) }

  public var license: AssetLicense? { .init(ras: manifest.license) }
}

// MARK: - Decodable types

// swiftlint:disable nesting
private enum RAS {
  struct ManifestData: Decodable {
    let data: Manifest // Should be optional and additional error field added
  }

  struct Manifest: Decodable {
    let id: String
    let name: [IMGLYEngine.Locale: String]
    var canGetGroups: Bool? = false
    let credits: AssetCredits?
    let license: AssetLicense?
    var canAddAsset: Bool? = false
    var canRemoveAsset: Bool = false
    var supportedMimeTypes: [String]? = []
  }

  struct AssetCredits: Decodable {
    let name: String
    let url: String?
  }

  struct AssetLicense: Decodable {
    let name: String
    let url: String?
  }

  struct AssetUTM: Decodable {
    let source: String?
    let medium: String?
  }

  struct AssetResult: Decodable {
    // IMGLYEngine.Asset
    let id: String
    let groups: IMGLYEngine.Groups?
    let meta: [String: MetaValue]?
    let payload: AssetPayload?

    enum MetaValue: Decodable {
      case string(String)
      case int(Int)
      case float(Float)

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
          self = .string(value)
        } else if let value = try? container.decode(Int.self) {
          self = .int(value)
        } else if let value = try? container.decode(Float.self) {
          self = .float(value)
        } else {
          throw DecodingError.typeMismatch(
            Self.self,
            .init(codingPath: container.codingPath, debugDescription: "Unsupported meta value.")
          )
        }
      }
    }

    // IMGLYEngine.AssetResult
    let locale: IMGLYEngine.Locale?
    let label: String?
    let tags: [String]?
    // let context: IMGLYEngine.AssetContext
    let credits: AssetCredits?
    let license: AssetLicense?
    let utm: AssetUTM?
  }

  struct AssetQueryResultData: Decodable {
    let data: AssetQueryResult // Should be optional and additional error field added
  }

  struct AssetQueryResult: Decodable {
    let assets: [AssetResult]
    let currentPage: Int
    let nextPage: Int? // Not optional in IMGLYEngine.AssetQueryResult
    let total: Int
  }
}

// MARK: - Engine extensions

extension Engine {
  func addRemoteAssetSources(
    host: String,
    paths: Set<RemoteAssetSource.Path> = Set(RemoteAssetSource.Path.allCases)
  ) async throws -> [RemoteAssetSource.Path: String] {
    let sources = try await addRemoteAssetSources(host: host, paths: Set(paths.map(\.rawValue)))

    return .init(uniqueKeysWithValues: sources.compactMap { path, sourceID in
      guard let path = RemoteAssetSource.Path(rawValue: path) else {
        return nil
      }
      return (path, sourceID)
    })
  }

  func addRemoteAssetSources(host: String, paths: Set<String>) async throws -> [String: String] {
    let sources =
      await withThrowingTaskGroup(of: (String, RemoteAssetSource).self) { group -> [String: RemoteAssetSource] in
        for path in paths {
          group.addTask {
            let source = try await RemoteAssetSource(engine: self, host: host, path: path)
            return (path, source)
          }
        }

        var sources = [String: RemoteAssetSource]()

        while let result = await group.nextResult() {
          if let source = try? result.get() {
            sources[source.0] = source.1
          }
        }

        return sources
      }

    return try sources.mapValues { source in
      try asset.addSource(source)
      return source.id
    }
  }
}

private extension AssetQueryData {
  var queryItems: [URLQueryItem] {
    var items = [URLQueryItem]()
    func append(name: String, value: String?) {
      if let value, !value.isEmpty {
        items.append(.init(name: name, value: value))
      }
    }
    func append(name: String, value values: [String]?) {
      let name = name + "[]"
      values?.forEach {
        items.append(.init(name: name, value: $0))
      }
    }
    append(name: "query", value: query)
    append(name: "page", value: String(page))
    append(name: "tags", value: tags)
    append(name: "groups", value: groups)
    append(name: "excludedGroups", value: excludedGroups)
    append(name: "locale", value: locale)
    append(name: "perPage", value: String(perPage))
    return items
  }
}

private extension AssetCredits {
  convenience init?(ras: RAS.AssetCredits?) {
    guard let ras else { return nil }
    if let url = ras.url {
      self.init(name: ras.name, url: URL(string: url))
    } else {
      self.init(name: ras.name, url: nil)
    }
  }
}

private extension AssetLicense {
  convenience init?(ras: RAS.AssetLicense?) {
    guard let ras else { return nil }
    if let url = ras.url {
      self.init(name: ras.name, url: URL(string: url))
    } else {
      self.init(name: ras.name, url: nil)
    }
  }
}

private extension AssetUTM {
  convenience init?(ras: RAS.AssetUTM?) {
    guard let ras else { return nil }
    self.init(source: ras.source, medium: ras.medium)
  }
}

private extension AssetResult {
  convenience init(ras: RAS.AssetResult, sourceID: String) {
    let meta: [String: String]? = ras.meta?.mapValues {
      switch $0 {
      case let .string(value):
        return value
      case let .int(value):
        return String(value)
      case let .float(value):
        return String(value)
      }
    }

    self.init(
      id: ras.id,
      locale: ras.locale,
      label: ras.label,
      tags: ras.tags,
      meta: meta,
      payload: ras.payload,
      context: .init(sourceID: sourceID),
      groups: ras.groups,
      credits: .init(ras: ras.credits),
      license: .init(ras: ras.license),
      utm: .init(ras: ras.utm)
    )
  }
}

private extension AssetQueryResult {
  convenience init(ras: RAS.AssetQueryResult, sourceID: String) {
    self.init(
      assets: ras.assets.map { AssetResult(ras: $0, sourceID: sourceID) },
      currentPage: ras.currentPage,
      nextPage: ras.nextPage ?? -1,
      total: ras.total
    )
  }
}

// This will be handled by the engine in the future
private extension BlockAPI {
  enum MetadataKey: String {
    case sourceID = "source/id"
    case assetExternalID = "source/externalId"
  }

  func ensureMetadataKeys(_ id: DesignBlockID, asset: AssetResult, sourceID: String) throws {
    try setMetadata(id, key: MetadataKey.sourceID.rawValue, value: sourceID)
    try setMetadata(id, key: MetadataKey.assetExternalID.rawValue, value: asset.id)
  }

  func ensureAssetDuration(_ id: DesignBlockID, asset: AssetResult) async throws {
    guard asset.meta?["duration"] == nil, try hasFill(id) else {
      return
    }

    let videoFill = try getFill(id)

    guard try getType(videoFill) == FillType.video.rawValue else {
      return
    }

    try await forceLoadAVResource(videoFill)
    let duration = try getAVResourceTotalDuration(videoFill)
    try setDuration(id, duration: duration)
  }
}
