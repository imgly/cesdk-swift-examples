import Foundation
import IMGLYEngine

@MainActor
func lockVideoDesign(engine: Engine) async throws {
  // Build a small video scene: one page with a track that holds one video
  // clip, plus an editable title overlay and a locked watermark overlay.
  // The blocks below are reference context for the scope calls in the
  // highlighted sections.
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 12)

  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)

  let baseURL = try engine.guidesBaseURL

  let videoClip = try engine.block.create(.graphic)
  try engine.block.setShape(videoClip, shape: engine.block.createShape(.rect))
  try engine.block.setDuration(videoClip, duration: 12)
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(
    videoFill,
    property: "fill/video/fileURI",
    value: baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4"),
  )
  try engine.block.setFill(videoClip, fill: videoFill)
  try engine.block.appendChild(to: track, child: videoClip)
  try engine.block.fillParent(track)

  let titleOverlay = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: titleOverlay)
  try engine.block.setWidthMode(titleOverlay, mode: .auto)
  try engine.block.setHeightMode(titleOverlay, mode: .auto)
  try engine.block.setPositionX(titleOverlay, value: 80)
  try engine.block.setPositionY(titleOverlay, value: 80)
  try engine.block.setDuration(titleOverlay, duration: 12)
  try engine.block.replaceText(titleOverlay, text: "Editable title")

  let watermarkOverlay = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: watermarkOverlay)
  try engine.block.setWidthMode(watermarkOverlay, mode: .auto)
  try engine.block.setHeightMode(watermarkOverlay, mode: .auto)
  try engine.block.setPositionX(watermarkOverlay, value: 980)
  try engine.block.setPositionY(watermarkOverlay, value: 640)
  try engine.block.setDuration(watermarkOverlay, duration: 12)
  try engine.block.replaceText(watermarkOverlay, text: "LOCKED")

  // highlight-lockVideoDesign-lockEntireDesign
  let scopes = engine.editor.findAllScopes()
  for scope in scopes {
    try engine.editor.setGlobalScope(key: scope, value: .deny)
  }
  // highlight-lockVideoDesign-lockEntireDesign

  // highlight-lockVideoDesign-enableSelection
  try engine.editor.setGlobalScope(key: "editor/select", value: .defer)
  try engine.block.setScopeEnabled(videoClip, key: "editor/select", enabled: true)
  try engine.block.setScopeEnabled(titleOverlay, key: "editor/select", enabled: true)
  try engine.block.setScopeEnabled(watermarkOverlay, key: "editor/select", enabled: false)
  // highlight-lockVideoDesign-enableSelection

  // highlight-lockVideoDesign-textOverlayEditing
  try engine.editor.setGlobalScope(key: "text/edit", value: .defer)
  try engine.editor.setGlobalScope(key: "text/character", value: .defer)
  try engine.block.setScopeEnabled(titleOverlay, key: "text/edit", enabled: true)
  try engine.block.setScopeEnabled(titleOverlay, key: "text/character", enabled: true)
  // highlight-lockVideoDesign-textOverlayEditing

  // highlight-lockVideoDesign-videoReplacement
  try engine.editor.setGlobalScope(key: "fill/change", value: .defer)
  try engine.block.setScopeEnabled(videoClip, key: "fill/change", enabled: true)
  // highlight-lockVideoDesign-videoReplacement

  // highlight-lockVideoDesign-layoutAdjustments
  try engine.editor.setGlobalScope(key: "layer/move", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/resize", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/rotate", value: .defer)
  try engine.block.setScopeEnabled(titleOverlay, key: "layer/move", enabled: true)
  try engine.block.setScopeEnabled(titleOverlay, key: "layer/resize", enabled: true)
  try engine.block.setScopeEnabled(titleOverlay, key: "layer/rotate", enabled: true)
  // highlight-lockVideoDesign-layoutAdjustments

  // highlight-lockVideoDesign-protectOverlay
  let lockedOverlayScopes = [
    "text/edit",
    "text/character",
    "fill/change",
    "layer/move",
    "layer/resize",
    "layer/rotate",
  ]
  for scope in lockedOverlayScopes {
    try engine.block.setScopeEnabled(watermarkOverlay, key: scope, enabled: false)
  }
  // highlight-lockVideoDesign-protectOverlay

  // highlight-lockVideoDesign-checkPermissions
  let canSelectVideoClip = try engine.block.isAllowedByScope(videoClip, key: "editor/select")
  let canReplaceVideoClip = try engine.block.isAllowedByScope(videoClip, key: "fill/change")
  let canMoveVideoClip = try engine.block.isAllowedByScope(videoClip, key: "layer/move")
  let canEditTitle = try engine.block.isAllowedByScope(titleOverlay, key: "text/edit")
  let canMoveTitle = try engine.block.isAllowedByScope(titleOverlay, key: "layer/move")
  let canSelectWatermark = try engine.block.isAllowedByScope(watermarkOverlay, key: "editor/select")

  let titleTextEditEnabled = try engine.block.isScopeEnabled(titleOverlay, key: "text/edit")
  let textEditGlobalScope = try engine.editor.getGlobalScope(key: "text/edit")

  print("Permission status:")
  print("- Can select video clip:", canSelectVideoClip) // true
  print("- Can replace video clip fill:", canReplaceVideoClip) // true
  print("- Can move video clip:", canMoveVideoClip) // false
  print("- Can edit title:", canEditTitle) // true
  print("- Can move title:", canMoveTitle) // true
  print("- Can select watermark:", canSelectWatermark) // false
  print("- Title text/edit block scope enabled:", titleTextEditEnabled) // true
  print("- text/edit global is .defer:", textEditGlobalScope == .defer) // true
  // highlight-lockVideoDesign-checkPermissions

  // highlight-lockVideoDesign-discoverScopes
  let availableScopes = engine.editor.findAllScopes()
  print("Available scopes:", availableScopes)

  for scope in availableScopes {
    let globalSetting = try engine.editor.getGlobalScope(key: scope)
    print("- \(scope) is .defer:", globalSetting == .defer)
  }
  // highlight-lockVideoDesign-discoverScopes
}
