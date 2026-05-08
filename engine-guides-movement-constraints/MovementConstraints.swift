// highlight-movement-constraints
import Foundation
import IMGLYEngine

@MainActor
func movementConstraints(engine: Engine) async throws {
  // highlight-movement-constraint-setup
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.appendChild(to: page, child: block)
  // highlight-movement-constraint-setup

  // highlight-movement-constraint-scene-wide
  // Allow every block in the scene to overshoot by 20% of its own size.
  try engine.editor.setMovementConstraint(MovementConstraintRule(overshoot: 0.2))
  // highlight-movement-constraint-scene-wide

  // highlight-movement-constraint-per-type
  // Pin all text and caption blocks fully inside the page.
  try engine.editor.setMovementConstraint([
    MovementConstraintRule(overshoot: 0, scope: .blockType("text")),
    MovementConstraintRule(overshoot: 0, scope: .blockType("caption")),
  ])
  // highlight-movement-constraint-per-type

  // highlight-movement-constraint-per-page
  // Override the scene-wide default for blocks on this page.
  try engine.editor.setMovementConstraint(
    MovementConstraintRule(overshoot: 0.1, scope: .block(page)),
  )
  // highlight-movement-constraint-per-page

  // highlight-movement-constraint-per-block
  // Override every other level for one specific block.
  try engine.editor.setMovementConstraint(
    MovementConstraintRule(overshoot: 0, scope: .block(block)),
  )
  // highlight-movement-constraint-per-block

  // highlight-movement-constraint-read
  // Read the resolved constraint, walking the priority chain:
  // block > parent page > blockType > scene-wide.
  let active = try engine.editor.getMovementConstraint(block)
  // highlight-movement-constraint-read

  // highlight-movement-constraint-remove
  // Clear a scope by passing the matching descriptor. Use no argument to remove
  // the scene-wide default.
  try engine.editor.removeMovementConstraint(.block(block)) // per-block
  try engine.editor.removeMovementConstraint(.blockType("text")) // per-type
  try engine.editor.removeMovementConstraint(.block(page)) // per-page
  try engine.editor.removeMovementConstraint() // scene-wide default
  // highlight-movement-constraint-remove

  _ = active
}

// highlight-movement-constraints
