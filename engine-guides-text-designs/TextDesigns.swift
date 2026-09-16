import Foundation
import IMGLYEngine

@MainActor
func textDesigns(engine: Engine) async throws {
  // Demo scaffolding: a 1080x1080 sample sheet showing two text designs — a
  // styled headline at the top and a promotional SALE callout below — to
  // illustrate the variety of components this workflow produces. The lesson
  // teaches the workflow with the headline; the SALE block is rendered here
  // for visual richness in the hero only. Pixel design unit pairs the
  // font-size unit to pixels so the auto font-size bounds below are
  // interpreted as pixels.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1080)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)

  // Decorative SALE callout: a red text on a light-red background graphic.
  let saleBackground = try engine.block.create(.graphic)
  try engine.block.setShape(saleBackground, shape: engine.block.createShape(.rect))
  try engine.block.setFill(saleBackground, fill: engine.block.createFill(.color))
  let saleFill = try engine.block.getFill(saleBackground)
  try engine.block.setColor(saleFill, property: "fill/color/value", color: .rgba(r: 1.0, g: 0.92, b: 0.86, a: 1.0))
  try engine.block.setWidthMode(saleBackground, mode: .absolute)
  try engine.block.setHeightMode(saleBackground, mode: .absolute)
  try engine.block.setWidth(saleBackground, value: 720)
  try engine.block.setHeight(saleBackground, value: 280)
  try engine.block.setPositionX(saleBackground, value: 180)
  try engine.block.setPositionY(saleBackground, value: 680)
  try engine.block.appendChild(to: page, child: saleBackground)

  let saleText = try engine.block.create(.text)
  try engine.block.replaceText(saleText, text: "SALE 50%")
  try engine.block.setTextFontSize(saleText, fontSize: 140)
  try engine.block.setTextColor(saleText, color: .rgba(r: 0.78, g: 0.16, b: 0.16, a: 1.0))
  try engine.block.setWidthMode(saleText, mode: .absolute)
  try engine.block.setHeightMode(saleText, mode: .absolute)
  try engine.block.setWidth(saleText, value: 720)
  try engine.block.setHeight(saleText, value: 280)
  try engine.block.setPositionX(saleText, value: 180)
  try engine.block.setPositionY(saleText, value: 680)
  try engine.block.appendChild(to: page, child: saleText)

  // Subtitle copy explaining what readers see — visual filler for the hero.
  let subtitle = try engine.block.create(.text)
  try engine.block.replaceText(subtitle, text: "Reusable text designs you can save and apply")
  try engine.block.setTextFontSize(subtitle, fontSize: 44)
  try engine.block.setTextColor(subtitle, color: .rgba(r: 0.40, g: 0.45, b: 0.52, a: 1.0))
  try engine.block.setWidthMode(subtitle, mode: .absolute)
  try engine.block.setHeightMode(subtitle, mode: .absolute)
  try engine.block.setWidth(subtitle, value: 800)
  try engine.block.setHeight(subtitle, value: 120)
  try engine.block.setPositionX(subtitle, value: 140)
  try engine.block.setPositionY(subtitle, value: 470)
  try engine.block.appendChild(to: page, child: subtitle)

  // highlight-textDesigns-designComponent
  let component = try engine.block.create(.text)
  try engine.block.replaceText(component, text: "Headline")
  try engine.block.setTextFontSize(component, fontSize: 160)
  try engine.block.setTextColor(component, color: .rgba(r: 0.122, g: 0.161, b: 0.216, a: 1.0))
  try engine.block.setWidthMode(component, mode: .absolute)
  try engine.block.setHeightMode(component, mode: .absolute)
  try engine.block.setWidth(component, value: 800)
  try engine.block.setHeight(component, value: 280)
  try engine.block.setPositionX(component, value: 140)
  try engine.block.setPositionY(component, value: 160)
  try engine.block.appendChild(to: page, child: component)
  // highlight-textDesigns-designComponent

  // highlight-textDesigns-constraints
  try engine.block.setBool(component, property: "text/clipLinesOutsideOfFrame", value: true)
  try engine.block.setBool(component, property: "text/automaticFontSizeEnabled", value: true)
  try engine.block.setFloat(component, property: "text/minAutomaticFontSize", value: 32)
  try engine.block.setFloat(component, property: "text/maxAutomaticFontSize", value: 200)
  // highlight-textDesigns-constraints

  try await engine.captureGuide(page, label: "hero")

  // highlight-textDesigns-saveArchive
  let archive = try await engine.block.saveToArchive(blocks: [component])
  let archiveURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("text-design-\(UUID().uuidString).zip")
  try archive.write(to: archiveURL)
  // highlight-textDesigns-saveArchive

  // highlight-textDesigns-thumbnail
  let thumbnail = try await engine.block.export(
    component,
    mimeType: .png,
    options: ExportOptions(targetWidth: 400, targetHeight: 320),
  )
  let thumbnailURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("text-design-\(UUID().uuidString).png")
  try thumbnail.write(to: thumbnailURL)
  // highlight-textDesigns-thumbnail

  // highlight-textDesigns-registerSource
  try engine.asset.addLocalSource(sourceID: "my-text-components", applyAsset: { [weak engine] asset in
    guard let engine, let uri = asset.meta?["uri"], let url = URL(string: uri) else { return nil }
    let loaded = try await engine.block.loadArchive(from: url)
    guard let newBlock = loaded.first else { return nil }
    if let currentPage = try await engine.scene.getCurrentPage() {
      try await engine.block.appendChild(to: currentPage, child: newBlock)
    }
    return newBlock
  })
  // highlight-textDesigns-registerSource

  // highlight-textDesigns-addAsset
  let component1 = AssetDefinition(
    id: "ly.img.text.components.headline",
    meta: [
      "uri": archiveURL.absoluteString,
      "thumbUri": thumbnailURL.absoluteString,
      "mimeType": "application/ubq-blocks-archive",
    ],
    label: ["en": "Headline", "de": "Überschrift"],
  )
  try engine.asset.addAsset(to: "my-text-components", asset: component1)
  try engine.asset.assetSourceContentsChanged(sourceID: "my-text-components")
  // highlight-textDesigns-addAsset

  // highlight-textDesigns-loadFromJson
  let contentJSONURL = URL(
    string: "https://your-backend.example.com/assets/ly.img.text.components/content.json",
  )!
  // try await engine.asset.addLocalAssetSourceFromJSON(contentJSONURL)
  // highlight-textDesigns-loadFromJson
  _ = contentJSONURL
}
