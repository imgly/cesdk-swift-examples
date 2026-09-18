import Foundation
import IMGLYEngine

@MainActor
func textWithEmojis(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-textWithEmojis-getFont
  let currentURI = try engine.editor.getSettingString("defaultEmojiFontFileUri")
  print("Current emoji font URI: \(currentURI)")
  // highlight-textWithEmojis-getFont

  // highlight-textWithEmojis-setCustomFont
  try engine.editor.setSettingString(
    "defaultEmojiFontFileUri",
    value: baseURL.appendingPathComponent("emoji/NotoColorEmoji.ttf").absoluteString,
  )
  // highlight-textWithEmojis-setCustomFont

  // Pixel design units pair the font-size unit to pixels, so the `text/fontSize`
  // value below is interpreted as pixels — the default font-size unit is
  // points, which the scene's DPI would otherwise scale up.
  let scene = try engine.scene.create(designUnit: .px)

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1080)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)

  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)

  // highlight-textWithEmojis-addText
  let text = try engine.block.create(.text)
  try engine.block.replaceText(text, text: "Hello World! 🎉 🇩🇪 👨‍👩‍👧 👋🏽")
  try engine.block.setWidth(text, value: 900)
  try engine.block.setHeight(text, value: 200)
  try engine.block.appendChild(to: page, child: text)
  // highlight-textWithEmojis-addText

  // Hero scaffolding: size the text and center it so emojis are legible at
  // thumbnail. The lesson itself does not require these calls, so they live
  // outside the highlight markers.
  try engine.block.setFloat(text, property: "text/fontSize", value: 64)
  try engine.block.setPositionX(text, value: 80)
  try engine.block.setPositionY(text, value: 480)

  // Snapshot the final scene as the guide's hero image. The label `"hero"` is
  // reserved and tells the promote script which baseline to convert to WebP.
  try await engine.captureGuide(page, label: "hero")
}
