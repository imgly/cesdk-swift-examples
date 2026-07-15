import Foundation
import IMGLYEngine

@MainActor
func addToTemplateLibrary(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // Load a design so there is something to save as a template. In your app this
  // is whatever the user is currently editing.
  let starterURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: starterURL)

  // highlight-addToTemplateLibrary-saveString
  let templateString = try await engine.scene.saveToString()
  let stringURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("template-\(UUID().uuidString).scene")
  try templateString.write(to: stringURL, atomically: true, encoding: .utf8)
  // highlight-addToTemplateLibrary-saveString

  // highlight-addToTemplateLibrary-saveArchive
  let templateArchive = try await engine.scene.saveToArchive()
  let archiveURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("template-\(UUID().uuidString).zip")
  try templateArchive.write(to: archiveURL)
  // highlight-addToTemplateLibrary-saveArchive

  // highlight-addToTemplateLibrary-createSource
  try engine.asset.addLocalSource(sourceID: "my-templates", applyAsset: { [weak engine] asset in
    guard let engine, let uri = asset.meta?["uri"], let url = URL(string: uri) else { return nil }
    try await engine.scene.applyTemplate(from: url)
    return nil
  })
  // highlight-addToTemplateLibrary-createSource

  // highlight-addToTemplateLibrary-addTemplates
  let templates = [
    AssetDefinition(
      id: "template-business-card",
      meta: [
        "uri": baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene").absoluteString,
        "thumbUri": baseURL.appendingPathComponent("ly.img.templates/thumbnails/cesdk_business_card_1.jpg")
          .absoluteString,
      ],
      label: ["en": "Business Card"],
    ),
    AssetDefinition(
      id: "template-blank",
      meta: [
        "uri": baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_blank_1.scene").absoluteString,
        "thumbUri": baseURL.appendingPathComponent("ly.img.templates/thumbnails/cesdk_blank_1.png").absoluteString,
      ],
      label: ["en": "Blank"],
    ),
    AssetDefinition(
      id: "template-postcard",
      meta: [
        "uri": baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_postcard_1.scene").absoluteString,
        "thumbUri": baseURL.appendingPathComponent("ly.img.templates/thumbnails/cesdk_postcard_1.jpg").absoluteString,
      ],
      label: ["en": "Postcard"],
    ),
  ]
  for template in templates {
    try engine.asset.addAsset(to: "my-templates", asset: template)
  }
  // highlight-addToTemplateLibrary-addTemplates

  // highlight-addToTemplateLibrary-manage
  let sources = engine.asset.findAllSources()
  print("Registered sources:", sources)

  let results = try await engine.asset.findAssets(
    sourceID: "my-templates",
    query: .init(query: nil, page: 0, perPage: 10),
  )
  print("Templates in library:", results.total)

  try engine.asset.removeAsset(from: "my-templates", assetID: "template-postcard")
  try engine.asset.assetSourceContentsChanged(sourceID: "my-templates")
  // highlight-addToTemplateLibrary-manage
}
