import Foundation
import IMGLYEngine

// highlight-imglyPremium-model
// A Decodable model matching the `content.json` manifest that ships with the
// IMG.LY premium asset package. Each template carries the design archive `uri`
// and a `thumbUri`, both using `{{base_url}}` placeholders so the package stays
// portable across hosting locations.
private struct PremiumTemplateManifest: Decodable {
  struct Template: Decodable {
    let id: String
    let label: [String: String]?
    let meta: [String: String]
  }

  let id: String
  let assets: [Template]
}

// highlight-imglyPremium-model

@MainActor
func imglyPremiumAssets(engine: Engine) async throws {
  // A design scene the premium templates apply into. In your app this is
  // whatever the user is currently editing.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1080)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)

  // Stand in for the hosted premium package so the example runs offline: save
  // the current scene to a real design archive under a per-template directory
  // that plays the role of your hosting location. In production this directory
  // is your server or CDN and already contains the extracted IMG.LY premium
  // package (its `content.json`, per-template design archives, and thumbnails).
  let hostingURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("premium-\(UUID().uuidString)", isDirectory: true)
  let templateDirURL = hostingURL.appendingPathComponent("modern-social-story", isDirectory: true)
  try FileManager.default.createDirectory(at: templateDirURL, withIntermediateDirectories: true)
  let archive = try await engine.scene.saveToArchive()
  try archive.write(to: templateDirURL.appendingPathComponent("design.zip"))
  let baseURL = hostingURL.absoluteString

  // highlight-imglyPremium-manifest
  let manifestJSON = """
  {
    "version": "1.0",
    "id": "imgly-premium-templates",
    "assets": [
      {
        "id": "modern-social-story",
        "label": { "en": "Modern Social Media Story" },
        "meta": {
          "uri": "{{base_url}}/modern-social-story/design.zip",
          "thumbUri": "{{base_url}}/modern-social-story/thumbnail.jpg"
        }
      }
    ]
  }
  """
  let manifest = try JSONDecoder().decode(
    PremiumTemplateManifest.self,
    from: Data(manifestJSON.utf8),
  )
  // highlight-imglyPremium-manifest

  // highlight-imglyPremium-source
  try engine.asset.addLocalSource(sourceID: manifest.id, applyAsset: { [weak engine] asset in
    guard let engine, let uri = asset.meta?["uri"], let url = URL(string: uri) else {
      return nil
    }
    try await engine.scene.load(from: url)
    return nil
  })
  // highlight-imglyPremium-source

  // highlight-imglyPremium-addTemplates
  for template in manifest.assets {
    let resolvedMeta = template.meta.mapValues {
      $0.replacingOccurrences(of: "{{base_url}}", with: baseURL)
    }
    try engine.asset.addAsset(
      to: manifest.id,
      asset: AssetDefinition(id: template.id, meta: resolvedMeta, label: template.label),
    )
  }
  // highlight-imglyPremium-addTemplates

  // highlight-imglyPremium-verify
  let templates = try await engine.asset.findAssets(
    sourceID: manifest.id,
    query: .init(query: nil, page: 0, perPage: 10),
  )
  print("Premium templates available:", templates.total)
  // highlight-imglyPremium-verify

  // highlight-imglyPremium-apply
  if let first = templates.assets.first {
    let appliedBlock = try await engine.asset.apply(sourceID: manifest.id, assetResult: first)
    print("Applied template, resulting block:", appliedBlock as Any)
  }
  // highlight-imglyPremium-apply
}
