import Foundation
import IMGLYEngine

@MainActor
func importDesignFromArchive(engine: Engine) async throws {
  // Demo scaffolding: load a template so there is a design to archive and import.
  // In your app you would start from a scene already open in the editor.
  let baseURL = try engine.guidesBaseURL
  try engine.editor.setSettingString("basePath", value: baseURL.absoluteString)
  let templateURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: templateURL)

  // highlight-importDesignFromArchive-createArchive
  let archiveBlob = try await engine.scene.saveToArchive()
  let archiveURL = FileManager.default.temporaryDirectory.appendingPathComponent("design.imgly")
  try archiveBlob.write(to: archiveURL)
  // highlight-importDesignFromArchive-createArchive

  // highlight-importDesignFromArchive-loadFromURL
  try await engine.scene.load(from: archiveURL)
  // highlight-importDesignFromArchive-loadFromURL

  // highlight-importDesignFromArchive-loadFromData
  let dataURL = FileManager.default.temporaryDirectory.appendingPathComponent("design-from-data.imgly")
  try archiveBlob.write(to: dataURL)
  try await engine.scene.load(from: dataURL)
  // highlight-importDesignFromArchive-loadFromData

  // highlight-importDesignFromArchive-modify
  let textBlocks = try engine.block.find(byType: .text)
  if let firstTextBlock = textBlocks.first {
    try engine.block.replaceText(firstTextBlock, text: "Loaded from Archive")
  }
  // highlight-importDesignFromArchive-modify
}
