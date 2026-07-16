import Foundation
import IMGLYEngine

@MainActor
func blur(engine: Engine) async throws {
  // Demo scaffolding: a 2x2 grid of the same photo so each cell can render
  // a different blur type side by side.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  let uniformCell = try makeImageCell(engine: engine, page: page, x: 20, y: 20, imageURL: imageURL)
  let linearCell = try makeImageCell(engine: engine, page: page, x: 400, y: 20, imageURL: imageURL)
  let radialCell = try makeImageCell(engine: engine, page: page, x: 20, y: 300, imageURL: imageURL)
  let mirroredCell = try makeImageCell(engine: engine, page: page, x: 400, y: 300, imageURL: imageURL)

  try await engine.captureGuide(page, label: "before-blur")

  // highlight-blur-supportsBlur
  guard try engine.block.supportsBlur(uniformCell) else { return }
  // highlight-blur-supportsBlur

  // highlight-blur-createAndApply
  let uniformBlur = try engine.block.createBlur(.uniform)
  try engine.block.setBlur(uniformCell, blurID: uniformBlur)
  try engine.block.setBlurEnabled(uniformCell, enabled: true)
  // highlight-blur-createAndApply

  // highlight-blur-uniform
  try engine.block.setFloat(uniformBlur, property: "blur/uniform/intensity", value: 0.8)
  // highlight-blur-uniform

  // highlight-blur-linear
  let linearBlur = try engine.block.createBlur(.linear)
  try engine.block.setFloat(linearBlur, property: "blur/linear/blurRadius", value: 35)
  try engine.block.setFloat(linearBlur, property: "blur/linear/x1", value: 0.0)
  try engine.block.setFloat(linearBlur, property: "blur/linear/y1", value: 0.3)
  try engine.block.setFloat(linearBlur, property: "blur/linear/x2", value: 1.0)
  try engine.block.setFloat(linearBlur, property: "blur/linear/y2", value: 0.7)
  try engine.block.setBlur(linearCell, blurID: linearBlur)
  try engine.block.setBlurEnabled(linearCell, enabled: true)
  // highlight-blur-linear

  // highlight-blur-radial
  let radialBlur = try engine.block.createBlur(.radial)
  try engine.block.setFloat(radialBlur, property: "blur/radial/blurRadius", value: 45)
  try engine.block.setFloat(radialBlur, property: "blur/radial/radius", value: 40)
  try engine.block.setFloat(radialBlur, property: "blur/radial/gradientRadius", value: 30)
  try engine.block.setFloat(radialBlur, property: "blur/radial/x", value: 0.5)
  try engine.block.setFloat(radialBlur, property: "blur/radial/y", value: 0.5)
  try engine.block.setBlur(radialCell, blurID: radialBlur)
  try engine.block.setBlurEnabled(radialCell, enabled: true)
  // highlight-blur-radial

  // highlight-blur-mirrored
  let mirroredBlur = try engine.block.createBlur(.mirrored)
  try engine.block.setFloat(mirroredBlur, property: "blur/mirrored/blurRadius", value: 50)
  try engine.block.setFloat(mirroredBlur, property: "blur/mirrored/size", value: 30)
  try engine.block.setFloat(mirroredBlur, property: "blur/mirrored/gradientSize", value: 25)
  try engine.block.setFloat(mirroredBlur, property: "blur/mirrored/x1", value: 0.0)
  try engine.block.setFloat(mirroredBlur, property: "blur/mirrored/y1", value: 0.5)
  try engine.block.setFloat(mirroredBlur, property: "blur/mirrored/x2", value: 1.0)
  try engine.block.setFloat(mirroredBlur, property: "blur/mirrored/y2", value: 0.5)
  try engine.block.setBlur(mirroredCell, blurID: mirroredBlur)
  try engine.block.setBlurEnabled(mirroredCell, enabled: true)
  // highlight-blur-mirrored

  try await engine.captureGuide(page, label: "hero")

  // highlight-blur-readBlur
  let currentBlur = try engine.block.getBlur(radialCell)
  let currentRadius = try engine.block.getFloat(currentBlur, property: "blur/radial/blurRadius")
  print("current radial blur radius: \(currentRadius)")
  // highlight-blur-readBlur

  // highlight-blur-toggle
  try engine.block.setBlurEnabled(uniformCell, enabled: false)
  let uniformEnabled = try engine.block.isBlurEnabled(uniformCell)
  print("uniform blur enabled: \(uniformEnabled)")
  // highlight-blur-toggle

  try await engine.captureGuide(page, label: "after-toggle")

  // highlight-blur-share
  let sharedBlur = try engine.block.createBlur(.uniform)
  try engine.block.setFloat(sharedBlur, property: "blur/uniform/intensity", value: 0.4)
  try engine.block.setBlur(uniformCell, blurID: sharedBlur)
  try engine.block.setBlurEnabled(uniformCell, enabled: true)
  try engine.block.setBlur(linearCell, blurID: sharedBlur)
  try engine.block.setBlurEnabled(linearCell, enabled: true)
  // highlight-blur-share

  // highlight-blur-destroy
  let existingBlur = try engine.block.getBlur(mirroredCell)
  try engine.block.destroy(existingBlur)
  // highlight-blur-destroy
}

@MainActor
private func makeImageCell(
  engine: Engine,
  page: DesignBlockID,
  x: Float,
  y: Float,
  imageURL: URL,
) throws -> DesignBlockID {
  let cell = try engine.block.create(.graphic)
  try engine.block.setShape(cell, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(cell, value: x)
  try engine.block.setPositionY(cell, value: y)
  try engine.block.setWidth(cell, value: 380)
  try engine.block.setHeight(cell, value: 260)
  let fill = try engine.block.createFill(.image)
  try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(cell, fill: fill)
  try engine.block.appendChild(to: page, child: cell)
  return cell
}
