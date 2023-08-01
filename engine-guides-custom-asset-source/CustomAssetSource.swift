import Foundation
import IMGLYEngine

@MainActor
func customAssetSource(engine: Engine) async throws {
  // highlight-unsplash-definition
  let source = UnsplashAssetSource()
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

  // highlight-add-local-source
  try engine.asset.addLocalSource(sourceID: "background-videos")
  // highlight-add-local-source

  // highlight-add-asset-to-source
  let asset = AssetDefinition(id: "ocean-waves-1",
                              meta: [
                                "uri": "https://example.com/ocean-waves-1.mp4",
                                "thumbUri": "https://example.com/thumbnails/ocean-waves-1.jpg",
                                "mimeType": "video/mp4",
                                "width": "1920",
                                "height": "1080"
                              ],
                              label: [
                                "en": "relaxing ocean waves",
                                "es": "olas del mar relajantes"
                              ],
                              tags: [
                                "en": ["ocean", "waves", "soothing", "slow"],
                                "es": ["mar", "olas", "calmante", "lento"]
                              ])
  try engine.asset.addAsset(toSource: "background-videos", asset: asset)
  // highlight-add-asset-to-source
}
