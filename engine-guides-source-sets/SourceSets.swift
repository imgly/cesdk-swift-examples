import Foundation
import IMGLYEngine

@MainActor
func sourceSets(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  try await engine.scene.zoom(to: page, paddingLeft: 50, paddingTop: 50, paddingRight: 50, paddingBottom: 50)
  // highlight-setup

  let baseURL = try engine.guidesBaseURL

  // highlight-set-source-set
  let block = try engine.block.create(DesignBlockType.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setSourceSet(imageFill, property: "fill/image/sourceSet", sourceSet: [
    .init(
      uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-512x341.jpg"),
      width: 512,
      height: 341,
    ),
    .init(
      uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-1249x833.jpg"),
      width: 1249,
      height: 833,
    ),
    .init(
      uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-1767x1178.jpg"),
      width: 1767,
      height: 1178,
    ),
  ])
  try engine.block.setFill(block, fill: imageFill)
  try engine.block.appendChild(to: page, child: block)
  // highlight-set-source-set

  // highlight-asset-definition
  let assetWithSourceSet = AssetDefinition(
    id: "my-image",
    meta: [
      "kind": "image",
      "fillType": "//ly.img.ubq/fill/image",
    ],
    payload: .init(sourceSet: [
      .init(
        uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-512x341.jpg"),
        width: 512,
        height: 341,
      ),
      .init(
        uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-1249x833.jpg"),
        width: 1249,
        height: 833,
      ),
      .init(
        uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-1767x1178.jpg"),
        width: 1767,
        height: 1178,
      ),
    ]),
  )
  // highlight-asset-definition

  // highlight-asset-source
  try engine.asset.addLocalSource(sourceID: "my-dynamic-images")
  try engine.asset.addAsset(to: "my-dynamic-images", asset: assetWithSourceSet)
  // highlight-asset-source

  // highlight-apply-asset
  // Could also acquire the asset using `findAssets` on the source
  let assetResult = AssetResult(
    id: assetWithSourceSet.id,
    meta: assetWithSourceSet.meta,
    context: AssetContext(sourceID: "my-dynamic-images"),
  )
  let result = try await engine.asset.defaultApplyAsset(assetResult: assetResult)
  // Lists the entries from above again.
  _ = try engine.block.getSourceSet(
    try engine.block.getFill(result!),
    property: "fill/image/sourceSet",
  )

  // highlight-apply-asset

  // highlight-video-source-sets
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setSourceSet(videoFill, property: "fill/video/sourceSet", sourceSet: [
    .init(
      uri: baseURL.appendingPathComponent(
        "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
      ),
      width: 1920,
      height: 1080,
    ),
  ])

  try await engine.block.addVideoFileURIToSourceSet(
    videoFill,
    property: "fill/video/sourceSet",
    uri: baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4"),
  )
  // highlight-video-source-sets
}
