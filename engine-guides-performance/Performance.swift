import Foundation
import IMGLYEngine

@MainActor
func performance(engine: Engine) async throws {
  // highlight-performance-initialization
  try engine.editor.setSettingString(
    "basePath",
    value: "https://cdn.img.ly/packages/imgly/cesdk-engine/1.76.0-rc.2/assets",
  )
  try await engine.addDefaultAssetSources()
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
      uri: URL(string: "https://img.ly/static/ubq_samples/sample_1_512x341.jpg")!,
      width: 512,
      height: 341,
    ),
    .init(
      uri: URL(string: "https://img.ly/static/ubq_samples/sample_1_1024x683.jpg")!,
      width: 1024,
      height: 683,
    ),
    .init(
      uri: URL(string: "https://img.ly/static/ubq_samples/sample_1_2048x1366.jpg")!,
      width: 2048,
      height: 1366,
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
