import Foundation
import IMGLYEngine

@MainActor
func performance(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-performance-initialization
  try engine.editor.setSettingString(
    "basePath",
    value: baseURL.absoluteString,
  )
  // highlight-performance-initialization

  let scene = try engine.scene.create()
  try engine.scene.setDesignUnit(.px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-performance-sourceSets
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setSourceSet(imageFill, property: "fill/image/sourceSet", sourceSet: [
    .init(
      uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-512x341.jpg"),
      width: 512,
      height: 341,
    ),
    .init(
      uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-883x589.jpg"),
      width: 883,
      height: 589,
    ),
    .init(
      uri: baseURL.appendingPathComponent("ly.img.image/images/sample_1-1767x1178.jpg"),
      width: 1767,
      height: 1178,
    ),
  ])
  try engine.block.setFill(block, fill: imageFill)
  try engine.block.appendChild(to: page, child: block)
  // highlight-performance-sourceSets

  // highlight-performance-memoryMonitoring
  let usedMemory = try engine.editor.getUsedMemory()
  let availableMemory = try? engine.editor.getAvailableMemory()
  if let availableMemory {
    let total = usedMemory + availableMemory
    let usagePercentage = Double(usedMemory) / Double(total) * 100
    print("Memory usage: \(usagePercentage)%")
  }
  // highlight-performance-memoryMonitoring

  // highlight-performance-maxExportSize
  let maxExportSize = try engine.editor.getMaxExportSize()

  let designUnit = try engine.scene.getDesignUnit()
  let widthMode = try engine.block.getWidthMode(page)
  let heightMode = try engine.block.getHeightMode(page)
  if designUnit == .px, widthMode == .absolute, heightMode == .absolute {
    let pageWidth = try engine.block.getWidth(page)
    let pageHeight = try engine.block.getHeight(page)
    let withinLimit = Int(pageWidth.rounded(.up)) <= maxExportSize
      && Int(pageHeight.rounded(.up)) <= maxExportSize
    if !withinLimit {
      print("Page dimensions exceed the device export limit")
    }
  }
  // highlight-performance-maxExportSize

  // highlight-performance-exportSettings
  let options = ExportOptions(
    jpegQuality: 0.8,
    targetWidth: 1280,
    targetHeight: 720,
  )
  let blob = try await engine.block.export(page, mimeType: .jpeg, options: options)
  // highlight-performance-exportSettings
  _ = blob
}
