import Foundation
import IMGLYEngine

@MainActor
func importFromPexels(engine: Engine) async throws {
  // highlight-pexels-definition
  // Replace with your Pexels API key from https://www.pexels.com/api/
  let apiKey = "YOUR_PEXELS_API_KEY"
  let source = PexelsAssetSource(apiKey: apiKey)
  try engine.asset.addSource(source)
  // highlight-pexels-definition

  // highlight-pexels-verify
  let registeredSources = engine.asset.findAllSources()
  print("Registered asset sources: \(registeredSources)")
  // highlight-pexels-verify
  assert(registeredSources.contains(PexelsAssetSource.id))

  // A live query needs a real API key, so skip it while the placeholder is in place.
  guard apiKey != "YOUR_PEXELS_API_KEY" else { return }

  // highlight-pexels-findAssets
  let curated = try await engine.asset.findAssets(
    sourceID: PexelsAssetSource.id,
    query: .init(query: nil, page: 0, perPage: 20),
  )
  print("Pexels returned \(curated.assets.count) curated photos")

  let results = try await engine.asset.findAssets(
    sourceID: PexelsAssetSource.id,
    query: .init(query: "mountains", page: 0, perPage: 20),
  )
  print("Pexels search returned \(results.assets.count) photos for 'mountains'")
  // highlight-pexels-findAssets
}
