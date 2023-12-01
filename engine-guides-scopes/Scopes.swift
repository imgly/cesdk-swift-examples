import Foundation
import IMGLYEngine

@MainActor
func scopes(engine: Engine) async throws {
  // highlight-setup
  let scene = try await engine.scene.create(fromImage:
    .init(string: "https://img.ly/static/ubq_samples/imgly_logo.jpg")!)
  let block = try engine.block.find(byType: .graphic).first!
  // highlight-setup

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
