import Foundation
import IMGLYEngine

@MainActor
func storeMetadata(engine: Engine) async throws {
  // highlight-setup
  var scene = try await engine.scene.create(fromImage:
    .init(string: "https://img.ly/static/ubq_samples/imgly_logo.jpg")!)
  let block = try engine.block.find(byType: .page).first!
  // highlight-setup

  // highlight-setMetadata
  try engine.block.setMetadata(scene, key: "author", value: "img.ly")
  try engine.block.setMetadata(block, key: "customer_id", value: "1234567890")

  /* We can even store complex objects */
  struct Payment: Encodable {
    let id: Int
    let method: String
    let received: Bool
  }

  let payment = Payment(id: 5, method: "credit_card", received: true)

  try engine.block.setMetadata(
    block,
    key: "payment",
    value: String(data: JSONEncoder().encode(payment), encoding: .utf8)!,
  )
  // highlight-setMetadata

  // highlight-getMetadata
  /* This will return "img.ly" */
  try engine.block.getMetadata(scene, key: "author")

  /* This will return "1000000" */
  try engine.block.getMetadata(block, key: "customer_id")
  // highlight-getMetadata

  // highlight-findAllMetadata
  /* This will return ["customer_id"] */
  try engine.block.findAllMetadata(block)
  // highlight-findAllMetadata

  // highlight-removeMetadata
  try engine.block.removeMetadata(block, key: "payment")

  /* This will return false */
  try engine.block.hasMetadata(block, key: "payment")
  // highlight-removeMetadata

  // highlight-persistence
  /* We save our scene and reload it from scratch */
  let sceneString = try await engine.scene.saveToString()
  scene = try await engine.scene.load(from: sceneString)

  /* This still returns "img.ly" */
  try engine.block.getMetadata(scene, key: "author")

  /* And this still returns "1234567890" */
  try engine.block.getMetadata(block, key: "customer_id")
  // highlight-persistence
}
