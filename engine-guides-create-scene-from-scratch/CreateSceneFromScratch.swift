import Foundation
import IMGLYEngine

@MainActor
func createSceneFromScratch(engine: Engine) async throws {
  // highlight-create
  let scene = try engine.scene.create()
  // highlight-create

  // highlight-add-page
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-add-page

  // highlight-add-block-with-star-shape
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.star))
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  try engine.block.appendChild(to: page, child: block)
  // highlight-add-block-with-star-shape
}
