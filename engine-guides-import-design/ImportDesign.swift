import Foundation
import IMGLYEngine

@MainActor
func importDesign(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-importDesign-loadFromURL
  let sceneURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: sceneURL)
  // highlight-importDesign-loadFromURL

  // Produce a serialized scene string for the next section. In production it
  // comes from your own storage — a database row, a file on disk, or the result
  // of a previous saveToString() call.
  let sceneString = try await engine.scene.saveToString()

  // highlight-importDesign-loadFromString
  try await engine.scene.load(from: sceneString)
  // highlight-importDesign-loadFromString

  // Produce a self-contained archive for the next section by saving the current
  // scene. In production archiveURL points to your own ZIP — a remote URL on
  // your CDN or a local file URL — created earlier with saveToArchive().
  let archiveData = try await engine.scene.saveToArchive()
  let archiveURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("imported-design-\(UUID().uuidString).zip")
  try archiveData.write(to: archiveURL)

  // highlight-importDesign-loadFromArchive
  try await engine.scene.loadArchive(from: archiveURL)
  // highlight-importDesign-loadFromArchive

  // highlight-importDesign-createFromImage
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_4.jpg")
  try await engine.scene.create(fromImage: imageURL)
  // highlight-importDesign-createFromImage

  // highlight-importDesign-createFromVideo
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )
  try await engine.scene.create(fromVideo: videoURL)
  // highlight-importDesign-createFromVideo

  // highlight-importDesign-modifyScene
  if let text = try engine.block.find(byType: .text).first {
    try engine.block.replaceText(text, text: "Updated heading")
  }
  // highlight-importDesign-modifyScene
}
