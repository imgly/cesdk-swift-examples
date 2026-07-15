import Foundation
import IMGLYEngine

@MainActor
func editOrRemoveAssets(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-editOrRemoveAssets-createSource
  try engine.asset.addLocalSource(sourceID: "my-uploads")

  let mountainURI = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg").absoluteString
  let mountainThumbURI = baseURL.appendingPathComponent("ly.img.image/thumbnails/sample_1.jpg").absoluteString
  try engine.asset.addAsset(to: "my-uploads", asset: AssetDefinition(
    id: "image-1",
    meta: [
      "uri": mountainURI,
      "thumbUri": mountainThumbURI,
      "fillType": "//ly.img.ubq/fill/image",
    ],
    label: ["en": "Mountain Landscape"],
    tags: ["en": ["nature", "mountain"]],
  ))

  let oceanURI = baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg").absoluteString
  let oceanThumbURI = baseURL.appendingPathComponent("ly.img.image/thumbnails/sample_2.jpg").absoluteString
  try engine.asset.addAsset(to: "my-uploads", asset: AssetDefinition(
    id: "image-2",
    meta: [
      "uri": oceanURI,
      "thumbUri": oceanThumbURI,
      "fillType": "//ly.img.ubq/fill/image",
    ],
    label: ["en": "Ocean Waves"],
    tags: ["en": ["nature", "water"]],
  ))

  let forestURI = baseURL.appendingPathComponent("ly.img.image/images/sample_3.jpg").absoluteString
  let forestThumbURI = baseURL.appendingPathComponent("ly.img.image/thumbnails/sample_3.jpg").absoluteString
  try engine.asset.addAsset(to: "my-uploads", asset: AssetDefinition(
    id: "image-3",
    meta: [
      "uri": forestURI,
      "thumbUri": forestThumbURI,
      "fillType": "//ly.img.ubq/fill/image",
    ],
    label: ["en": "Forest Path"],
    tags: ["en": ["nature", "forest"]],
  ))
  // highlight-editOrRemoveAssets-createSource

  // highlight-editOrRemoveAssets-findAssets
  let result = try await engine.asset.findAssets(
    sourceID: "my-uploads",
    query: .init(query: "nature", page: 0, perPage: 100),
  )
  let assetToModify = result.assets.first { $0.id == "image-1" }
  print("Found \(result.total) assets; editing \(assetToModify?.label ?? "none")")
  // highlight-editOrRemoveAssets-findAssets

  // highlight-editOrRemoveAssets-updateMetadata
  try engine.asset.removeAsset(from: "my-uploads", assetID: "image-1")
  try engine.asset.addAsset(to: "my-uploads", asset: AssetDefinition(
    id: "image-1",
    meta: [
      "uri": mountainURI,
      "thumbUri": mountainThumbURI,
      "fillType": "//ly.img.ubq/fill/image",
    ],
    label: ["en": "Updated Mountain Photo"],
    tags: ["en": ["nature", "mountain", "updated"]],
  ))
  // highlight-editOrRemoveAssets-updateMetadata

  // highlight-editOrRemoveAssets-removeAsset
  try engine.asset.removeAsset(from: "my-uploads", assetID: "image-2")
  // highlight-editOrRemoveAssets-removeAsset

  // highlight-editOrRemoveAssets-notifyUI
  try engine.asset.assetSourceContentsChanged(sourceID: "my-uploads")
  // highlight-editOrRemoveAssets-notifyUI

  // highlight-editOrRemoveAssets-createTempSource
  let temporaryURI = baseURL.appendingPathComponent("ly.img.image/images/sample_4.jpg").absoluteString
  let temporaryThumbURI = baseURL.appendingPathComponent("ly.img.image/thumbnails/sample_4.jpg").absoluteString
  try engine.asset.addLocalSource(sourceID: "temporary-uploads")
  try engine.asset.addAsset(to: "temporary-uploads", asset: AssetDefinition(
    id: "temp-1",
    meta: [
      "uri": temporaryURI,
      "thumbUri": temporaryThumbURI,
      "fillType": "//ly.img.ubq/fill/image",
    ],
    label: ["en": "Temporary Image"],
  ))
  // highlight-editOrRemoveAssets-createTempSource

  // highlight-editOrRemoveAssets-removeSource
  try engine.asset.removeSource(sourceID: "temporary-uploads")
  // highlight-editOrRemoveAssets-removeSource

  // highlight-editOrRemoveAssets-events
  let addedListener = Task {
    for await sourceID in engine.asset.onAssetSourceAdded {
      print("Source added: \(sourceID)")
    }
  }
  let removedListener = Task {
    for await sourceID in engine.asset.onAssetSourceRemoved {
      print("Source removed: \(sourceID)")
    }
  }
  let updatedListener = Task {
    for await sourceID in engine.asset.onAssetSourceUpdated {
      print("Source updated: \(sourceID)")
    }
  }

  try engine.asset.addLocalSource(sourceID: "event-demo-source")
  try engine.asset.assetSourceContentsChanged(sourceID: "event-demo-source")
  try engine.asset.removeSource(sourceID: "event-demo-source")

  addedListener.cancel()
  removedListener.cancel()
  updatedListener.cancel()
  // highlight-editOrRemoveAssets-events
}
