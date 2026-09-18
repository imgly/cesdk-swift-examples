import Foundation
import IMGLYEngine

@MainActor
func remoteAsset(engine: Engine) async throws {
  // highlight-remoteAsset-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-remoteAsset-setup

  // Base URL where the asset files are hosted. In production this is your CDN or
  // server; substitute your own base URL here.
  let baseURL = try engine.guidesBaseURL

  // highlight-remoteAsset-loadFromURL
  let imageSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("ly.img.image/content.json"),
  )
  print("Loaded source:", imageSourceID)
  // highlight-remoteAsset-loadFromURL

  // highlight-remoteAsset-loadFromString
  let absoluteImageURL = baseURL
    .appendingPathComponent("ly.img.image/images/sample_1.jpg")
    .absoluteString
  let manifestJSON = """
  {
    "version": "2.0.0",
    "id": "my.remote.images",
    "assets": [
      {
        "id": "sample_image",
        "label": { "en": "Sample Image" },
        "meta": {
          "uri": "\(absoluteImageURL)",
          "thumbUri": "\(absoluteImageURL)",
          "blockType": "//ly.img.ubq/graphic",
          "fillType": "//ly.img.ubq/fill/image",
          "mimeType": "image/jpeg"
        }
      }
    ]
  }
  """
  let stringSourceID = try engine.asset.addLocalAssetSourceFromJSON(manifestJSON)
  print("Loaded source:", stringSourceID)
  // highlight-remoteAsset-loadFromString

  // highlight-remoteAsset-basePath
  let hostedManifest = """
  {
    "version": "2.0.0",
    "id": "my.remote.images.hosted",
    "assets": [
      {
        "id": "sample_image",
        "label": { "en": "Sample Image" },
        "meta": {
          "uri": "{{base_url}}/ly.img.image/images/sample_1.jpg",
          "thumbUri": "{{base_url}}/ly.img.image/images/sample_1.jpg",
          "blockType": "//ly.img.ubq/graphic",
          "fillType": "//ly.img.ubq/fill/image",
          "mimeType": "image/jpeg"
        }
      }
    ]
  }
  """
  let hostedSourceID = try engine.asset.addLocalAssetSourceFromJSON(
    hostedManifest,
    basePath: baseURL.absoluteString,
  )
  print("Loaded source:", hostedSourceID)
  // highlight-remoteAsset-basePath

  // highlight-remoteAsset-verify
  let results = try await engine.asset.findAssets(
    sourceID: "my.remote.images",
    query: .init(query: nil, page: 0, perPage: 10),
  )
  print("Found assets:", results.total)
  // highlight-remoteAsset-verify

  // highlight-remoteAsset-apply
  let hostedAssets = try await engine.asset.findAssets(
    sourceID: "my.remote.images.hosted",
    query: .init(query: nil, page: 0, perPage: 10),
  )
  if let asset = hostedAssets.assets.first {
    let blockID = try await engine.asset.apply(sourceID: "my.remote.images.hosted", assetResult: asset)
    print("Applied asset to block:", blockID as Any)
  }
  // highlight-remoteAsset-apply

  // highlight-remoteAsset-listSources
  let sources = engine.asset.findAllSources()
  print("Registered sources:", sources)
  // highlight-remoteAsset-listSources

  // highlight-remoteAsset-removeSource
  try engine.asset.removeSource(sourceID: "my.remote.images")
  // highlight-remoteAsset-removeSource

  // highlight-remoteAsset-errorHandling
  do {
    let sourceID = try engine.asset.addLocalAssetSourceFromJSON("{ not valid json }")
    print("Loaded source:", sourceID)
  } catch {
    print("Failed to load asset source:", error.localizedDescription)
  }
  // highlight-remoteAsset-errorHandling
}

// Compile-only variant showing the URL overload with a fully-qualified remote
// URL. The test above runs `remoteAsset` against the bundled sample assets; this
// function is here to illustrate how the same call looks against a CDN.
@MainActor
func remoteAssetFromRemoteServer(engine: Engine) async throws {
  // highlight-remoteAsset-remoteServer
  let baseURL = URL(string: "https://cdn.example.com/assets")!
  let sourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("my-source/content.json"),
  )
  print("Loaded source:", sourceID)
  // highlight-remoteAsset-remoteServer
}
