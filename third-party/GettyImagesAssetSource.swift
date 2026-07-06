import Foundation
import IMGLYEngine

// highlight-getty-api-creation
public final class GettyImagesAssetSource: NSObject {
  private let decoder = JSONDecoder()
  private let host: String
  private let path: String

  public init(proxyHost: String, path: String = "/getty-proxy") {
    host = proxyHost
    self.path = path
  }

  private struct Endpoint {
    let query: [URLQueryItem]

    static func search(queryData: AssetQueryData) -> Self {
      Endpoint(
        query: [
          .init(name: "phrase", value: queryData.query),
          // Getty Images pages start at 1, while CE.SDK uses 0-based indices.
          .init(name: "page", value: String(queryData.page + 1)),
          .init(name: "page_size", value: String(queryData.perPage)),
        ],
      )
    }

    func url(host: String, path: String) -> URL? {
      var components = URLComponents()
      components.scheme = "https"
      components.host = host
      components.path = path
      components.queryItems = query
      return components.url
    }
  }
}

// highlight-getty-api-creation

extension GettyImagesAssetSource: AssetSource {
  // highlight-getty-find-assets
  public static let id = "gettyImagesImageAssets"

  public var id: String {
    Self.id
  }

  public func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    guard let url = Endpoint.search(queryData: queryData).url(host: host, path: path) else {
      throw NSError(domain: "GettyImagesAssetSource", code: -1)
    }

    let data = try await URLSession.shared.data(from: url).0
    let response = try decoder.decode(GettyImagesSearchResponse.self, from: data)

    let total = response.resultCount ?? -1
    let loadedSoFar = (queryData.page + 1) * queryData.perPage
    let hasNextPage = !response.images.isEmpty && (total < 0 || loadedSoFar < total)

    return .init(
      assets: response.images.map(AssetResult.init),
      currentPage: queryData.page,
      nextPage: hasNextPage ? queryData.page + 1 : -1,
      total: total,
    )
  }

  // highlight-getty-find-assets

  public var supportedMIMETypes: [String]? {
    [MIMEType.jpeg.rawValue]
  }

  // highlight-getty-credits-license
  public var credits: AssetCredits? {
    .init(
      name: "Getty Images",
      url: URL(string: "https://www.gettyimages.com/")!,
    )
  }

  public var license: AssetLicense? {
    .init(
      name: "Getty Images Content License Agreement",
      url: URL(string: "https://www.gettyimages.com/eula")!,
    )
  }
  // highlight-getty-credits-license
}

private extension AssetResult {
  // highlight-getty-translate
  convenience init(image: GettyImage) {
    // Getty's searchimages display sizes are named (typically "comp", "preview", "thumb").
    // Pick the largest for the imported asset and a smaller one for the library thumbnail so
    // the grid loads lightweight previews instead of full-resolution comps.
    let sizesByName = Dictionary(
      image.displaySizes.map { ($0.name, $0.uri) },
      uniquingKeysWith: { first, _ in first },
    )
    let fullURL = sizesByName["comp"] ?? sizesByName["preview"] ?? image.displaySizes.first?.uri
    let thumbURL = sizesByName["thumb"] ?? sizesByName["preview"] ?? fullURL
    self.init(
      id: image.id,
      locale: "en",
      label: image.title,
      meta: [
        "uri": fullURL?.absoluteString ?? "",
        "thumbUri": thumbURL?.absoluteString ?? "",
        "blockType": DesignBlockType.graphic.rawValue,
        "fillType": FillType.image.rawValue,
        "shapeType": ShapeType.rect.rawValue,
        "kind": "image",
        "width": image.maxDimensions?.width.map(String.init) ?? "",
        "height": image.maxDimensions?.height.map(String.init) ?? "",
      ],
      context: .init(sourceID: GettyImagesAssetSource.id),
    )
  }
  // highlight-getty-translate
}
