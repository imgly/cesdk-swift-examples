import Foundation
import IMGLYEngine

@MainActor
func createCustomFilters(engine: Engine) async throws {
  // Demo scaffolding: a design scene with a page and two image blocks to apply
  // filters to. In your app these would be existing design elements.
  let scene = try engine.scene.create()
  let baseURL = try engine.guidesBaseURL

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let sampleImage = baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg")

  let firstImage = try engine.block.create(.graphic)
  try engine.block.setShape(firstImage, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(firstImage, value: 50)
  try engine.block.setPositionY(firstImage, value: 188)
  try engine.block.setWidth(firstImage, value: 300)
  try engine.block.setHeight(firstImage, value: 225)
  let firstFill = try engine.block.createFill(.image)
  try engine.block.setURL(firstFill, property: "fill/image/imageFileURI", value: sampleImage)
  try engine.block.setFill(firstImage, fill: firstFill)
  try engine.block.appendChild(to: page, child: firstImage)

  let secondImage = try engine.block.create(.graphic)
  try engine.block.setShape(secondImage, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(secondImage, value: 450)
  try engine.block.setPositionY(secondImage, value: 188)
  try engine.block.setWidth(secondImage, value: 300)
  try engine.block.setHeight(secondImage, value: 225)
  let secondFill = try engine.block.createFill(.image)
  try engine.block.setURL(secondFill, property: "fill/image/imageFileURI", value: sampleImage)
  try engine.block.setFill(secondImage, fill: secondFill)
  try engine.block.appendChild(to: page, child: secondImage)

  // highlight-createCustomFilters-createSource
  let warmLUT = baseURL.appendingPathComponent("ly.img.filter.lut/LUTs/imgly_lut_sepia_5_5_128.png")
  let monochromeLUT = baseURL.appendingPathComponent("ly.img.filter.lut/LUTs/imgly_lut_bw_5_5_128.png")

  // Register a local asset source to hold the brand's custom filters.
  try engine.asset.addLocalSource(sourceID: "my-custom-filters")

  // Define each filter with its LUT metadata and add it to the source.
  let vintageWarm = AssetDefinition(
    id: "vintage-warm",
    groups: ["Warm Tones"],
    meta: [
      "uri": warmLUT.absoluteString,
      "thumbUri": warmLUT.absoluteString,
      "horizontalTileCount": "5",
      "verticalTileCount": "5",
      "blockType": EffectType.lutFilter.rawValue,
    ],
    label: ["en": "Vintage Warm"],
    tags: ["en": ["vintage", "warm", "retro"]],
  )
  try engine.asset.addAsset(to: "my-custom-filters", asset: vintageWarm)

  let monochromeClassic = AssetDefinition(
    id: "monochrome-classic",
    groups: ["Monochrome"],
    meta: [
      "uri": monochromeLUT.absoluteString,
      "thumbUri": monochromeLUT.absoluteString,
      "horizontalTileCount": "5",
      "verticalTileCount": "5",
      "blockType": EffectType.lutFilter.rawValue,
    ],
    label: ["en": "Monochrome Classic"],
    tags: ["en": ["monochrome", "classic", "black and white"]],
  )
  try engine.asset.addAsset(to: "my-custom-filters", asset: monochromeClassic)
  // highlight-createCustomFilters-createSource

  // highlight-createCustomFilters-loadJSON
  let filterConfigJSON = """
  {
    "version": "2.0.0",
    "id": "my-json-filters",
    "assets": [
      {
        "id": "noir-classic",
        "label": { "en": "Noir Classic" },
        "tags": { "en": ["monochrome", "noir", "grayscale"] },
        "groups": ["Monochrome"],
        "meta": {
          "uri": "\(monochromeLUT.absoluteString)",
          "thumbUri": "\(monochromeLUT.absoluteString)",
          "horizontalTileCount": "5",
          "verticalTileCount": "5",
          "blockType": "\(EffectType.lutFilter.rawValue)"
        }
      },
      {
        "id": "sunset-glow",
        "label": { "en": "Sunset Glow" },
        "tags": { "en": ["warm", "sunset", "golden"] },
        "groups": ["Warm Tones"],
        "meta": {
          "uri": "\(warmLUT.absoluteString)",
          "thumbUri": "\(warmLUT.absoluteString)",
          "horizontalTileCount": "5",
          "verticalTileCount": "5",
          "blockType": "\(EffectType.lutFilter.rawValue)"
        }
      }
    ]
  }
  """
  let jsonSourceID = try engine.asset.addLocalAssetSourceFromJSON(filterConfigJSON)
  print("Created JSON-based filter source: \(jsonSourceID)")
  // highlight-createCustomFilters-loadJSON

  // highlight-createCustomFilters-query
  let customResults = try await engine.asset.findAssets(
    sourceID: "my-custom-filters",
    query: .init(query: nil, page: 0, perPage: 10),
  )
  print("Found \(customResults.total) filters in the custom source")

  // Narrow the results to a single category with the groups parameter.
  let warmResults = try await engine.asset.findAssets(
    sourceID: "my-custom-filters",
    query: .init(query: nil, page: 0, groups: ["Warm Tones"], perPage: 10),
  )
  print("Found \(warmResults.total) warm-tone filters")

  let jsonResults = try await engine.asset.findAssets(
    sourceID: jsonSourceID,
    query: .init(query: nil, page: 0, perPage: 10),
  )
  print("Found \(jsonResults.total) filters in the JSON source")

  let monochromeResults = try await engine.asset.findAssets(
    sourceID: jsonSourceID,
    query: .init(query: nil, page: 0, groups: ["Monochrome"], perPage: 10),
  )
  print("Found \(monochromeResults.total) monochrome filters")

  let allSources = engine.asset.findAllSources()
  print("Registered sources: \(allSources)")
  // highlight-createCustomFilters-query

  // highlight-createCustomFilters-apply
  if let filter = warmResults.assets.first,
     let meta = filter.meta,
     let lutURL = meta["uri"].flatMap(URL.init(string:)) {
    let lutEffect = try engine.block.createEffect(.lutFilter)
    try engine.block.setURL(lutEffect, property: "effect/lut_filter/lutFileURI", value: lutURL)
    try engine.block.setInt(
      lutEffect,
      property: "effect/lut_filter/horizontalTileCount",
      value: Int(meta["horizontalTileCount"] ?? "") ?? 5,
    )
    try engine.block.setInt(
      lutEffect,
      property: "effect/lut_filter/verticalTileCount",
      value: Int(meta["verticalTileCount"] ?? "") ?? 5,
    )
    try engine.block.setFloat(lutEffect, property: "effect/lut_filter/intensity", value: 0.85)
    try engine.block.appendEffect(firstImage, effectID: lutEffect)
  }
  // highlight-createCustomFilters-apply

  try await engine.captureGuide(page, label: "after-apply")

  // highlight-createCustomFilters-applyJSON
  if let filter = monochromeResults.assets.first,
     let meta = filter.meta,
     let lutURL = meta["uri"].flatMap(URL.init(string:)) {
    let lutEffect = try engine.block.createEffect(.lutFilter)
    try engine.block.setURL(lutEffect, property: "effect/lut_filter/lutFileURI", value: lutURL)
    try engine.block.setInt(
      lutEffect,
      property: "effect/lut_filter/horizontalTileCount",
      value: Int(meta["horizontalTileCount"] ?? "") ?? 5,
    )
    try engine.block.setInt(
      lutEffect,
      property: "effect/lut_filter/verticalTileCount",
      value: Int(meta["verticalTileCount"] ?? "") ?? 5,
    )
    try engine.block.setFloat(lutEffect, property: "effect/lut_filter/intensity", value: 0.85)
    try engine.block.appendEffect(secondImage, effectID: lutEffect)
  }
  // highlight-createCustomFilters-applyJSON

  // Most-evolved scene — promoted to the guide's hero image.
  try await engine.captureGuide(page, label: "hero")

  // highlight-createCustomFilters-export
  let blob = try await engine.block.export(page, mimeType: .png)
  let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("custom-filters.png")
  try blob.write(to: outputURL)
  // highlight-createCustomFilters-export
}
