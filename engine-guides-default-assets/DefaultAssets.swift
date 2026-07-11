import Foundation
import IMGLYEngine

@MainActor
func defaultAssets(engine: Engine) async throws {
  // Demo scaffolding: resolve sample assets against the engine's configured base
  // URL, with a wide page to host the three blocks the hero shows.
  let baseURL = try engine.guidesBaseURL
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 900)
  try engine.block.setHeight(page, value: 400)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-defaultAssets-loadDefault
  // Register a default asset source by loading its `content.json`. The returned
  // ID matches the source's `id` field in the JSON.
  let shapeSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("ly.img.vector.shape/content.json"),
  )
  let stickerSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("ly.img.sticker/content.json"),
  )
  // highlight-defaultAssets-loadDefault

  // highlight-defaultAssets-loadDemo
  // Demo asset sources — sample images, videos, and audio — load the same way.
  let imageSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("ly.img.image/content.json"),
  )
  // highlight-defaultAssets-loadDemo

  // highlight-defaultAssets-createBlocks
  // Fetch a specific asset by its ID, then apply it.
  // `apply(sourceID:assetResult:)` creates a block from the asset, attaches it
  // to the current page, and returns the new block's handle.
  guard
    let starAsset = try await engine.asset.fetchAsset(
      sourceID: shapeSourceID,
      assetID: "ly.img.vector.shape.filled.star",
    ),
    let starBlock = try await engine.asset.apply(sourceID: shapeSourceID, assetResult: starAsset),
    let emojiAsset = try await engine.asset.fetchAsset(
      sourceID: stickerSourceID,
      assetID: "ly.img.sticker.emoji.happyface",
    ),
    let emojiBlock = try await engine.asset.apply(sourceID: stickerSourceID, assetResult: emojiAsset),
    let imageAsset = try await engine.asset.fetchAsset(
      sourceID: imageSourceID,
      assetID: "ly.img.image.sample_1",
    ),
    let imageBlock = try await engine.asset.apply(sourceID: imageSourceID, assetResult: imageAsset)
  else { return }
  // highlight-defaultAssets-createBlocks

  // Demo scaffolding: give the star a solid fill, keep the emoji uncropped, then
  // size and lay out the three blocks in a centered row for the hero.
  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    starFill,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.78, b: 0.0, a: 1.0),
  )
  try engine.block.setFill(starBlock, fill: starFill)

  if try engine.block.supportsContentFillMode(emojiBlock) {
    try engine.block.setContentFillMode(emojiBlock, mode: .contain)
  }

  let blockSize: Float = 220
  let spacing: Float = 50
  let blocks = [starBlock, emojiBlock, imageBlock]
  let rowWidth = Float(blocks.count) * blockSize + Float(blocks.count - 1) * spacing
  let startX = (900 - rowWidth) / 2
  for (index, block) in blocks.enumerated() {
    try engine.block.setWidth(block, value: blockSize)
    try engine.block.setHeight(block, value: blockSize)
    try engine.block.setPositionX(block, value: startX + Float(index) * (blockSize + spacing))
    try engine.block.setPositionY(block, value: (400 - blockSize) / 2)
  }

  try await engine.captureGuide(page, label: "hero")
}

// Compile-only demonstration of the `matcher` parameter. The guide test does not
// run this function: re-registering an asset source ID that is already loaded in
// `defaultAssets(engine:)` would fail because source IDs must be unique.
@MainActor
func defaultAssetsWithMatcher(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-defaultAssets-matcher
  // Load only star and arrow shapes.
  let shapeSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("ly.img.vector.shape/content.json"),
    matcher: ["*star*", "*arrow*"],
  )
  // Load only emoji stickers.
  let stickerSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    baseURL.appendingPathComponent("ly.img.sticker/content.json"),
    matcher: ["*emoji*"],
  )
  print("Loaded filtered sources: \(shapeSourceID), \(stickerSourceID)")
  // highlight-defaultAssets-matcher
}
