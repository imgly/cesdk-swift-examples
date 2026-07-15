import Foundation
import IMGLYEngine

@MainActor
func importFromInDesign(engine: Engine) async throws {
  // Stand in for the .cesdk archive your server produces from an IDML file with
  // the @imgly/idml-importer package. In production, archiveURL points to that
  // archive — a remote URL on your CDN or a local file URL — and
  // loadArchive(from:) accepts either.
  let baseURL = try engine.guidesBaseURL
  let sceneURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: sceneURL)
  let archiveData = try await engine.scene.saveToArchive()
  let archiveURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("converted-indesign-\(UUID().uuidString).cesdk")
  try archiveData.write(to: archiveURL)

  // highlight-importFromInDesign-loadArchive
  try await engine.scene.loadArchive(from: archiveURL)
  // highlight-importFromInDesign-loadArchive

  // highlight-importFromInDesign-verifyImport
  let pages = try engine.scene.getPages()
  print("Imported design has \(pages.count) page(s)")
  // highlight-importFromInDesign-verifyImport

  // highlight-importFromInDesign-fitViewport
  guard let scene = try engine.scene.get() else { return }
  try await engine.scene.zoom(
    to: scene,
    paddingLeft: 40,
    paddingTop: 40,
    paddingRight: 40,
    paddingBottom: 40,
  )
  // highlight-importFromInDesign-fitViewport
}
