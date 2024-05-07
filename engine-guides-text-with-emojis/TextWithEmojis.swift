import Foundation
import IMGLYEngine

@MainActor
func textWithEmojis(engine: Engine) async throws {
  // highlight-change-default-emoji-font
  let uri = try engine.editor.getSettingString("ubq://defaultEmojiFontFileUri")
  // From a bundle
  try engine.editor.setSettingString(
    "ubq://defaultEmojiFontFileUri",
    value: "bundle://ly.img.cesdk/fonts/NotoColorEmoji.ttf"
  )
  // From a URL
  try engine.editor.setSettingString(
    "ubq://defaultEmojiFontFileUri",
    value: "https://cdn.img.ly/assets/v3/emoji/NotoColorEmoji.ttf"
  )
  // highlight-change-default-emoji-font

  // highlight-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)
  // highlight-setup

  // highlight-add-text-with-emoji
  let text = try engine.block.create(.text)
  try engine.block.setString(text, property: "text/text", value: "Text with an emoji 🧐")
  try engine.block.setWidth(text, value: 50)
  try engine.block.setHeight(text, value: 10)
  try engine.block.appendChild(to: page, child: text)
  // highlight-add-text-with-emoji
}
