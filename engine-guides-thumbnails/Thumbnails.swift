import Foundation
import IMGLYEngine

// MARK: - Custom Asset Source

// highlight-thumbnails-customSource
// A custom asset source backed by an external photo service.
private final class StockPhotoSource: NSObject, AssetSource {
  let id = "stock-photos"
  var supportedMIMETypes: [String]? { ["image/jpeg"] }
  var credits: AssetCredits? { nil }
  var license: AssetLicense? { nil }

  private let host = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.78.0-rc.0/assets"

  func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    let asset = AssetResult(
      id: "mountain-lake",
      label: "Mountain Lake",
      meta: [
        "uri": "\(host)/ly.img.image/images/sample_1.jpg",
        "thumbUri": "\(host)/ly.img.image/thumbnails/sample_1.jpg",
        "blockType": "//ly.img.ubq/graphic",
        "fillType": "//ly.img.ubq/fill/image",
      ],
      context: AssetContext(sourceID: id),
    )
    return AssetQueryResult(
      assets: [asset],
      currentPage: queryData.page,
      nextPage: -1,
      total: 1,
    )
  }
}

// highlight-thumbnails-customSource

// MARK: - Guide

@MainActor
func thumbnails(engine: Engine) async throws {
  // Base path the example asset URIs are built from. Replace with your own host.
  let baseURL = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.78.0-rc.0/assets"

  // highlight-thumbnails-basic
  try engine.asset.addLocalSource(sourceID: "my-images")

  let image = AssetDefinition(
    id: "scenic-landscape",
    meta: [
      "uri": "\(baseURL)/ly.img.image/images/sample_1.jpg",
      "thumbUri": "\(baseURL)/ly.img.image/thumbnails/sample_1.jpg",
      "blockType": "//ly.img.ubq/graphic",
      "fillType": "//ly.img.ubq/fill/image",
    ],
    label: ["en": "Scenic Landscape"],
  )
  try engine.asset.addAsset(to: "my-images", asset: image)
  // highlight-thumbnails-basic

  // highlight-thumbnails-audioPreview
  try engine.asset.addLocalSource(sourceID: "my-audio", supportedMimeTypes: ["audio/x-m4a"])

  let audio = AssetDefinition(
    id: "ambient-track",
    meta: [
      "uri": "\(baseURL)/ly.img.audio/audios/dance_harder.m4a",
      "thumbUri": "\(baseURL)/ly.img.audio/thumbnails/dance_harder.jpg",
      "previewUri": "\(baseURL)/ly.img.audio/audios/dance_harder.m4a",
      "mimeType": "audio/x-m4a",
    ],
    label: ["en": "Ambient Track"],
  )
  try engine.asset.addAsset(to: "my-audio", asset: audio)
  // highlight-thumbnails-audioPreview

  // highlight-thumbnails-registerCustomSource
  let stockSource = StockPhotoSource()
  try engine.asset.addSource(stockSource)
  // highlight-thumbnails-registerCustomSource

  // Confirm each source returns its assets with the configured metadata.
  for sourceID in ["my-images", "my-audio", "stock-photos"] {
    let results = try await engine.asset.findAssets(
      sourceID: sourceID,
      query: .init(query: nil, page: 0, perPage: 10),
    )
    print("\(sourceID):", results.total, "asset(s)")
  }
}
