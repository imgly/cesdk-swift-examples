import CoreGraphics
import Foundation
import IMGLYEngine

@MainActor
func dragAndDrop(engine: Engine) async throws -> DesignBlockID? {
  let baseURL = try engine.guidesBaseURL
  let firstImageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  let secondImageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg")

  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // The gesture moves image fills, so give each block a rectangle shape and an image fill.
  func addImage(_ uri: URL, x: Float) throws {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    let fill = try engine.block.createFill(.image)
    try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: uri)
    try engine.block.setFill(block, fill: fill)
    try engine.block.setWidth(block, value: 300)
    try engine.block.setHeight(block, value: 300)
    try engine.block.setPositionX(block, value: x)
    try engine.block.setPositionY(block, value: 150)
    try engine.block.appendChild(to: page, child: block)
  }

  try addImage(firstImageURL, x: 50)
  try addImage(secondImageURL, x: 450)
  // highlight-setup

  // highlight-gesture-enable
  // Let users exchange two images by dragging one image block onto another.
  try engine.editor.setSettingBool("dragToSwapFills/enabled", value: true)

  // How long the pointer stays pressed before the image lifts.
  // Use 0 for fixed layouts, where every drag must swap instead of move.
  try engine.editor.setSettingFloat("dragToSwapFills/longPressDurationMs", value: 500)
  // highlight-gesture-enable

  // highlight-asset-source
  try engine.asset.addLocalSource(sourceID: "my-images")
  try engine.asset.addAsset(
    to: "my-images",
    asset: AssetDefinition(
      id: "sample-1",
      meta: [
        "uri": firstImageURL.absoluteString,
        "fillType": FillType.image.rawValue,
      ],
      label: ["en": "Sample image"],
    ),
  )

  guard let asset = try await engine.asset.fetchAsset(sourceID: "my-images", assetID: "sample-1") else {
    return nil
  }
  // highlight-asset-source

  // highlight-apply-placement
  // Add the asset to `page`, centered at (200, 300) relative to `page`.
  guard let placed = try await engine.asset.apply(
    sourceID: "my-images",
    assetResult: asset,
    placement: AssetPlacement(parent: page, center: CGPoint(x: 200, y: 300)),
  ) else {
    return nil
  }
  print("Placed block \(placed)")
  // highlight-apply-placement

  // highlight-default-apply
  // An omitted `parent` adds the block to the current page.
  if let defaultPlaced = try await engine.asset.defaultApplyAsset(
    assetResult: asset,
    placement: AssetPlacement(center: CGPoint(x: 600, y: 300)),
  ) {
    print("Placed block \(defaultPlaced)")
  }
  // highlight-default-apply

  return placed
}
