import Foundation
import IMGLYEngine

@MainActor
func editingWorkflow(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block, value: 100)
  try engine.block.setHeight(block, value: 100)
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  try engine.block.appendChild(to: page, child: block)

  // highlight-editingWorkflow-roles
  // Roles define user types: "Creator", "Adopter", "Viewer", "Presenter"
  let role = try engine.editor.getRole()
  print("Current role:", role) // "Creator"

  // Switch to a different role
  try engine.editor.setRole("Adopter")
  print("New role:", try engine.editor.getRole()) // "Adopter"

  // Switch back to Creator for the rest of the guide
  try engine.editor.setRole("Creator")
  // highlight-editingWorkflow-roles

  // highlight-editingWorkflow-globalScopes
  // Set global scopes to 'Defer' so block-level settings take effect
  try engine.editor.setGlobalScope(key: "editor/select", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/move", value: .defer)
  try engine.editor.setGlobalScope(key: "text/edit", value: .defer)
  try engine.editor.setGlobalScope(key: "lifecycle/destroy", value: .defer)

  // Query a global scope value
  let moveScope = try engine.editor.getGlobalScope(key: "layer/move")
  print("Global 'layer/move' scope:", moveScope) // .defer

  // List all available scopes
  let allScopes = try engine.editor.findAllScopes()
  print("Available scopes:", allScopes.count)
  // highlight-editingWorkflow-globalScopes

  // highlight-editingWorkflow-blockScopes
  // Lock the block — Adopters cannot select, move, or delete it
  try engine.block.setScopeEnabled(block, key: "editor/select", enabled: false)
  try engine.block.setScopeEnabled(block, key: "layer/move", enabled: false)
  try engine.block.setScopeEnabled(block, key: "lifecycle/destroy", enabled: false)

  // Query a block-level scope
  let canMove = try engine.block.isScopeEnabled(block, key: "layer/move")
  print("Block 'layer/move' enabled:", canMove) // false
  // highlight-editingWorkflow-blockScopes

  // highlight-editingWorkflow-checkPermissions
  // Check the final resolved permission (role + global + block scopes)
  let isAllowed = try engine.block.isAllowedByScope(block, key: "layer/move")
  print("Moving allowed:", isAllowed) // false (global is .defer, block is disabled)
  // highlight-editingWorkflow-checkPermissions

  // highlight-editingWorkflow-switchRole
  // Switch to Adopter — restrictions now apply
  try engine.editor.setRole("Adopter")

  let isAllowedAsAdopter = try engine.block.isAllowedByScope(block, key: "layer/move")
  print("Moving allowed as Adopter:", isAllowedAsAdopter) // false

  // Switch back to Creator — full access restored
  try engine.editor.setRole("Creator")

  let isAllowedAsCreator = try engine.block.isAllowedByScope(block, key: "layer/move")
  print("Moving allowed as Creator:", isAllowedAsCreator) // true
  // highlight-editingWorkflow-switchRole
}
