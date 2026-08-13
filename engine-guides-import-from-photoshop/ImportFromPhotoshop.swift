import Foundation
import IMGLYEngine

@MainActor
func importFromPhotoshop(engine: Engine) async throws {
  // Stand in for the .imgly archive your server produces from a PSD file with
  // the @imgly/psd-importer package. In production, archiveURL points to that
  // archive — a remote URL on your CDN or a local file URL — and
  // load(from:) accepts either.
  let baseURL = try engine.guidesBaseURL
  let sceneURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: sceneURL)
  let archiveData = try await engine.scene.saveToArchive()
  let archiveURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("converted-photoshop-\(UUID().uuidString).imgly")
  try archiveData.write(to: archiveURL)

  // highlight-importFromPhotoshop-loadArchive
  try await engine.scene.load(from: archiveURL)
  // highlight-importFromPhotoshop-loadArchive

  // highlight-importFromPhotoshop-verifyImport
  let pages = try engine.scene.getPages()
  print("Imported design has \(pages.count) page(s)")
  // highlight-importFromPhotoshop-verifyImport

  // highlight-importFromPhotoshop-fitViewport
  guard let scene = try engine.scene.get() else { return }
  try await engine.scene.zoom(
    to: scene,
    paddingLeft: 40,
    paddingTop: 40,
    paddingRight: 40,
    paddingBottom: 40,
  )
  // highlight-importFromPhotoshop-fitViewport
}
