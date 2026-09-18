import Foundation
import IMGLYEngine

@MainActor
func importLocalAsset(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-importLocalAsset-register
  try engine.asset.addLocalSource(sourceID: "my-local-images")
  // highlight-importLocalAsset-register

  // highlight-importLocalAsset-restrictMimeTypes
  try engine.asset.addLocalSource(
    sourceID: "my-local-audio",
    supportedMimeTypes: ["audio/mpeg", "audio/mp4"],
  )
  // highlight-importLocalAsset-restrictMimeTypes

  // highlight-importLocalAsset-locateFiles
  // application bundle
  let bundledImageURLs = Bundle.main.urls(
    forResourcesWithExtension: "jpg",
    subdirectory: "SampleImages",
  ) ?? []

  // Application Support directory
  let supportDirectory = try FileManager.default.url(
    for: .applicationSupportDirectory,
    in: .userDomainMask,
    appropriateFor: nil,
    create: true,
  )
  let managedImageURLs = try FileManager.default.contentsOfDirectory(
    at: supportDirectory,
    includingPropertiesForKeys: nil,
    options: [.skipsHiddenFiles],
  ).filter { ["jpg", "jpeg", "png"].contains($0.pathExtension.lowercased()) }

  print("Located \(bundledImageURLs.count) bundled and \(managedImageURLs.count) managed images")
  // highlight-importLocalAsset-locateFiles

  // highlight-importLocalAsset-definition
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  let thumbnailURL = baseURL.appendingPathComponent("ly.img.image/thumbnails/sample_1.jpg")

  let imageAsset = AssetDefinition(
    id: "local-image-1",
    meta: [
      "uri": imageURL.absoluteString,
      "thumbUri": thumbnailURL.absoluteString,
      "fillType": "//ly.img.ubq/fill/image",
    ],
    label: ["en": "Mountain Landscape"],
    tags: ["en": ["local", "nature", "mountain"]],
  )
  // highlight-importLocalAsset-definition

  // highlight-importLocalAsset-add
  try engine.asset.addAsset(to: "my-local-images", asset: imageAsset)
  // highlight-importLocalAsset-add

  // highlight-importLocalAsset-verify
  let result = try await engine.asset.findAssets(
    sourceID: "my-local-images",
    query: .init(query: nil, page: 0, perPage: 10),
  )
  print("The source now holds \(result.total) asset(s)")
  // highlight-importLocalAsset-verify
}
