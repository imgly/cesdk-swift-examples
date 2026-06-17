import Foundation
import IMGLYEngine

// MARK: - Custom Asset Source

class DemoAssetSource: NSObject, AssetSource {
  let id = "my-assets"
  var supportedMIMETypes: [String]? { nil }
  var credits: AssetCredits? { nil }
  var license: AssetLicense? { nil }

  // Base URL the sample sticker is resolved against.
  let baseURL: URL

  init(baseURL: URL) {
    self.baseURL = baseURL
    super.init()
  }

  // highlight-conceptsAssets-assetDefinition
  var stickerAsset: AssetResult {
    let stickerURI = baseURL
      .appendingPathComponent("ly.img.sticker/images/emoticons/imgly_sticker_emoticons_smile.svg")
      .absoluteString
    return AssetResult(
      id: "sticker-smile",
      label: "Smile Sticker",
      tags: ["emoji", "happy"],
      meta: [
        "uri": stickerURI,
        "thumbUri": stickerURI,
        "blockType": "//ly.img.ubq/graphic",
        "fillType": "//ly.img.ubq/fill/image",
        "width": "62",
        "height": "58",
        "mimeType": "image/svg+xml",
      ],
      context: AssetContext(sourceID: "my-assets"),
      groups: ["stickers"],
    )
  }

  // highlight-conceptsAssets-assetDefinition

  // highlight-conceptsAssets-assetSource
  func findAssets(queryData: AssetQueryData) async throws -> AssetQueryResult {
    AssetQueryResult(
      assets: [stickerAsset],
      currentPage: queryData.page,
      nextPage: -1,
      total: 1,
    )
  }
  // highlight-conceptsAssets-assetSource
}

// MARK: - Guide

@MainActor
func conceptsAssets(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL

  // Register a custom asset source
  let source = DemoAssetSource(baseURL: baseURL)
  try engine.asset.addSource(source)

  // highlight-conceptsAssets-queryAssets
  // Query assets from a registered source
  let results = try await engine.asset.findAssets(
    sourceID: "my-assets",
    query: .init(query: nil, page: 0, perPage: 10),
  )
  print("Found assets:", results.total)
  // highlight-conceptsAssets-queryAssets

  // highlight-conceptsAssets-applyAsset
  // Apply an asset to create a block in the scene
  if let asset = results.assets.first {
    let blockID = try await engine.asset.apply(sourceID: "my-assets", assetResult: asset)
    print("Created block:", blockID as Any)
  }
  // highlight-conceptsAssets-applyAsset

  // highlight-conceptsAssets-localSource
  // Local sources store assets in memory and support dynamic add/remove
  try engine.asset.addLocalSource(sourceID: "uploads", supportedMimeTypes: ["image/svg+xml", "image/png"])

  let uploadedStickerURI = baseURL
    .appendingPathComponent("ly.img.sticker/images/emoticons/imgly_sticker_emoticons_grin.svg")
    .absoluteString
  try engine.asset.addAsset(
    to: "uploads",
    asset: AssetDefinition(
      id: "uploaded-1",
      meta: [
        "uri": uploadedStickerURI,
        "thumbUri": uploadedStickerURI,
        "blockType": "//ly.img.ubq/graphic",
        "fillType": "//ly.img.ubq/fill/image",
        "mimeType": "image/svg+xml",
      ],
      label: ["en": "Grin Sticker"],
    ),
  )
  // highlight-conceptsAssets-localSource

  // highlight-conceptsAssets-sourceEvents
  // Subscribe to asset source lifecycle events
  let task = Task {
    for await sourceID in engine.asset.onAssetSourceUpdated {
      print("Source updated:", sourceID)
      break
    }
  }

  // Notify that source contents changed
  try engine.asset.assetSourceContentsChanged(sourceID: "uploads")

  task.cancel()
  // highlight-conceptsAssets-sourceEvents
}
