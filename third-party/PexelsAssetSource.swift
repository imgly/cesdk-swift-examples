import Foundation
import IMGLYEngine

// highlight-pexels-api-creation
public final class PexelsAssetSource: NSObject {
  private let decoder = JSONDecoder()
  private let apiKey: String

  public init(apiKey: String) {
    self.apiKey = apiKey
  }

  private struct Endpoint {
    let path: String
    let query: [URLQueryItem]

    static func search(queryData: AssetQueryData) -> Self {
      Endpoint(
        path: "/v1/search",
        query: [
          .init(name: "query", value: queryData.query),
          .init(name: "page", value: String(queryData.page + 1)),
          .init(name: "per_page", value: String(queryData.perPage)),
        ],
      )
    }

    static func curated(queryData: AssetQueryData) -> Self {
      Endpoint(
        path: "/v1/curated",
        query: [
          .init(name: "page", value: String(queryData.page + 1)),
          .init(name: "per_page", value: String(queryData.perPage)),
        ],
      )
    }

    var url: URL? {
      var components = URLComponents()
      components.scheme = "https"
      components.host = "api.pexels.com"
      components.path = path
      components.queryItems = query
      return components.url
    }
  }
}

// highlight-pexels-api-creation

extension PexelsAssetSource: AssetSource {
  // highlight-pexels-find-assets
  public static let id = "pexels"

  public var id: String {
    Self.id
  }

  public func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    let endpoint: Endpoint = queryData.query?
      .isEmpty ?? true ? .curated(queryData: queryData) : .search(queryData: queryData)

    var request = URLRequest(url: endpoint.url!)
    request.setValue(apiKey, forHTTPHeaderField: "Authorization")
    let data = try await URLSession.shared.data(for: request).0

    let response = try decoder.decode(PexelsSearchResponse.self, from: data)
    let hasNextPage = response.nextPage != nil && !response.photos.isEmpty

    return .init(
      assets: response.photos.map(AssetResult.init),
      currentPage: queryData.page,
      nextPage: hasNextPage ? queryData.page + 1 : -1,
      total: response.totalResults ?? -1,
    )
  }

  // highlight-pexels-find-assets

  public var supportedMIMETypes: [String]? {
    [MIMEType.jpeg.rawValue]
  }

  // highlight-pexels-credits-license
  public var credits: AssetCredits? {
    .init(
      name: "Pexels",
      url: URL(string: "https://www.pexels.com/")!,
    )
  }

  public var license: AssetLicense? {
    .init(
      name: "Pexels license (free)",
      url: URL(string: "https://www.pexels.com/license/")!,
    )
  }
  // highlight-pexels-credits-license
}

private extension AssetResult {
  // highlight-pexels-translate
  convenience init(photo: PexelsPhoto) {
    self.init(
      id: String(photo.id),
      locale: "en",
      label: photo.alt,
      meta: [
        "uri": photo.src.original.absoluteString,
        "thumbUri": photo.src.medium.absoluteString,
        "blockType": DesignBlockType.graphic.rawValue,
        "fillType": FillType.image.rawValue,
        "shapeType": ShapeType.rect.rawValue,
        "kind": "image",
        "width": String(photo.width),
        "height": String(photo.height),
      ],
      context: .init(sourceID: PexelsAssetSource.id),
      credits: .init(
        name: photo.photographer,
        url: photo.photographerURL.flatMap(URL.init(string:)),
      ),
      utm: .init(source: "CE.SDK Demo", medium: "referral"),
    )
  }
  // highlight-pexels-translate
}
