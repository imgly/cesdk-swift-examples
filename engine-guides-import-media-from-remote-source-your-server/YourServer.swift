import Foundation
import IMGLYEngine

// A custom asset source backed by your backend. Implement the `AssetSource`
// protocol: expose a unique `id` and a `findAssets(queryData:)` method that
// returns paginated results. This example returns a fixed in-memory catalog so
// it runs without a network connection; `fetchAssetsFromBackend(...)` below
// shows the production shape that requests the same data from your API.
final class BackendAssetSource: NSObject, AssetSource {
  let id: String
  private let catalog: [AssetResult]

  var supportedMIMETypes: [String]? {
    nil
  }

  var credits: AssetCredits? {
    nil
  }

  var license: AssetLicense? {
    nil
  }

  init(id: String) {
    self.id = id

    // highlight-yourServer-image-asset
    let image = AssetResult(
      id: "photo-1",
      label: "Mountain Landscape",
      tags: ["nature", "mountain", "landscape"],
      meta: [
        "uri": "https://cdn.example.com/assets/photo-1.jpg",
        "thumbUri": "https://cdn.example.com/thumbs/photo-1.jpg",
        "blockType": DesignBlockType.graphic.rawValue,
        "fillType": FillType.image.rawValue,
        "width": "1920",
        "height": "1080",
      ],
      context: .init(sourceID: id),
    )
    // highlight-yourServer-image-asset

    // highlight-yourServer-video-asset
    let video = AssetResult(
      id: "clip-1",
      label: "City Timelapse",
      tags: ["city", "timelapse"],
      meta: [
        "uri": "https://cdn.example.com/assets/clip-1.mp4",
        "thumbUri": "https://cdn.example.com/thumbs/clip-1.jpg",
        "blockType": DesignBlockType.graphic.rawValue,
        "fillType": FillType.video.rawValue,
        "duration": "12.5",
        "width": "1920",
        "height": "1080",
      ],
      context: .init(sourceID: id),
    )
    // highlight-yourServer-video-asset

    // highlight-yourServer-audio-asset
    let audio = AssetResult(
      id: "track-1",
      label: "Ambient Loop",
      tags: ["ambient", "loop"],
      meta: [
        "uri": "https://cdn.example.com/assets/track-1.m4a",
        "thumbUri": "https://cdn.example.com/thumbs/track-1.jpg",
        "blockType": DesignBlockType.audio.rawValue,
        "mimeType": "audio/x-m4a",
        "duration": "30.0",
      ],
      context: .init(sourceID: id),
    )
    // highlight-yourServer-audio-asset

    // highlight-yourServer-sticker-asset
    let sticker = AssetResult(
      id: "sticker-1",
      label: "Star Badge",
      tags: ["badge", "star"],
      meta: [
        "uri": "https://cdn.example.com/assets/sticker-1.png",
        "thumbUri": "https://cdn.example.com/thumbs/sticker-1.png",
        "blockType": DesignBlockType.graphic.rawValue,
        "fillType": FillType.image.rawValue,
        "kind": "sticker",
        "width": "512",
        "height": "512",
      ],
      context: .init(sourceID: id),
    )
    // highlight-yourServer-sticker-asset

    catalog = [image, video, audio, sticker]
    super.init()
  }

  // highlight-yourServer-find-assets
  func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    let term = (queryData.query ?? "").lowercased()
    let matches = term.isEmpty ? catalog : catalog.filter { asset in
      (asset.label?.lowercased().contains(term) ?? false)
        || (asset.tags?.contains { $0.lowercased().contains(term) } ?? false)
    }

    let start = queryData.page * queryData.perPage
    let page = Array(matches.dropFirst(start).prefix(queryData.perPage))
    let hasMore = start + page.count < matches.count

    return AssetQueryResult(
      assets: page,
      currentPage: queryData.page,
      nextPage: hasMore ? queryData.page + 1 : -1,
      total: matches.count,
    )
  }
  // highlight-yourServer-find-assets
}

@MainActor
func yourServer(engine: Engine) async throws {
  // highlight-yourServer-register
  let source = BackendAssetSource(id: "my-backend")
  try engine.asset.addSource(source)

  let results = try await engine.asset.findAssets(
    sourceID: source.id,
    query: .init(query: "", page: 0, perPage: 10),
  )
  print("Loaded \(results.assets.count) of \(results.total) assets from the backend source")
  // highlight-yourServer-register

  // highlight-yourServer-template-source
  try engine.asset.addLocalSource(sourceID: "my-backend-templates", applyAsset: { [weak engine] asset in
    guard let engine, let uri = asset.meta?["uri"], let url = URL(string: uri) else {
      return nil
    }
    try await engine.scene.applyTemplate(from: url)
    return nil
  })

  let template = AssetDefinition(
    id: "promo-card",
    meta: [
      "uri": "https://cdn.example.com/templates/promo-card.scene",
      "thumbUri": "https://cdn.example.com/thumbs/promo-card.jpg",
      "blockType": DesignBlockType.scene.rawValue,
    ],
    label: ["en": "Promo Card"],
  )
  try engine.asset.addAsset(to: "my-backend-templates", asset: template)
  // highlight-yourServer-template-source

  // highlight-yourServer-json-source
  let manifest = """
  {
    "version": "1.0.0",
    "id": "my-backend-stickers",
    "assets": [
      {
        "id": "star-badge",
        "label": { "en": "Star Badge" },
        "tags": { "en": ["badge", "star"] },
        "meta": {
          "uri": "{{base_url}}/stickers/star-badge.png",
          "thumbUri": "{{base_url}}/stickers/star-badge.png",
          "blockType": "//ly.img.ubq/graphic",
          "fillType": "//ly.img.ubq/fill/image",
          "kind": "sticker",
          "width": "512",
          "height": "512"
        }
      }
    ]
  }
  """
  let staticSourceID = try engine.asset.addLocalAssetSourceFromJSON(
    manifest,
    basePath: "https://cdn.example.com/assets",
  )
  print("Registered static source: \(staticSourceID)")
  // highlight-yourServer-json-source
}

// MARK: - Fetching from your backend

// A Decodable model that matches the JSON your `/assets` endpoint returns.
private struct BackendAssetPage: Decodable {
  struct Item: Decodable {
    let id: String
    let label: String
    let uri: String
    let thumbUri: String
    let width: Int
    let height: Int
  }

  let assets: [Item]
  let total: Int
  let currentPage: Int
  let nextPage: Int?
}

// The production shape of `findAssets(queryData:)`: forward the query to your
// API, decode the response, and map each row into an `AssetResult`. Called from
// `BackendAssetSource.findAssets(queryData:)` in a real integration.
@MainActor
func fetchAssetsFromBackend(
  host: URL,
  sourceID: String,
  queryData: AssetQueryData,
) async throws -> AssetQueryResult {
  // highlight-yourServer-backend-fetch
  var components = URLComponents(
    url: host.appendingPathComponent("assets"),
    resolvingAgainstBaseURL: false,
  )!
  components.queryItems = [
    URLQueryItem(name: "query", value: queryData.query),
    URLQueryItem(name: "page", value: String(queryData.page)),
    URLQueryItem(name: "perPage", value: String(queryData.perPage)),
  ]

  var request = URLRequest(url: components.url!)
  request.setValue("Bearer YOUR_API_TOKEN", forHTTPHeaderField: "Authorization")
  let (data, _) = try await URLSession.shared.data(for: request)
  let page = try JSONDecoder().decode(BackendAssetPage.self, from: data)

  let assets = page.assets.map { item in
    AssetResult(
      id: item.id,
      label: item.label,
      meta: [
        "uri": item.uri,
        "thumbUri": item.thumbUri,
        "blockType": DesignBlockType.graphic.rawValue,
        "fillType": FillType.image.rawValue,
        "width": String(item.width),
        "height": String(item.height),
      ],
      context: .init(sourceID: sourceID),
    )
  }

  return AssetQueryResult(
    assets: assets,
    currentPage: page.currentPage,
    nextPage: page.nextPage ?? -1,
    total: page.total,
  )
  // highlight-yourServer-backend-fetch
}
