import Foundation
import IMGLYEngine

@MainActor
func importFromGettyImages(engine: Engine) async throws {
  // highlight-getty-definition
  // Replace with the host of your Getty Images proxy server (see the prerequisites).
  let proxyHost = "YOUR_GETTY_IMAGES_PROXY_HOST"
  let source = GettyImagesAssetSource(proxyHost: proxyHost)
  try engine.asset.addSource(source)
  // highlight-getty-definition

  // highlight-getty-verify
  let registeredSources = engine.asset.findAllSources()
  print("Registered asset sources: \(registeredSources)")
  // highlight-getty-verify
  assert(registeredSources.contains(GettyImagesAssetSource.id))

  // A live query needs a running proxy server, so skip it while the placeholder host is in place.
  guard proxyHost != "YOUR_GETTY_IMAGES_PROXY_HOST" else { return }

  // highlight-getty-findAssets
  let results = try await engine.asset.findAssets(
    sourceID: GettyImagesAssetSource.id,
    query: .init(query: "business", page: 0, perPage: 20),
  )
  print("Getty Images returned \(results.assets.count) photos for 'business'")
  // highlight-getty-findAssets
}
