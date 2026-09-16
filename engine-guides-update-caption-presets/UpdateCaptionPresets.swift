import Foundation
import IMGLYEngine

@MainActor
func updateCaptionPresets(engine: Engine) async throws {
  // A caption block to apply presets to. Caption tracks and blocks are covered
  // in the Add Captions guide; this is the minimum a preset needs to target.
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.editor.setSettingBool("features/videoCaptionsEnabled", value: true)

  let captionTrack = try engine.block.create(.captionTrack)
  try engine.block.appendChild(to: page, child: captionTrack)
  let caption = try engine.block.create(.caption)
  try engine.block.setString(caption, property: "caption/text", value: "Your caption text")
  try engine.block.appendChild(to: captionTrack, child: caption)

  // highlight-updateCaptionPresets-defineStylePreset
  let neonGlowStyle = """
  {
    "blockType": "//ly.img.ubq/caption",
    "mode": "replace",
    "typeface": { "family": "Manrope", "weight": "bold", "style": "normal" },
    "properties": {
      "caption/horizontalAlignment": "Center",
      "caption/verticalAlignment": "Center",
      "fill/enabled": true,
      "fill/solid/color": { "r": 0, "g": 1, "b": 1, "a": 1 },
      "dropShadow/enabled": true,
      "dropShadow/color": { "r": 0, "g": 1, "b": 1, "a": 1 },
      "dropShadow/offset/x": 0,
      "dropShadow/offset/y": 0,
      "dropShadow/blurRadius/x": 8,
      "dropShadow/blurRadius/y": 8
    },
    "scaleWithFontSize": [
      { "property": "dropShadow/blurRadius/x", "ratio": 0.2 },
      { "property": "dropShadow/blurRadius/y", "ratio": 0.2 }
    ]
  }
  """
  // highlight-updateCaptionPresets-defineStylePreset

  // highlight-updateCaptionPresets-hostPresets
  let contentJSON = """
  {
    "version": "7.0.0",
    "id": "ly.img.caption.presets",
    "assets": [
      {
        "id": "ly.img.caption.presets.neon-glow",
        "label": { "en": "Neon Glow" },
        "groups": ["caption"],
        "meta": { "thumbUri": "{{base_url}}/ly.img.caption.presets/thumbnails/neon-glow.png" },
        "payload": { "stylePreset": \(neonGlowStyle) }
      }
    ]
  }
  """
  let contentURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("ly.img.caption.presets-content.json")
  try contentJSON.write(to: contentURL, atomically: true, encoding: .utf8)
  let captionPresetsSourceID = try await engine.asset.addLocalAssetSourceFromJSON(contentURL)
  // highlight-updateCaptionPresets-hostPresets

  // highlight-updateCaptionPresets-registerPreset
  let boldBackgroundStyle = """
  {
    "blockType": "//ly.img.ubq/caption",
    "mode": "replace",
    "properties": {
      "caption/horizontalAlignment": "Center",
      "fill/enabled": true,
      "fill/solid/color": { "r": 1, "g": 1, "b": 1, "a": 1 },
      "backgroundColor/enabled": true,
      "backgroundColor/color": { "r": 0, "g": 0, "b": 0, "a": 0.6 }
    }
  }
  """
  let boldBackground = AssetDefinition(
    id: "ly.img.caption.presets.bold-background",
    groups: ["caption"],
    meta: ["thumbUri": "https://example.com/caption-presets/bold-background.png"],
    payload: AssetPayload(stylePreset: boldBackgroundStyle),
    label: ["en": "Bold Background"],
  )
  try engine.asset.addAsset(to: captionPresetsSourceID, asset: boldBackground)
  // highlight-updateCaptionPresets-registerPreset

  // highlight-updateCaptionPresets-applyPreset
  let presets = try await engine.asset.findAssets(
    sourceID: captionPresetsSourceID,
    query: AssetQueryData(query: nil, page: 0, groups: ["caption"], perPage: 10),
  )
  if let neonGlow = presets.assets.first(where: { $0.id == "ly.img.caption.presets.neon-glow" }) {
    try await engine.asset.applyToBlock(sourceID: captionPresetsSourceID, assetResult: neonGlow, block: caption)
  }
  // highlight-updateCaptionPresets-applyPreset
}
