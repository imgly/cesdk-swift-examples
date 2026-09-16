import Foundation
import IMGLYEngine

@MainActor
func importFromSceneFile(engine: Engine) async throws {
  // Base URL the sample templates are resolved against. In your app this is the
  // location where you host your own `.scene` files.
  let baseURL = try engine.guidesBaseURL

  // Prepare a local archive for the next section: load a sample template and
  // save it as an archive. In production, archiveURL points to your own
  // archive — a remote URL on your CDN or a local file URL — and load(from:)
  // accepts either. Archives use the .imgly extension now (.zip remains
  // loadable).
  let setupSceneURL = baseURL
    .appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: setupSceneURL)
  let archiveData = try await engine.scene.saveToArchive()
  let archiveURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("imported-template-\(UUID().uuidString).imgly")
  try archiveData.write(to: archiveURL)

  // highlight-importFromSceneFile-loadFromArchive
  try await engine.scene.load(from: archiveURL)
  // highlight-importFromSceneFile-loadFromArchive

  // highlight-importFromSceneFile-loadFromURL
  let sceneURL = baseURL
    .appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: sceneURL)
  // highlight-importFromSceneFile-loadFromURL

  if let loadedPage = try engine.scene.getPages().first {
    try await engine.captureGuide(loadedPage, label: "after-load-url")
  }

  // highlight-importFromSceneFile-applyTemplate
  // Create a scene whose page dimensions the template content must adapt to.
  let designScene = try engine.scene.create()
  try engine.block.setFloat(designScene, property: "scene/pageDimensions/width", value: 1920)
  try engine.block.setFloat(designScene, property: "scene/pageDimensions/height", value: 1080)
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: designScene, child: page)

  let templateURL = baseURL
    .appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.applyTemplate(from: templateURL)
  // highlight-importFromSceneFile-applyTemplate

  if let appliedPage = try engine.scene.getPages().first {
    try await engine.captureGuide(appliedPage, label: "hero")
  }

  // highlight-importFromSceneFile-getScene
  guard let scene = try engine.scene.get() else { return }
  let pages = try engine.scene.getPages()
  print("Scene \(scene) contains \(pages.count) page(s)")
  // highlight-importFromSceneFile-getScene

  // highlight-importFromSceneFile-errorHandling
  // Demo: this URL has no scene file behind it.
  let missingTemplateURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("missing-template.scene")
  do {
    try await engine.scene.load(from: missingTemplateURL)
  } catch {
    print("Failed to load template:", error.localizedDescription)
  }
  // highlight-importFromSceneFile-errorHandling
}
