import Foundation
import IMGLYEngine

@MainActor
func storeMetadata(engine: Engine) async throws {
  // highlight-setup
  var scene = try await engine.scene.create(from: .init(string: "https://img.ly/static/ubq_samples/imgly_logo.jpg")!)
  let image = try engine.block.find(byType: .image).first!
  // highlight-setup

  // highlight-setMetadata
  try engine.block.setMetadata(scene, key: "author", value: "img.ly")
  try engine.block.setMetadata(image, key: "customer_id", value: "1234567890")

  /* We can even store complex objects */
  struct Payment: Encodable {
    let id: Int
    let method: String
    let received: Bool
  }

  let payment = Payment(id: 5, method: "credit_card", received: true)

  try engine.block.setMetadata(
    image,
    key: "payment",
    value: String(data: JSONEncoder().encode(payment), encoding: .utf8)!
  )
  // highlight-setMetadata

  // highlight-getMetadata
  /* This will return "img.ly" */
  try engine.block.getMetadata(scene, key: "author")

  /* This will return "1000000" */
  try engine.block.getMetadata(image, key: "customer_id")
  // highlight-getMetadata

  // highlight-findAllMetadata
  /* This will return ["customer_id"] */
  try engine.block.findAllMetadata(image)
  // highlight-findAllMetadata

  // highlight-removeMetadata
  try engine.block.removeMetadata(image, key: "payment")

  /* This will return false */
  try engine.block.hasMetadata(image, key: "payment")
  // highlight-removeMetadata

  // highlight-persistence
  /* We save our scene and reload it from scratch */
  let sceneString = try await engine.scene.saveToString()
  scene = try await engine.scene.load(fromString: sceneString)

  /* This still returns "img.ly" */
  try engine.block.getMetadata(scene, key: "author")

  /* And this still returns "1234567890" */
  try engine.block.getMetadata(image, key: "customer_id")
  // highlight-persistence
}
