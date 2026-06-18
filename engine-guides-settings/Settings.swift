import Foundation
import IMGLYEngine

@MainActor
func settings(engine: Engine) async throws {
  // highlight-settings-discover
  let allSettings = engine.editor.findAllSettings()
  let settingType = try engine.editor.getSettingType("doubleClickSelectionMode")
  // highlight-settings-discover

  // highlight-settings-read-write
  try engine.editor.setSettingBool("doubleClickToCropEnabled", value: true)
  let cropEnabled = try engine.editor.getSettingBool("doubleClickToCropEnabled")

  try engine.editor.setSettingInt("maxImageSize", value: 4096)
  let maxImageSize = try engine.editor.getSettingInt("maxImageSize")

  try engine.editor.setSettingFloat("positionSnappingThreshold", value: 2.0)
  let snappingThreshold = try engine.editor.getSettingFloat("positionSnappingThreshold")

  try engine.editor.setSettingString("page/title/separator", value: " | ")
  let separator = try engine.editor.getSettingString("page/title/separator")

  try engine.editor.setSettingColor("highlightColor", color: .rgba(r: 1, g: 0, b: 1, a: 1))
  let highlightColor: Color = try engine.editor.getSettingColor("highlightColor")

  let modes = try engine.editor.getSettingEnumOptions("doubleClickSelectionMode")
  try engine.editor.setSettingEnum("doubleClickSelectionMode", value: "Direct")
  let selectionMode = try engine.editor.getSettingEnum("doubleClickSelectionMode")
  // highlight-settings-read-write

  // highlight-settings-observe
  let settingsTask = Task {
    for await _ in engine.editor.onSettingsChanged {
      print("Editor settings have changed")
    }
  }
  // highlight-settings-observe

  // highlight-settings-role
  let role = try engine.editor.getRole()
  try engine.editor.setRole("Adopter")
  let roleTask = Task {
    for await newRole in engine.editor.onRoleChanged {
      print("Role changed to \(newRole)")
    }
  }
  // highlight-settings-role

  _ = (allSettings, settingType, cropEnabled, maxImageSize, snappingThreshold,
       separator, highlightColor, modes, selectionMode, role)
  settingsTask.cancel()
  roleTask.cancel()
}
