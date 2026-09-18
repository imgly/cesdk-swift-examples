import Foundation
import IMGLYEngine

@MainActor
func editOrRemoveTemplates(engine: Engine) async throws {
  // Demo scaffolding: a scene with one page that serves as the template content.
  // Passing the design unit to `create` also pairs the font-size unit to pixels,
  // so the `text/fontSize` values below are interpreted as pixels — the default
  // font-size unit is points, which the scene's DPI would otherwise scale up.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  let pageWidth = try engine.block.getWidth(page)
  let pageHeight = try engine.block.getHeight(page)

  // highlight-editOrRemoveTemplates-createSource
  try engine.asset.addLocalSource(sourceID: "my-templates", applyAsset: { [weak engine] asset in
    guard let engine, let uri = asset.meta?["uri"],
          let base64Content = uri.split(separator: ",", maxSplits: 1).dropFirst().first
    else { return nil }
    try await engine.scene.load(from: String(base64Content))
    return nil
  })
  // highlight-editOrRemoveTemplates-createSource

  // highlight-editOrRemoveTemplates-createTemplate
  let titleBlock = try engine.block.create(.text)
  try engine.block.replaceText(titleBlock, text: "Original Template")
  try engine.block.setFloat(titleBlock, property: "text/fontSize", value: 64)
  try engine.block.setWidthMode(titleBlock, mode: .auto)
  try engine.block.setHeightMode(titleBlock, mode: .auto)
  try engine.block.appendChild(to: page, child: titleBlock)

  let subtitleBlock = try engine.block.create(.text)
  try engine.block.replaceText(subtitleBlock, text: "A reusable starting point")
  try engine.block.setFloat(subtitleBlock, property: "text/fontSize", value: 42)
  try engine.block.setWidthMode(subtitleBlock, mode: .auto)
  try engine.block.setHeightMode(subtitleBlock, mode: .auto)
  try engine.block.appendChild(to: page, child: subtitleBlock)
  // highlight-editOrRemoveTemplates-createTemplate

  // Position the text blocks centered on the page.
  let titleWidth = try engine.block.getFrameWidth(titleBlock)
  let titleHeight = try engine.block.getFrameHeight(titleBlock)
  try engine.block.setPositionX(titleBlock, value: (pageWidth - titleWidth) / 2)
  try engine.block.setPositionY(titleBlock, value: pageHeight / 2 - titleHeight - 20)

  let subtitleWidth = try engine.block.getFrameWidth(subtitleBlock)
  try engine.block.setPositionX(subtitleBlock, value: (pageWidth - subtitleWidth) / 2)
  try engine.block.setPositionY(subtitleBlock, value: pageHeight / 2 + 20)

  // Capture the composed template for the guide's hero image (verification only —
  // not part of the rendered snippets).
  try await engine.captureGuide(page, label: "hero", mimeType: .png)

  // highlight-editOrRemoveTemplates-addToSource
  let originalContent = try await engine.scene.saveToString()
  try engine.asset.addAsset(to: "my-templates", asset: AssetDefinition(
    id: "template-original",
    meta: [
      "uri": "data:application/octet-stream;base64,\(originalContent)",
      "thumbUri": try await templateThumbnail(engine: engine, page: page),
    ],
    label: ["en": "Original Template"],
  ))
  // highlight-editOrRemoveTemplates-addToSource

  // highlight-editOrRemoveTemplates-modifyTemplate
  try engine.block.replaceText(titleBlock, text: "Updated Template")
  try engine.block.replaceText(subtitleBlock, text: "This template was edited and saved")

  let updatedContent = try await engine.scene.saveToString()
  try engine.asset.addAsset(to: "my-templates", asset: AssetDefinition(
    id: "template-updated",
    meta: [
      "uri": "data:application/octet-stream;base64,\(updatedContent)",
      "thumbUri": try await templateThumbnail(engine: engine, page: page),
    ],
    label: ["en": "Updated Template"],
  ))
  // highlight-editOrRemoveTemplates-modifyTemplate

  // Re-center the text blocks after the edits changed their frame sizes.
  let newTitleWidth = try engine.block.getFrameWidth(titleBlock)
  let newTitleHeight = try engine.block.getFrameHeight(titleBlock)
  try engine.block.setPositionX(titleBlock, value: (pageWidth - newTitleWidth) / 2)
  try engine.block.setPositionY(titleBlock, value: pageHeight / 2 - newTitleHeight - 20)

  let newSubtitleWidth = try engine.block.getFrameWidth(subtitleBlock)
  try engine.block.setPositionX(subtitleBlock, value: (pageWidth - newSubtitleWidth) / 2)

  // highlight-editOrRemoveTemplates-removeTemplate
  // Add a temporary template to demonstrate removal.
  try engine.asset.addAsset(to: "my-templates", asset: AssetDefinition(
    id: "template-temporary",
    meta: [
      "uri": "data:application/octet-stream;base64,\(originalContent)",
      "thumbUri": try await templateThumbnail(engine: engine, page: page),
    ],
    label: ["en": "Temporary Template"],
  ))

  try engine.asset.removeAsset(from: "my-templates", assetID: "template-temporary")
  // highlight-editOrRemoveTemplates-removeTemplate

  // highlight-editOrRemoveTemplates-updateInSource
  try engine.block.replaceText(subtitleBlock, text: "Updated again with new content")
  let reUpdatedContent = try await engine.scene.saveToString()

  try engine.asset.removeAsset(from: "my-templates", assetID: "template-updated")
  try engine.asset.addAsset(to: "my-templates", asset: AssetDefinition(
    id: "template-updated",
    meta: [
      "uri": "data:application/octet-stream;base64,\(reUpdatedContent)",
      "thumbUri": try await templateThumbnail(engine: engine, page: page),
    ],
    label: ["en": "Updated Template"],
  ))
  // highlight-editOrRemoveTemplates-updateInSource

  // Restore the original template content as the active scene.
  try await engine.scene.load(from: originalContent)
}

// highlight-editOrRemoveTemplates-thumbnailHelper
private func templateThumbnail(engine: Engine, page: DesignBlockID) async throws -> String {
  // `targetWidth` bounds the export so the thumbnail stays small.
  let data = try await engine.block.export(page, mimeType: .png, options: ExportOptions(targetWidth: 200))
  return "data:image/png;base64,\(data.base64EncodedString())"
}

// highlight-editOrRemoveTemplates-thumbnailHelper
