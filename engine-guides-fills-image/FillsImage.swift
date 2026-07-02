import Foundation
import IMGLYEngine

@MainActor
func fillsImage(engine: Engine) async throws {
  // Demo scaffolding: a scene with a page and a single graphic block to receive the image fill.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block, value: 500)
  try engine.block.setHeight(block, value: 500)
  try engine.block.setPositionX(block, value: 150)
  try engine.block.setPositionY(block, value: 50)
  try engine.block.appendChild(to: page, child: block)

  let baseURL = try engine.guidesBaseURL
  let imagesURL = baseURL.appendingPathComponent("ly.img.image/images")
  let sampleImageURL = imagesURL.appendingPathComponent("sample_1.jpg")

  // highlight-fillsImage-checkSupport
  let canHaveFill = try engine.block.supportsFill(block)
  print("Block supports fills: \(canHaveFill)")
  // highlight-fillsImage-checkSupport

  // highlight-fillsImage-createImageFill
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: sampleImageURL,
  )
  try engine.block.setFill(block, fill: imageFill)
  // highlight-fillsImage-createImageFill

  // highlight-fillsImage-getCurrentFill
  let currentFill = try engine.block.getFill(block)
  let fillType = try engine.block.getType(currentFill)
  print("Fill type: \(fillType)")
  // highlight-fillsImage-getCurrentFill

  // highlight-fillsImage-coverMode
  try engine.block.setEnum(block, property: "contentFill/mode", value: "Cover")
  // highlight-fillsImage-coverMode

  try await engine.captureGuide(page, label: "after-cover")

  // highlight-fillsImage-containMode
  try engine.block.setEnum(block, property: "contentFill/mode", value: "Contain")
  // highlight-fillsImage-containMode

  try await engine.captureGuide(page, label: "after-contain")

  // highlight-fillsImage-getFillMode
  let currentMode = try engine.block.getEnum(block, property: "contentFill/mode")
  print("Current fill mode: \(currentMode)")
  // highlight-fillsImage-getFillMode

  // highlight-fillsImage-sourceSet
  try engine.block.setSourceSet(
    imageFill,
    property: "fill/image/sourceSet",
    sourceSet: [
      Source(uri: imagesURL.appendingPathComponent("sample_1-512x341.jpg"), width: 512, height: 341),
      Source(uri: imagesURL.appendingPathComponent("sample_1-883x589.jpg"), width: 883, height: 589),
      Source(uri: imagesURL.appendingPathComponent("sample_1-1767x1178.jpg"), width: 1767, height: 1178),
    ],
  )
  // highlight-fillsImage-sourceSet

  // highlight-fillsImage-getSourceSet
  let sourceSet = try engine.block.getSourceSet(imageFill, property: "fill/image/sourceSet")
  print("Source set entries: \(sourceSet.count)")
  // highlight-fillsImage-getSourceSet

  // Clear the source set so the engine falls back to the single imageFileURI
  // for the hero composition; the URI was never overwritten, so no need to re-set it.
  try engine.block.setSourceSet(imageFill, property: "fill/image/sourceSet", sourceSet: [])

  try await engine.captureGuide(page, label: "hero")

  // highlight-fillsImage-dataUri
  let svgContent = """
  <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">\
  <circle cx="50" cy="50" r="40" fill="#4CAF50"/>\
  </svg>
  """
  let svgData = Data(svgContent.utf8).base64EncodedString()
  let svgDataUri = "data:image/svg+xml;base64,\(svgData)"

  let dataUriBlock = try engine.block.create(.graphic)
  try engine.block.setShape(dataUriBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(dataUriBlock, value: 120)
  try engine.block.setHeight(dataUriBlock, value: 120)
  try engine.block.setPositionX(dataUriBlock, value: 640)
  try engine.block.setPositionY(dataUriBlock, value: 60)
  try engine.block.appendChild(to: page, child: dataUriBlock)

  let dataUriFill = try engine.block.createFill(.image)
  try engine.block.setString(dataUriFill, property: "fill/image/imageFileURI", value: svgDataUri)
  try engine.block.setFill(dataUriBlock, fill: dataUriFill)
  // highlight-fillsImage-dataUri

  // highlight-fillsImage-opacity
  try engine.block.setOpacity(dataUriBlock, value: 0.6)
  // highlight-fillsImage-opacity
}
