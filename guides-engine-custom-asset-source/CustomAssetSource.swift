import Foundation
import IMGLYEngine

@MainActor
func customAssetSource(engine: Engine) async throws {
  // highlight-unsplash-definition
  let source = UnsplashAPI()
  try engine.asset.addSource(source)
  // highlight-unsplash-definition

  // highlight-unsplash-findAssets
  let list = try await engine.asset.findAssets(
    sourceID: "ly.img.asset.source.unsplash",
    query: .init(query: "", page: 1, perPage: 10)
  )
  // highlight-unsplash-findAssets
  // highlight-unsplash-list
  let search = try await engine.asset.findAssets(
    sourceID: "ly.img.asset.source.unsplash",
    query: .init(query: "banana", page: 1, perPage: 10)
  )
  // highlight-unsplash-list
}

// highlight-unsplash-api-creation
final class UnsplashAPI: NSObject {
  private lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  private struct Endpoint {
    let host = Secrets.unsplashHost

    let path: String
    let query: [URLQueryItem]

    static func search(queryData: AssetQueryData) -> Self {
      Endpoint(
        path: "/photos/search/photos",
        query: [
          URLQueryItem(name: "query", value: queryData.query),
          URLQueryItem(name: "page", value: String(queryData.page)),
          URLQueryItem(name: "perPage", value: String(queryData.perPage))
        ]
      )
    }

    static func list(queryData: AssetQueryData) -> Self {
      Endpoint(
        path: "/photos/photos",
        query: [
          URLQueryItem(name: "order_by", value: "popular"),
          URLQueryItem(name: "page", value: String(queryData.page)),
          URLQueryItem(name: "perPage", value: String(queryData.perPage))
        ]
      )
    }

    var url: URL? {
      var components = URLComponents()
      components.scheme = "https"
      components.host = host
      components.path = path
      components.queryItems = query
      return components.url
    }
  }
}

// highlight-unsplash-api-creation

extension UnsplashAPI: AssetSource {
  var id: String {
    "ly.img.asset.source.unsplash"
  }

  func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    let page = queryData.page == 0 ? 1 : queryData.page

    // highlight-unsplash-query
    let endpoint: Endpoint = queryData.query?
      .isEmpty ?? true ? .list(queryData: queryData) : .search(queryData: queryData)
    // highlight-unsplash-query

    let data = try await URLSession.shared.data(from: endpoint.url!).0

    // highlight-unsplash-result-mapping
    if queryData.query?.isEmpty ?? true {
      let response = try decoder.decode(UnsplashListResponse.self, from: data)
      let nextPage = page + 1

      return .init(
        assets: response.map(AssetResult.init),
        currentPage: queryData.page,
        nextPage: nextPage,
        total: 0
      )
    } else {
      let response = try decoder.decode(UnsplashSearchResponse.self, from: data)
      let (results, total) = (response.results, response.total ?? 0)
      let totalFetched = (queryData.page - 1) * queryData.perPage + results.count
      let nextPage = totalFetched < total ? page + 1 : -1

      return .init(
        assets: response.results.map(AssetResult.init),
        currentPage: queryData.page,
        nextPage: nextPage,
        total: response.total ?? 0
      )
    }
    // highlight-unsplash-result-mapping
  }

  // highlight-unsplash-credits-license
  var credits: AssetCredits? {
    .init(
      name: "Unsplash",
      url: URL(string: "https://unsplash.com/")!
    )
  }

  var license: AssetLicense? {
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
      label: image.resultDescription ?? image.altDescription,
      // highlight-result-label
      // highlight-result-tags
      tags: image.tags?.compactMap(\.title),
      // highlight-result-tags
      // highlight-result-thumbUri
      thumbURI: image.urls.thumb,
      // highlight-result-thumbUri
      // highlight-result-size
      width: Float(image.width),
      height: Float(image.height),
      // highlight-result-size
      // highlight-result-uri
      meta: ["uri": image.urls.full.absoluteString],
      // highlight-result-uri
      // highlight-result-context
      context: .init(sourceID: "unsplash", createdByRole: ""),
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
