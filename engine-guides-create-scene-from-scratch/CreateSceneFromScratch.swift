import Foundation
import IMGLYEngine

@MainActor
func createSceneFromScratch(engine: Engine) throws {
  // highlight-create
  let scene = try engine.scene.create()
  // highlight-create

  // highlight-add-page
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-add-page

  // highlight-add-star
  let star = try engine.block.create(.starShape)
  try engine.block.appendChild(to: page, child: star)
  // highlight-add-star
}
