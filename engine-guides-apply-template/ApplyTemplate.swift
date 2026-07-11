import Foundation
import IMGLYEngine

@MainActor
func applyTemplate(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // highlight-applyTemplate-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1080)
  try engine.block.setHeight(page, value: 1920)
  // highlight-applyTemplate-setup

  // highlight-applyTemplate-fromURL
  let templateURL = baseURL
    .appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.applyTemplate(from: templateURL)
  // highlight-applyTemplate-fromURL

  // highlight-applyTemplate-verifyDimensions
  guard let appliedPage = try engine.scene.getPages().first else { return }
  let width = try engine.block.getWidth(appliedPage)
  let height = try engine.block.getHeight(appliedPage)
  print("Page dimensions preserved: \(width) x \(height)")
  // highlight-applyTemplate-verifyDimensions

  // highlight-applyTemplate-switching
  let alternativeTemplateURL = baseURL
    .appendingPathComponent("ly.img.templates/templates/cesdk_blank_1.scene")
  try await engine.scene.applyTemplate(from: alternativeTemplateURL)
  // highlight-applyTemplate-switching

  // highlight-applyTemplate-fromString
  // A serialized scene string, here read from the template file. In production
  // it typically comes from your database or an API response.
  let templateData = try await URLSession.shared.data(from: templateURL).0
  guard let templateString = String(bytes: templateData, encoding: .utf8) else { return }
  try await engine.scene.applyTemplate(from: templateString)
  // highlight-applyTemplate-fromString
}
