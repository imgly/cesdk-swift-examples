import Foundation
import IMGLYEngine

@MainActor
func importTemplates(engine: Engine) async throws {
  // highlight-importTemplates-loadFromURL
  let templatesBase = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.0-rc.3/assets/ly.img.template/templates"
  let sceneURL = URL(string: "\(templatesBase)/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneURL)
  // highlight-importTemplates-loadFromURL

  // highlight-importTemplates-getScene
  guard let scene = try engine.scene.get() else { return }
  let pages = try engine.scene.getPages()
  print("Template has \(pages.count) page(s)")
  // highlight-importTemplates-getScene

  // highlight-importTemplates-zoomToScene
  try await engine.scene.zoom(
    to: scene,
    paddingLeft: 40,
    paddingTop: 40,
    paddingRight: 40,
    paddingBottom: 40,
  )
  // highlight-importTemplates-zoomToScene

  // Prepare a serialized scene string for the next section.
  // In production, sceneString comes from your database or a fetched .scene file.
  let sceneString = try await engine.scene.saveToString()

  // highlight-importTemplates-loadFromString
  try await engine.scene.load(from: sceneString)
  // highlight-importTemplates-loadFromString

  // Prepare a local archive for the next section by saving the current scene.
  // In production, archiveURL points to your own ZIP — a remote URL on your CDN
  // or a local file URL — and loadArchive(from:) accepts either.
  let archiveData = try await engine.scene.saveToArchive()
  let archiveURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("imported-template-\(UUID().uuidString).zip")
  try archiveData.write(to: archiveURL)

  // highlight-importTemplates-loadFromArchive
  try await engine.scene.loadArchive(from: archiveURL)
  // highlight-importTemplates-loadFromArchive
}
