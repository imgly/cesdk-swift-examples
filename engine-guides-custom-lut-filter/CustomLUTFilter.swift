import Foundation
import IMGLYEngine

@MainActor
func customLutFilter(engine: Engine) async throws {
  let scene = try engine.scene.create()

  // highlight-load-scene
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 100)
  try engine.block.setHeight(page, value: 100)
  try engine.block.appendChild(to: scene, child: page)
  try await engine.scene.zoom(to: scene, paddingLeft: 40.0, paddingTop: 40.0, paddingRight: 40.0, paddingBottom: 40.0)
  // highlight-load-scene

  // highlight-create-rect
  let rect = try engine.block.create(.graphic)
  try engine.block.setShape(rect, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(rect, value: 100)
  try engine.block.setHeight(rect, value: 100)
  try engine.block.appendChild(to: page, child: rect)
  // highlight-create-rect

  // highlight-create-image-fill
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg",
  )
  // highlight-create-image-fill

  // highlight-create-lut-filter
  let lutFilter = try engine.block.createEffect(.lutFilter)
  try engine.block.setBool(lutFilter, property: "effect/enabled", value: true)
  try engine.block.setFloat(lutFilter, property: "effect/lut_filter/intensity", value: 0.9)
  try engine.block.setString(
    lutFilter,
    property: "effect/lut_filter/lutFileURI",
    // swiftlint:disable:next line_length
    value: "https://cdn.img.ly/packages/imgly/cesdk-js/1.63.0-rc.0/assets/extensions/ly.img.cesdk.filters.lut/LUTs/imgly_lut_ad1920_5_5_128.png",
  )
  try engine.block.setInt(lutFilter, property: "effect/lut_filter/verticalTileCount", value: 5)
  try engine.block.setInt(lutFilter, property: "effect/lut_filter/horizontalTileCount", value: 5)
  // highlight-create-lut-filter

  // highlight-apply-lut-filter
  try engine.block.appendEffect(rect, effectID: lutFilter)
  try engine.block.setFill(rect, fill: imageFill)
  // highlight-apply-lut-filter
}
