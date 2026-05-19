import Foundation
import IMGLYEngine

@MainActor
func sizeLimits(engine: Engine) async throws {
  try engine.scene.create()
  // Use pixels as the scene's design unit so block dimensions can be compared
  // directly to pixel-based limits like getMaxExportSize().
  try engine.scene.setDesignUnit(.px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  if let scene = try engine.scene.get() {
    try engine.block.appendChild(to: scene, child: page)
  }

  // highlight-sizeLimits-readSetting
  let currentMaxImageSize = try engine.editor.getSettingInt("maxImageSize")
  // The default value is 4096 pixels.
  // highlight-sizeLimits-readSetting

  // highlight-sizeLimits-writeSetting
  // Lower the limit on memory-constrained devices. Apply this before loading
  // images so newly loaded textures are downscaled to the new limit.
  try engine.editor.setSettingInt("maxImageSize", value: 2048)

  // Or raise it for high-quality workflows on capable devices:
  // try engine.editor.setSettingInt("maxImageSize", value: 8192)
  // highlight-sizeLimits-writeSetting

  // highlight-sizeLimits-observeChanges
  // Observe settings changes via an AsyncStream and react to new values. Cancel
  // the task to unsubscribe.
  let observation = Task {
    for await _ in engine.editor.onSettingsChanged {
      let newMaxImageSize = try engine.editor.getSettingInt("maxImageSize")
      _ = newMaxImageSize
    }
  }
  // ...
  observation.cancel()
  // highlight-sizeLimits-observeChanges

  // highlight-sizeLimits-maxExportSize
  // The engine reports the maximum export size supported on the current device.
  // The value is an upper bound — exports may still fail for memory or other
  // reasons. When the limit is unknown, the engine returns Int32.max.
  let maxExportSize = try engine.editor.getMaxExportSize()
  // highlight-sizeLimits-maxExportSize

  // highlight-sizeLimits-validateExport
  // getWidth/getHeight only return absolute pixel values when the scene's
  // design unit is .px AND the block's size mode is .absolute. With .percent
  // the value is a fraction of the parent's size; with .auto it is derived
  // from the block's content. Check both before comparing to the pixel-based
  // device limit.
  let designUnit = try engine.scene.getDesignUnit()
  let widthMode = try engine.block.getWidthMode(page)
  let heightMode = try engine.block.getHeightMode(page)
  if designUnit == .px, widthMode == .absolute, heightMode == .absolute {
    let pageWidth = try engine.block.getWidth(page)
    let pageHeight = try engine.block.getHeight(page)
    let withinLimit = Int(pageWidth.rounded(.up)) <= maxExportSize
      && Int(pageHeight.rounded(.up)) <= maxExportSize
    _ = withinLimit
  }
  // highlight-sizeLimits-validateExport

  // highlight-sizeLimits-handleExport
  // Catch export errors so the app can recover. Common remediations are
  // lowering targetWidth/targetHeight or reducing maxImageSize.
  // ExportOptions.targetWidth/targetHeight are always in pixels.
  do {
    let pngData = try await engine.block.export(page, mimeType: .png)
    _ = pngData
  } catch {
    try engine.editor.setSettingInt("maxImageSize", value: 2048)
    let retryOptions = ExportOptions(targetWidth: 1920, targetHeight: 1080)
    let retryData = try await engine.block.export(page, mimeType: .png, options: retryOptions)
    _ = retryData
  }
  // highlight-sizeLimits-handleExport
}
