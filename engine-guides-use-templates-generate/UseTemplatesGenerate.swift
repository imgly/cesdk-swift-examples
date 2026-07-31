import Foundation
import IMGLYEngine

@MainActor
func useTemplatesGenerate(engine: Engine) async throws {
  // Resolve sample assets against the engine's configured base URL.
  let baseURL = try engine.guidesBaseURL

  // Demo setup: build a small greeting-card template inline and serialize it so
  // the load call below has real template data to work with. In production your
  // templates come from the web editor or your storage — you load them the same
  // way, straight into `engine.scene.load(from:)`.
  let demoScene = try engine.scene.create(designUnit: .px)
  let demoPage = try engine.block.create(.page)
  try engine.block.setWidth(demoPage, value: 800)
  try engine.block.setHeight(demoPage, value: 600)
  try engine.block.appendChild(to: demoScene, child: demoPage)

  // An image placeholder with a semantic name the generation code looks up.
  let demoImage = try engine.block.create(.graphic)
  try engine.block.setShape(demoImage, shape: engine.block.createShape(.rect))
  let demoFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    demoFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(demoImage, fill: demoFill)
  try engine.block.setWidth(demoImage, value: 320)
  try engine.block.setHeight(demoImage, value: 320)
  try engine.block.setPositionX(demoImage, value: 60)
  try engine.block.setPositionY(demoImage, value: 140)
  try engine.block.setName(demoImage, name: "Image")
  try engine.block.setPlaceholderEnabled(demoImage, enabled: true)
  try engine.block.appendChild(to: demoPage, child: demoImage)

  // Two text blocks driven by variable tokens.
  let demoGreeting = try engine.block.create(.text)
  try engine.block.replaceText(demoGreeting, text: "Dear {{recipientName}},")
  try engine.block.setWidthMode(demoGreeting, mode: .auto)
  try engine.block.setHeightMode(demoGreeting, mode: .auto)
  try engine.block.setFloat(demoGreeting, property: "text/fontSize", value: 44)
  try engine.block.setPositionX(demoGreeting, value: 440)
  try engine.block.setPositionY(demoGreeting, value: 170)
  try engine.block.appendChild(to: demoPage, child: demoGreeting)

  let demoMessage = try engine.block.create(.text)
  try engine.block.replaceText(demoMessage, text: "{{message}}")
  try engine.block.setWidthMode(demoMessage, mode: .absolute)
  try engine.block.setWidth(demoMessage, value: 300)
  try engine.block.setHeightMode(demoMessage, mode: .auto)
  try engine.block.setFloat(demoMessage, property: "text/fontSize", value: 28)
  try engine.block.setPositionX(demoMessage, value: 440)
  try engine.block.setPositionY(demoMessage, value: 260)
  try engine.block.appendChild(to: demoPage, child: demoMessage)

  // Register the template's variables with default values. `findAll()` reports
  // registered variables, so a template must register a variable for each token
  // it defines — the CE.SDK editor does this automatically when you insert a
  // `{{token}}`. Registering them here serializes them with the scene.
  try engine.variable.set(key: "recipientName", value: "Friend")
  try engine.variable.set(key: "message", value: "Best wishes")

  let templateString = try await engine.scene.saveToString()

  // highlight-generate-load
  // Load a template as the active scene. Pass `overrideEditorConfig: true` to
  // import the template's registered variables (and settings) into the engine.
  // Use a serialized string for stored data, a URL for a remote or bundled
  // `.scene` file with `engine.scene.load(from: URL)`, or
  // `engine.scene.load(from:)` for an archive that bundles its assets.
  try await engine.scene.load(from: templateString, overrideEditorConfig: true)
  // highlight-generate-load

  // highlight-generate-discoverVariables
  // List the variables the template registers, and read a variable's value.
  let variableNames = engine.variable.findAll()
  let defaultRecipient = try engine.variable.get(key: "recipientName")
  print("Template variables:", variableNames, "— recipientName default:", defaultRecipient)
  // highlight-generate-discoverVariables

  // highlight-generate-populateVariables
  // Assign values that replace the matching {{token}} placeholders in text.
  try engine.variable.set(key: "recipientName", value: "Alice")
  try engine.variable.set(key: "message", value: "Wishing you a wonderful year ahead!")
  // highlight-generate-populateVariables

  // highlight-generate-findPlaceholders
  // Discover every placeholder block, or look one up by its name.
  let placeholders = engine.block.findAllPlaceholders()
  print("Template placeholders:", placeholders.count)

  if let namedImage = engine.block.find(byName: "Image").first {
    print("Found image placeholder:", try engine.block.getName(namedImage))
  }
  // highlight-generate-findPlaceholders

  // highlight-generate-updateImage
  // Swap an image placeholder's source by updating its fill's image URI.
  if let imageBlock = engine.block.find(byName: "Image").first {
    let fill = try engine.block.getFill(imageBlock)
    try engine.block.setURL(
      fill,
      property: "fill/image/imageFileURI",
      value: baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg"),
    )
  }
  // highlight-generate-updateImage

  if let heroPage = try engine.block.find(byType: .page).first {
    try await engine.captureGuide(heroPage, label: "hero")
  }

  // highlight-generate-exportImage
  // Export the populated page to a PNG image at a target resolution.
  guard let page = try engine.block.find(byType: .page).first else { return }
  let pngData = try await engine.block.export(
    page,
    mimeType: .png,
    options: ExportOptions(targetWidth: 1920, targetHeight: 1080),
  )
  print("Exported PNG:", pngData.count, "bytes")
  // highlight-generate-exportImage

  // highlight-generate-exportPDF
  // Export the whole scene to a multi-page PDF document.
  if let scene = try engine.scene.get() {
    let pdfData = try await engine.block.export(scene, mimeType: .pdf)
    print("Exported PDF:", pdfData.count, "bytes")
  }
  // highlight-generate-exportPDF

  // highlight-generate-batch
  // Personalize the same template once per record and export each result.
  let records: [[String: String]] = [
    ["recipientName": "Alice", "message": "Wishing you a wonderful year ahead!"],
    ["recipientName": "Bob", "message": "Congratulations on the new home!"],
    ["recipientName": "Carol", "message": "Thank you for everything."],
  ]

  for record in records {
    // A reload with `overrideEditorConfig: true` re-imports the template's
    // own variables, resetting them to their serialized defaults each record.
    try await engine.scene.load(from: templateString, overrideEditorConfig: true)
    for (key, value) in record {
      try engine.variable.set(key: key, value: value)
    }
    guard let recordPage = try engine.block.find(byType: .page).first else { continue }
    let recordData = try await engine.block.export(recordPage, mimeType: .png)
    print("Exported \(record["recipientName"] ?? "record"):", recordData.count, "bytes")
  }
  // highlight-generate-batch
}
