import Foundation
import IMGLYEngine

@MainActor
func templating(engine: Engine) async throws {
  // highlight-templating-loadTemplate
  let templateURL = URL(
    string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene",
  )!
  try await engine.scene.load(from: templateURL)
  // highlight-templating-loadTemplate

  // highlight-templating-discoverVariables
  let variableNames = engine.variable.findAll()
  print("Template variables:", variableNames)
  // highlight-templating-discoverVariables

  // highlight-templating-setVariables
  try engine.variable.set(key: "Name", value: "Jane")
  try engine.variable.set(key: "Greeting", value: "Wish you were here!")
  // highlight-templating-setVariables

  // highlight-templating-discoverPlaceholders
  let placeholders = engine.block.findAllPlaceholders()
  print("Template placeholders:", placeholders.count)
  // highlight-templating-discoverPlaceholders
}
