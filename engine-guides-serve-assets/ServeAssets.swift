import Foundation
import IMGLYEngine

// highlight-serveAssets-defaultSourceIDs
private let serveAssetsDefaultSourceIDs = [
  "ly.img.sticker",
  "ly.img.vector.shape",
  "ly.img.filter",
  "ly.img.color.palette",
  "ly.img.effect",
  "ly.img.blur",
  "ly.img.typeface",
  "ly.img.crop.presets",
  "ly.img.page.presets",
  "ly.img.text",
  "ly.img.text.styles",
  "ly.img.text.curves",
  "ly.img.text.components",
]
// highlight-serveAssets-defaultSourceIDs

// highlight-serveAssets-demoSourceIDs
private let serveAssetsDemoSourceIDs = [
  "ly.img.image",
  "ly.img.video",
  "ly.img.audio",
  "ly.img.templates",
  "ly.img.templates.premium",
]
// highlight-serveAssets-demoSourceIDs

@MainActor
func serveAssets(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-serveAssets-registerDefaults
  for id in serveAssetsDefaultSourceIDs {
    _ = try await engine.asset.addLocalAssetSourceFromJSON(
      baseURL.appendingPathComponent(id).appendingPathComponent("content.json"),
    )
  }
  // highlight-serveAssets-registerDefaults

  // highlight-serveAssets-engineLevelAssets
  try engine.editor.setSettingString("basePath", value: baseURL.absoluteString)
  // highlight-serveAssets-engineLevelAssets
}

// Register the sample content sources (images, videos, audio, templates). These
// ship in the same archive and load the same way — replace them with your own
// content sources in production.
@MainActor
func serveAssetsSampleContent(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-serveAssets-registerDemo
  for id in serveAssetsDemoSourceIDs {
    _ = try await engine.asset.addLocalAssetSourceFromJSON(
      baseURL.appendingPathComponent(id).appendingPathComponent("content.json"),
    )
  }
  // highlight-serveAssets-registerDemo
}

// Variations showing where to host the assets. These are compile-only
// demonstrations — the test runs `serveAssets` against the bundled assets.

@MainActor
func serveAssetsFromRemoteServer(engine: Engine) async throws {
  // highlight-serveAssets-remoteBaseURL
  let baseURL = URL(string: "https://cdn.your.custom.domain/assets")!
  for id in serveAssetsDefaultSourceIDs {
    _ = try await engine.asset.addLocalAssetSourceFromJSON(
      baseURL.appendingPathComponent(id).appendingPathComponent("content.json"),
    )
  }
  // highlight-serveAssets-remoteBaseURL
}

@MainActor
func serveAssetsFromAppBundle(engine: Engine) async throws {
  // highlight-serveAssets-bundleBaseURL
  guard let baseURL = Bundle.main.url(forResource: "IMGLYAssets", withExtension: "bundle") else {
    return
  }
  for id in serveAssetsDefaultSourceIDs {
    _ = try await engine.asset.addLocalAssetSourceFromJSON(
      baseURL.appendingPathComponent(id).appendingPathComponent("content.json"),
    )
  }
  // highlight-serveAssets-bundleBaseURL
}
