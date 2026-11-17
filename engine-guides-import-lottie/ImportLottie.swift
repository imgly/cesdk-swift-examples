import Foundation
import IMGLYEngine

/// `archiveURL` is the URL of the `.imgly` archive that the Node.js example of this guide saves,
/// for example from `Bundle.main.url(forResource: "badge", withExtension: "imgly")`.
@MainActor
func importLottie(engine: Engine, archiveURL: URL) async throws {
  // highlight-importLottie-loadArchive
  // `overrideEditorConfig: true` also loads the variables that the importer created for the slots.
  try await engine.scene.load(from: archiveURL, overrideEditorConfig: true, waitForResources: true)
  // highlight-importLottie-loadArchive

  // highlight-importLottie-importedBlocks
  // Each import is one group on the page. Its blocks carry the names of the Lottie layers.
  guard let page = try engine.scene.getPages().first,
        let group = try engine.block.getChildren(page).first else { return }
  let layerNames = try engine.block.getChildren(group).map { try engine.block.getName($0) }
  print("Imported layers:", layerNames)

  // The animation of a layer is a set of keyframe tracks on its block.
  if let ring = engine.block.find(byName: "Ring").first {
    print("Animated properties of the ring:", try engine.block.getAnimatedProperties(ring))
  }
  // highlight-importLottie-importedBlocks

  // highlight-importLottie-slots
  // The "brand" slot became a color variable. Setting it recolors every fill that uses the slot.
  try engine.variable.set(key: "brand", color: .rgba(r: 0.13, g: 0.55, b: 0.45, a: 1))
  // highlight-importLottie-slots

  // highlight-importLottie-markers
  // Lottie markers became scene markers, in seconds.
  for marker in try engine.scene.getMarkers() {
    print("Marker \"\(marker.name)\" at \(marker.time)s for \(marker.duration)s")
  }
  // highlight-importLottie-markers

  try await engine.captureGuide(page, label: "hero")
}
