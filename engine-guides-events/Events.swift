import Foundation
import IMGLYEngine

@MainActor
// swiftlint:disable:next cyclomatic_complexity
func events(engine: Engine) async throws {
  // highlight-events-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.star))
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  try engine.block.appendChild(to: page, child: block)
  // highlight-events-setup

  // highlight-events-subscribeAll
  let allEventsTask = Task {
    for await events in engine.event.subscribe(to: []) {
      for event in events {
        print("Event: \(event.type) for block \(event.block)")
      }
    }
  }
  // highlight-events-subscribeAll

  // highlight-events-subscribeSpecific
  let specificTask = Task {
    for await events in engine.event.subscribe(to: [block]) {
      for event in events {
        print("Specific event: \(event.type) for block \(event.block)")
      }
    }
  }
  // highlight-events-subscribeSpecific

  try await Task.sleep(nanoseconds: NSEC_PER_SEC)

  // highlight-events-processEvents
  let processTask = Task {
    for await events in engine.event.subscribe(to: []) {
      for event in events {
        switch event.type {
        case .created:
          let type = try engine.block.getType(event.block)
          print("Block created: \(type)")
        case .updated:
          let type = try engine.block.getType(event.block)
          print("Block updated: \(type)")
        case .destroyed:
          print("Block destroyed: \(event.block)")
        @unknown default:
          break
        }
      }
    }
  }
  // highlight-events-processEvents

  try await Task.sleep(nanoseconds: NSEC_PER_SEC)

  // highlight-events-updated
  try engine.block.setRotation(block, radians: 0.5 * .pi)
  // highlight-events-updated

  try await Task.sleep(nanoseconds: NSEC_PER_SEC)

  // highlight-events-destroyedSafety
  if engine.block.isValid(block) {
    let type = try engine.block.getType(block)
    print("Block is valid: \(type)")
  }
  // highlight-events-destroyedSafety

  // highlight-events-destroyed
  try engine.block.destroy(block)
  // highlight-events-destroyed

  try await Task.sleep(nanoseconds: NSEC_PER_SEC)

  // highlight-events-unsubscribe
  allEventsTask.cancel()
  specificTask.cancel()
  processTask.cancel()
  // highlight-events-unsubscribe
}
