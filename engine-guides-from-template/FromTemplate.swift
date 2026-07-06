import Foundation
import IMGLYEngine

@MainActor
func fromTemplate(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let templateURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")

  // highlight-fromTemplate-loadFromURL
  try await engine.scene.load(from: templateURL)
  // highlight-fromTemplate-loadFromURL

  // highlight-fromTemplate-loadFromString
  let templateString = try await engine.scene.saveToString()
  try await engine.scene.load(from: templateString)
  // highlight-fromTemplate-loadFromString

  // highlight-fromTemplate-applyTemplate
  try await engine.scene.applyTemplate(from: templateURL)
  // highlight-fromTemplate-applyTemplate

  // highlight-fromTemplate-modifyContent
  if let firstTextBlock = try engine.block.find(byType: .text).first {
    try engine.block.replaceText(firstTextBlock, text: "Your Company")
  }
  // highlight-fromTemplate-modifyContent
}
