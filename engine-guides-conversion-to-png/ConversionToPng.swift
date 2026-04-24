import Foundation
import IMGLYEngine

@MainActor
func conversionToPng(engine: Engine) async throws {
  try engine.editor.setSettingString("basePath", value: "https://cdn.img.ly/packages/imgly/cesdk-engine/1.74.0-rc.0/assets")
  try await engine.addDefaultAssetSources()
  let sceneUrl =
    URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneUrl)

  // highlight-conversionToPng-exportSinglePage
  let page = try engine.scene.getCurrentPage()!
  let pngData = try await engine.block.export(page, mimeType: .png)
  // highlight-conversionToPng-exportSinglePage

  // highlight-conversionToPng-exportAllPages
  let pages = try engine.scene.getPages()
  var exportedPages: [Data] = []
  for try await data in try await engine.block.export(pages, mimeType: .png) {
    exportedPages.append(data)
  }
  // highlight-conversionToPng-exportAllPages

  // highlight-conversionToPng-compressionLevel
  let compressedOptions = ExportOptions(pngCompressionLevel: 9)
  let compressedData = try await engine.block.export(page, mimeType: .png, options: compressedOptions)
  // highlight-conversionToPng-compressionLevel

  // highlight-conversionToPng-targetDimensions
  let resizedOptions = ExportOptions(targetWidth: 1920, targetHeight: 1080)
  let resizedData = try await engine.block.export(page, mimeType: .png, options: resizedOptions)
  // highlight-conversionToPng-targetDimensions

  // highlight-conversionToPng-textOverhang
  let overhangOptions = ExportOptions(allowTextOverhang: true)
  let overhangData = try await engine.block.export(page, mimeType: .png, options: overhangOptions)
  // highlight-conversionToPng-textOverhang
}
