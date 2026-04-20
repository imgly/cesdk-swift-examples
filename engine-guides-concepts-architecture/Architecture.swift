import Foundation
import IMGLYEngine

@MainActor
func architecture(engine: Engine) async throws {
  // highlight-architecture-apis
  // The engine exposes six API namespaces:
  _ = engine.scene // Scene API — content hierarchy
  _ = engine.block // Block API — create and modify blocks
  _ = engine.asset // Asset API — manage asset sources
  _ = engine.editor // Editor API — edit modes, undo/redo, roles
  _ = engine.event // Event API — subscribe to changes
  _ = engine.variable // Variable API — template variables
  // highlight-architecture-apis

  // highlight-architecture-hierarchy
  // Create a scene with a page and a graphic block.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  try engine.block.appendChild(to: page, child: block)

  // Traverse the hierarchy.
  let pages = try engine.scene.getPages()
  let children = try engine.block.getChildren(pages.first!)
  // highlight-architecture-hierarchy

  _ = children

  // highlight-architecture-sceneModes
  // Design mode — static designs like social posts and print materials.
  let designScene = try engine.scene.create()

  // Video mode — time-based content with playback and timeline.
  let videoScene = try engine.scene.createVideo()
  // highlight-architecture-sceneModes

  _ = designScene
  _ = videoScene

  // highlight-architecture-events
  // Subscribe to block changes using AsyncStream.
  let subscription = engine.event.subscribe(to: [scene])
  Task {
    for await events in subscription {
      for event in events {
        print("Block \(event.block) had event: \(event.type)")
      }
    }
  }
  // highlight-architecture-events

  // highlight-architecture-variables
  // Set and retrieve template variables.
  try engine.variable.set(key: "username", value: "Jane")
  let username = try engine.variable.get(key: "username")
  // highlight-architecture-variables

  _ = username
}
