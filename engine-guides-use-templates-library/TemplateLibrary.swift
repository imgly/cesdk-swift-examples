import Foundation
import IMGLYEngine

@MainActor
func templateLibrary(engine: Engine) async throws {
  // highlight-templateLibrary-setup
  // Create a design scene that templates will be applied to.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-templateLibrary-setup

  // Base URL the sample templates are resolved against. In your app this is the
  // location where you host your own `.scene` files and thumbnails.
  let baseURL = try engine.guidesBaseURL

  // highlight-templateLibrary-customSource
  // Register a local template source. The `applyAsset` callback runs when a
  // template is selected: it reads the scene URL from the asset's metadata and
  // applies it to the current scene, keeping the current page dimensions.
  try engine.asset.addLocalSource(sourceID: "my.custom.templates", applyAsset: { [weak engine] asset in
    guard let engine, let uri = asset.meta?["uri"], let sceneURL = URL(string: uri) else {
      return nil
    }
    try await engine.scene.applyTemplate(from: sceneURL)
    return nil
  })
  // highlight-templateLibrary-customSource

  // highlight-templateLibrary-addAssets
  // Add template assets. Each asset's `meta` carries the `uri` of the `.scene`
  // file to apply and a `thumbUri` for the preview thumbnail.
  try engine.asset.addAsset(
    to: "my.custom.templates",
    asset: AssetDefinition(
      id: "business-card",
      groups: ["business"],
      meta: [
        "uri": baseURL
          .appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
          .absoluteString,
        "thumbUri": baseURL
          .appendingPathComponent("ly.img.templates/thumbnails/cesdk_business_card_1.jpg")
          .absoluteString,
      ],
      label: ["en": "Business Card"],
      tags: ["en": ["business", "card"]],
    ),
  )

  try engine.asset.addAsset(
    to: "my.custom.templates",
    asset: AssetDefinition(
      id: "blank-canvas",
      groups: ["basics"],
      meta: [
        "uri": baseURL
          .appendingPathComponent("ly.img.templates/templates/cesdk_blank_1.scene")
          .absoluteString,
        "thumbUri": baseURL
          .appendingPathComponent("ly.img.templates/thumbnails/cesdk_blank_1.png")
          .absoluteString,
      ],
      label: ["en": "Blank Canvas"],
      tags: ["en": ["blank", "empty"]],
    ),
  )
  // highlight-templateLibrary-addAssets

  // Apply a template by running the source's callback, exactly as the editor
  // does when a user taps a template thumbnail.
  if let firstTemplate = try await engine.asset.findAssets(
    sourceID: "my.custom.templates",
    query: .init(query: nil, page: 0, perPage: 1),
  ).assets.first {
    _ = try await engine.asset.apply(sourceID: "my.custom.templates", assetResult: firstTemplate)
  }

  // highlight-templateLibrary-fromJSON
  // For production, register a template source from a hosted `content.json`
  // file. The parent directory of the JSON becomes the base path for resolving
  // relative URLs inside it.
  let contentURL = baseURL.appendingPathComponent("ly.img.templates/content.json")
  let hostedSourceID = try await engine.asset.addLocalAssetSourceFromJSON(contentURL)
  print("Registered hosted template source:", hostedSourceID)
  // highlight-templateLibrary-fromJSON

  // highlight-templateLibrary-query
  // Query templates with pagination and group filtering.
  let businessTemplates = try await engine.asset.findAssets(
    sourceID: "my.custom.templates",
    query: .init(query: nil, page: 0, groups: ["business"], perPage: 20),
  )
  print("Templates in \"business\" group:", businessTemplates.assets.map(\.id))

  let allTemplates = try await engine.asset.findAssets(
    sourceID: "my.custom.templates",
    query: .init(query: nil, page: 0, perPage: 100),
  )
  print("Total custom templates:", allTemplates.total)
  // highlight-templateLibrary-query

  // highlight-templateLibrary-manageSources
  // List registered sources, read a source's groups, and remove a source.
  let templateSources = engine.asset.findAllSources().filter { $0.contains("template") }
  print("Template sources:", templateSources)

  let groups = try await engine.asset.getGroups(sourceID: "my.custom.templates")
  print("Available groups:", groups)

  try engine.asset.removeSource(sourceID: hostedSourceID)
  // highlight-templateLibrary-manageSources

  // highlight-templateLibrary-monitorSources
  // React to sources being added or removed.
  let addedTask = Task {
    for await sourceID in engine.asset.onAssetSourceAdded {
      print("Asset source added:", sourceID)
      break
    }
  }
  try engine.asset.addLocalSource(sourceID: "seasonal.templates")
  addedTask.cancel()

  let removedTask = Task {
    for await sourceID in engine.asset.onAssetSourceRemoved {
      print("Asset source removed:", sourceID)
      break
    }
  }
  try engine.asset.removeSource(sourceID: "seasonal.templates")
  removedTask.cancel()
  // highlight-templateLibrary-monitorSources
}
