import IMGLYEngine

@MainActor
func rulesOverview(engine: Engine) async throws {
  // Set up a design scene with a page to host the demo blocks.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1600)
  try engine.block.setHeight(page, value: 1000)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-rulesOverview-globalScope
  // The default Creator role allows every scope globally, which would short-circuit
  // the block-level checks below — set each scope to `.defer` to honor per-block settings.
  // Layer operations
  try engine.editor.setGlobalScope(key: "layer/move", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/resize", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/rotate", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/flip", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/crop", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/opacity", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/blendMode", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/visibility", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/clipping", value: .defer)
  // Appearance
  try engine.editor.setGlobalScope(key: "appearance/adjustments", value: .defer)
  try engine.editor.setGlobalScope(key: "appearance/filter", value: .defer)
  try engine.editor.setGlobalScope(key: "appearance/effect", value: .defer)
  try engine.editor.setGlobalScope(key: "appearance/blur", value: .defer)
  try engine.editor.setGlobalScope(key: "appearance/shadow", value: .defer)
  // Content editing
  try engine.editor.setGlobalScope(key: "fill/change", value: .defer)
  try engine.editor.setGlobalScope(key: "fill/changeType", value: .defer)
  try engine.editor.setGlobalScope(key: "stroke/change", value: .defer)
  // Lifecycle
  try engine.editor.setGlobalScope(key: "lifecycle/destroy", value: .defer)
  try engine.editor.setGlobalScope(key: "lifecycle/duplicate", value: .defer)
  try engine.editor.setGlobalScope(key: "editor/add", value: .defer)
  try engine.editor.setGlobalScope(key: "editor/select", value: .defer)
  // highlight-rulesOverview-globalScope

  // Create five demo blocks, one per scope configuration. Each is a gray
  // rectangle; only the name and per-block scope settings differ.
  let blockNames = [
    "Layer Operations Disabled",
    "Appearance Disabled",
    "Content Editing Disabled",
    "All Scopes Disabled",
    "All Scopes Enabled",
  ]
  var demoBlocks: [DesignBlockID] = []
  for name in blockNames {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setWidth(block, value: 300)
    try engine.block.setHeight(block, value: 300)
    let fill = try engine.block.createFill(.color)
    try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.6, g: 0.6, b: 0.6, a: 1))
    try engine.block.setFill(block, fill: fill)
    try engine.block.appendChild(to: page, child: block)
    try engine.block.setName(block, name: name)
    demoBlocks.append(block)
  }
  let layerBlock = demoBlocks[0]
  let appearanceBlock = demoBlocks[1]
  let contentBlock = demoBlocks[2]
  let lockedBlock = demoBlocks[3]
  let enabledBlock = demoBlocks[4]

  // The complete set of scopes, used to fully lock or fully unlock a block.
  let allScopes = [
    "layer/move", "layer/resize", "layer/rotate", "layer/flip", "layer/crop",
    "layer/opacity", "layer/blendMode", "layer/visibility", "layer/clipping",
    "appearance/adjustments", "appearance/filter", "appearance/effect",
    "appearance/blur", "appearance/shadow",
    "fill/change", "fill/changeType", "stroke/change",
    "lifecycle/destroy", "lifecycle/duplicate", "editor/add", "editor/select",
  ]

  // highlight-rulesOverview-blockScope
  try engine.block.setScopeEnabled(layerBlock, key: "layer/move", enabled: false)
  try engine.block.setScopeEnabled(layerBlock, key: "layer/resize", enabled: false)
  try engine.block.setScopeEnabled(layerBlock, key: "layer/rotate", enabled: false)
  try engine.block.setScopeEnabled(layerBlock, key: "layer/flip", enabled: false)
  try engine.block.setScopeEnabled(layerBlock, key: "layer/crop", enabled: false)
  try engine.block.setScopeEnabled(layerBlock, key: "layer/opacity", enabled: false)
  try engine.block.setScopeEnabled(layerBlock, key: "layer/blendMode", enabled: false)
  try engine.block.setScopeEnabled(layerBlock, key: "layer/visibility", enabled: false)
  try engine.block.setScopeEnabled(layerBlock, key: "layer/clipping", enabled: false)
  // Keep other categories editable.
  try engine.block.setScopeEnabled(layerBlock, key: "fill/change", enabled: true)
  try engine.block.setScopeEnabled(layerBlock, key: "lifecycle/destroy", enabled: true)
  try engine.block.setScopeEnabled(layerBlock, key: "editor/select", enabled: true)
  // highlight-rulesOverview-blockScope

  // Block 2: disable the appearance scopes.
  try engine.block.setScopeEnabled(appearanceBlock, key: "appearance/adjustments", enabled: false)
  try engine.block.setScopeEnabled(appearanceBlock, key: "appearance/filter", enabled: false)
  try engine.block.setScopeEnabled(appearanceBlock, key: "appearance/effect", enabled: false)
  try engine.block.setScopeEnabled(appearanceBlock, key: "appearance/blur", enabled: false)
  try engine.block.setScopeEnabled(appearanceBlock, key: "appearance/shadow", enabled: false)

  // Block 3: disable the content-editing scopes.
  try engine.block.setScopeEnabled(contentBlock, key: "fill/change", enabled: false)
  try engine.block.setScopeEnabled(contentBlock, key: "fill/changeType", enabled: false)
  try engine.block.setScopeEnabled(contentBlock, key: "stroke/change", enabled: false)

  // Block 4: disable every scope, fully locking the block.
  for scope in allScopes {
    try engine.block.setScopeEnabled(lockedBlock, key: scope, enabled: false)
  }

  // Block 5: enable every scope, leaving the block fully editable.
  for scope in allScopes {
    try engine.block.setScopeEnabled(enabledBlock, key: scope, enabled: true)
  }

  // highlight-rulesOverview-checkScope
  let canMoveLayer = try engine.block.isAllowedByScope(layerBlock, key: "layer/move")
  let canMoveEnabled = try engine.block.isAllowedByScope(enabledBlock, key: "layer/move")
  let canMoveLocked = try engine.block.isAllowedByScope(lockedBlock, key: "layer/move")

  print("Layer block - can move: \(canMoveLayer)") // false
  print("Enabled block - can move: \(canMoveEnabled)") // true
  print("Locked block - can move: \(canMoveLocked)") // false
  // highlight-rulesOverview-checkScope

  // highlight-rulesOverview-denyGlobal
  try engine.editor.setGlobalScope(key: "layer/flip", value: .deny)
  let canFlipEnabled = try engine.block.isAllowedByScope(enabledBlock, key: "layer/flip")

  print("Enabled block - can flip after global deny: \(canFlipEnabled)") // false
  // highlight-rulesOverview-denyGlobal
}
