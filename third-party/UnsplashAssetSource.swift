import Foundation
import IMGLYEngine

// highlight-unsplash-api-creation
public final class UnsplashAssetSource: NSObject {
  private lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  private let host: String
  private let path: String

  public static let defaultHost = Secrets.unsplashHost

  public init(host: String = defaultHost, path: String = "/unsplashProxy") {
    self.host = host
    self.path = path
  }

  private struct Endpoint {
    let path: String
    let query: [URLQueryItem]

    static func search(queryData: AssetQueryData) -> Self {
      Endpoint(
        path: "/search/photos",
        query: [
          .init(name: "query", value: queryData.query),
          .init(name: "page", value: String(queryData.page + 1)),
          .init(name: "per_page", value: String(queryData.perPage)),
          .init(name: "content_filter", value: "high")
        ]
      )
    }

    static func list(queryData: AssetQueryData) -> Self {
      Endpoint(
        path: "/photos",
        query: [
          .init(name: "order_by", value: "popular"),
          .init(name: "page", value: String(queryData.page + 1)),
          .init(name: "per_page", value: String(queryData.perPage)),
          .init(name: "content_filter", value: "high")
        ]
      )
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
}

// highlight-unsplash-api-creation

extension UnsplashAssetSource: AssetSource {
  public static let id = "ly.img.asset.source.unsplash"

  public var id: String {
    Self.id
  }

  // Silences warning: "Non-sendable type '(any URLSessionTaskDelegate)?' exiting main actor-isolated context in call to
  // non-isolated instance method 'data(from:delegate:)' cannot cross actor boundary"
  private static let get: (URL) async throws -> (Data, URLResponse) = URLSession.shared.data

  public func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    // highlight-unsplash-query
    let endpoint: Endpoint = queryData.query?
      .isEmpty ?? true ? .list(queryData: queryData) : .search(queryData: queryData)
    // highlight-unsplash-query

    let data = try await Self.get(endpoint.url(with: host, path: path)!).0

    // highlight-unsplash-result-mapping
    if queryData.query?.isEmpty ?? true {
      let response = try decoder.decode(UnsplashListResponse.self, from: data)
      let nextPage = queryData.page + 1

      return .init(
        assets: response.map(AssetResult.init),
        currentPage: queryData.page,
        nextPage: nextPage,
        total: -1
      )
    } else {
      let response = try decoder.decode(UnsplashSearchResponse.self, from: data)
      let (results, total, totalPages) = (response.results, response.total ?? 0, response.totalPages ?? 0)
      let nextPage = (queryData.page + 1) == totalPages ? -1 : queryData.page + 1

      return .init(
        assets: results.map(AssetResult.init),
        currentPage: queryData.page,
        nextPage: nextPage,
        total: total
      )
    }
    // highlight-unsplash-result-mapping
  }

  public var supportedMIMETypes: [String]? {
    [MIMEType.jpeg.rawValue]
  }

  // highlight-unsplash-credits-license
  public var credits: AssetCredits? {
    .init(
      name: "Unsplash",
      url: URL(string: "https://unsplash.com/")!
    )
  }

  public var license: AssetLicense? {
    .init(
      name: "Unsplash license (free)",
      url: URL(string: "https://unsplash.com/license")!
    )
  }
  // highlight-unsplash-credits-license
}

extension AssetResult {
  // highlight-translateToAssetResult
  convenience init(image: UnsplashImage) {
    self.init(
      // highlight-result-id
      id: image.id,
      // highlight-result-id
      // highlight-result-locale
      locale: "en",
      // highlight-result-locale
      // highlight-result-label
      label: image.description ?? image.altDescription,
      // highlight-result-label
      // highlight-result-tags
      tags: image.tags?.compactMap(\.title),
      // highlight-result-tags
      // highlight-result-meta
      meta: [
        // highlight-result-uri
        "uri": image.urls.full.absoluteString,
        // highlight-result-uri
        // highlight-result-thumbUri
        "thumbUri": image.urls.thumb.absoluteString,
        // highlight-result-thumbUri
        // highlight-result-blockType
        "blockType": DesignBlockType.graphic.rawValue,
        // highlight-result-blockType
        // highlight-result-fillType
        "fillType": FillType.image.rawValue,
        // highlight-result-fillType
        // highlight-result-shapeType
        "shapeType": ShapeType.rect.rawValue,
        // highlight-result-shapeType
        // highlight-result-kind
        "kind": "image",
        // highlight-result-kind
        // highlight-result-size
        "width": String(image.width),
        "height": String(image.height)
        // highlight-result-size
      ],
      // highlight-result-meta
      // highlight-result-context
      context: .init(sourceID: "unsplash"),
      // highlight-result-context
      // highlight-result-credits
      credits: .init(name: image.user.name!, url: image.user.links?.html),
      // highlight-result-credits
      // highlight-result-utm
      utm: .init(source: "CE.SDK Demo", medium: "referral")
      // highlight-result-utm
    )
  }
  // highlight-translateToAssetResult
}
