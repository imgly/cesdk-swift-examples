import Foundation
import IMGLYEngine

@MainActor
func setEditingConstraints(engine: Engine) throws {
  // Demo scaffolding: a scene and page to hold the constrained blocks.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1200)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-setEditingConstraints-globalScopes
  try engine.editor.setGlobalScope(key: "layer/move", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/resize", value: .defer)
  try engine.editor.setGlobalScope(key: "lifecycle/destroy", value: .defer)
  try engine.editor.setGlobalScope(key: "lifecycle/duplicate", value: .defer)
  // highlight-setEditingConstraints-globalScopes

  // Demo scaffolding: two renderable graphic blocks, constrained independently.
  let positionLocked = try engine.block.create(.graphic)
  try engine.block.setShape(positionLocked, shape: engine.block.createShape(.rect))
  try engine.block.setFill(positionLocked, fill: engine.block.createFill(.color))
  try engine.block.setWidth(positionLocked, value: 200)
  try engine.block.setHeight(positionLocked, value: 200)
  try engine.block.appendChild(to: page, child: positionLocked)

  let deletionLocked = try engine.block.create(.graphic)
  try engine.block.setShape(deletionLocked, shape: engine.block.createShape(.rect))
  try engine.block.setFill(deletionLocked, fill: engine.block.createFill(.color))
  try engine.block.setWidth(deletionLocked, value: 200)
  try engine.block.setHeight(deletionLocked, value: 200)
  try engine.block.appendChild(to: page, child: deletionLocked)

  // highlight-setEditingConstraints-lockPosition
  try engine.block.setScopeEnabled(positionLocked, key: "layer/move", enabled: false)
  try engine.block.setScopeEnabled(positionLocked, key: "layer/resize", enabled: true)
  // highlight-setEditingConstraints-lockPosition

  // highlight-setEditingConstraints-preventDeletion
  try engine.block.setScopeEnabled(deletionLocked, key: "lifecycle/destroy", enabled: false)
  try engine.block.setScopeEnabled(deletionLocked, key: "lifecycle/duplicate", enabled: false)
  try engine.block.setScopeEnabled(deletionLocked, key: "layer/move", enabled: true)
  try engine.block.setScopeEnabled(deletionLocked, key: "layer/resize", enabled: true)
  // highlight-setEditingConstraints-preventDeletion

  // highlight-setEditingConstraints-checkScope
  let canMove = try engine.block.isScopeEnabled(positionLocked, key: "layer/move")
  print("layer/move enabled at block level: \(canMove)") // false
  // highlight-setEditingConstraints-checkScope

  // highlight-setEditingConstraints-checkAllowed
  let moveAllowed = try engine.block.isAllowedByScope(positionLocked, key: "layer/move")
  print("layer/move allowed: \(moveAllowed)") // false
  // highlight-setEditingConstraints-checkAllowed
}
