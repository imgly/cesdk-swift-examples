import Foundation
import IMGLYEngine

@MainActor
func sourceSets(engine: Engine) async throws {
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  try await engine.scene.zoom(to: page, paddingLeft: 50, paddingTop: 50, paddingRight: 50, paddingBottom: 50)

  let baseURL = try engine.guidesBaseURL

  // highlight-set-source-set
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setSourceSet(imageFill, property: "fill/image/sourceSet", sourceSet: [
    .init(uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-512x341.jpg"), width: 512, height: 341),
    .init(uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-1249x833.jpg"), width: 1249, height: 833),
    .init(
      uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-1767x1178.jpg"),
      width: 1767,
      height: 1178,
    ),
  ])
  try engine.block.setFill(block, fill: imageFill)
  try engine.block.appendChild(to: page, child: block)
  // highlight-set-source-set

  // highlight-query-source-set
  let sources = try engine.block.getSourceSet(imageFill, property: "fill/image/sourceSet")
  print("Image source set has \(sources.count) sources")

  try await engine.block.addImageFileURIToSourceSet(
    imageFill,
    property: "fill/image/sourceSet",
    uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  // highlight-query-source-set

  // highlight-asset-source-set
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

  try engine.asset.addLocalSource(sourceID: "my-dynamic-images")
  try engine.asset.addAsset(to: "my-dynamic-images", asset: assetWithSourceSet)

  // In an app, look the asset up from its source with `findAssets` or `fetchAsset`.
  // Here we build the `AssetResult` directly because we already have the definition.
  let assetResult = AssetResult(
    id: assetWithSourceSet.id,
    meta: assetWithSourceSet.meta,
    context: AssetContext(sourceID: "my-dynamic-images"),
  )
  if let appliedBlock = try await engine.asset.defaultApplyAsset(assetResult: assetResult) {
    let appliedFill = try engine.block.getFill(appliedBlock)
    let appliedSources = try engine.block.getSourceSet(appliedFill, property: "fill/image/sourceSet")
    print("Applied block fill has \(appliedSources.count) sources")
  }
  // highlight-asset-source-set

  // highlight-video-source-set
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setSourceSet(videoFill, property: "fill/video/sourceSet", sourceSet: [
    .init(
      uri: baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4"),
      width: 720,
      height: 1280,
    ),
  ])

  try await engine.block.addVideoFileURIToSourceSet(
    videoFill,
    property: "fill/video/sourceSet",
    uri: baseURL.appendingPathComponent(
      "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
    ),
  )
  // highlight-video-source-set

  // highlight-video-preview-settings
  try engine.editor.setSettingBool("features/forceLowQualityVideoPreview", value: true)
  // highlight-video-preview-settings
}
