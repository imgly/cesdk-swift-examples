import Foundation
import IMGLYEngine

@MainActor
func scopes(engine: Engine) async throws {
  // highlight-setup
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
  // highlight-setup

  // highlight-findAllScopes
  let scopes = try engine.editor.findAllScopes()
  // highlight-findAllScopes

  // highlight-setGlobalScope
  /* Let the global scope defer to the block-level. */
  try engine.editor.setGlobalScope(key: "layer/move", value: .defer)

  /* Manipulation of layout properties of any block will fail at this point. */
  do {
    try engine.block.setPositionX(block, value: 100) // Not allowed
  } catch {
    print(error.localizedDescription)
  }

  // highlight-setGlobalScope

  // highlight-getGlobalScope
  /* This will return `.defer`. */
  try engine.editor.getGlobalScope(key: "layer/move")
  // highlight-getGlobalScope

  // highlight-setScopeEnabled
  /* Allow the user to control the layout properties of the image block. */
  try engine.block.setScopeEnabled(block, key: "layer/move", enabled: true)

  /* Manipulation of layout properties of any block is now allowed. */
  do {
    try engine.block.setPositionX(block, value: 100) // Allowed
  } catch {
    print(error.localizedDescription)
  }

  // highlight-setScopeEnabled

  // highlight-isScopeEnabled
  /* Verify that the "layer/move" scope is now enabled for the image block. */
  try engine.block.isScopeEnabled(block, key: "layer/move")
  // highlight-isScopeEnabled

  // highlight-isAllowedByScope
  /* This will return true as well since the global scope is set to `.defer`. */
  try engine.block.isAllowedByScope(block, key: "layer/move")
  // highlight-isAllowedByScope
}
