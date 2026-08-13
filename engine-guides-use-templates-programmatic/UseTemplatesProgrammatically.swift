import Foundation
import IMGLYEngine

@MainActor
func useTemplatesProgrammatically(engine: Engine) async throws {
  // Resolve sample assets against the engine's configured base URL.
  let baseURL = try engine.guidesBaseURL
  let outputDir = FileManager.default.temporaryDirectory

  // highlight-useTemplatesProgrammatic-createTemplate
  // Build a greeting card template from scratch.
  let scene = try engine.scene.create()
  try engine.scene.setDesignUnit(.px)
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)

  // Light gray page background.
  let pageFill = try engine.block.getFill(page)
  try engine.block.setColor(pageFill, property: "fill/color/value", color: .rgba(r: 0.95, g: 0.95, b: 0.95, a: 1))

  // Define the variables before any text references them.
  try engine.variable.set(key: "recipientName", value: "Template")
  try engine.variable.set(key: "customMessage", value: "This is a template example")

  // Title text block with a variable token.
  let titleBlock = try engine.block.create(.text)
  try engine.block.setName(titleBlock, name: "title")
  try engine.block.appendChild(to: page, child: titleBlock)
  try engine.block.setPositionX(titleBlock, value: 50)
  try engine.block.setPositionY(titleBlock, value: 50)
  try engine.block.setWidth(titleBlock, value: 700)
  try engine.block.setHeight(titleBlock, value: 80)
  try engine.block.replaceText(titleBlock, text: "Hello, {{recipientName}}!")
  try engine.block.setTextColor(titleBlock, color: .rgba(r: 0.2, g: 0.2, b: 0.2, a: 1))
  try engine.block.setFloat(titleBlock, property: "text/fontSize", value: 48)

  // Message text block with a variable token.
  let messageBlock = try engine.block.create(.text)
  try engine.block.setName(messageBlock, name: "message")
  try engine.block.appendChild(to: page, child: messageBlock)
  try engine.block.setPositionX(messageBlock, value: 50)
  try engine.block.setPositionY(messageBlock, value: 140)
  try engine.block.setWidth(messageBlock, value: 700)
  try engine.block.setHeight(messageBlock, value: 120)
  try engine.block.replaceText(messageBlock, text: "{{customMessage}}")
  try engine.block.setTextColor(messageBlock, color: .rgba(r: 0.3, g: 0.3, b: 0.3, a: 1))
  try engine.block.setFloat(messageBlock, property: "text/fontSize", value: 28)
  // highlight-useTemplatesProgrammatic-createTemplate

  // highlight-useTemplatesProgrammatic-manageVariables
  // List every variable the template defines and read a current value.
  let variableNames = engine.variable.findAll()
  print("Template variables:", variableNames)
  let titleUsesVariables = try engine.block.referencesAnyVariables(titleBlock)
  print("Title references variables:", titleUsesVariables)
  let currentName = try engine.variable.get(key: "recipientName")
  print("recipientName =", currentName)
  // highlight-useTemplatesProgrammatic-manageVariables

  // highlight-useTemplatesProgrammatic-saveTemplate
  // Serialize the template to a string and persist it for reuse.
  let templateString = try await engine.scene.saveToString()
  let templateURL = outputDir.appendingPathComponent("template.imgly")
  try templateString.write(to: templateURL, atomically: true, encoding: .utf8)
  // highlight-useTemplatesProgrammatic-saveTemplate

  // highlight-useTemplatesProgrammatic-batchProcessing
  // Populate the template with each record and export a personalized card.
  let recipients = [
    (name: "Alice", message: "Congratulations on your promotion!"),
    (name: "Bob", message: "Happy Birthday! Have a wonderful day!"),
    (name: "Charlie", message: "Thank you for your amazing work!"),
  ]
  for recipient in recipients {
    try engine.variable.set(key: "recipientName", value: recipient.name)
    try engine.variable.set(key: "customMessage", value: recipient.message)

    let cardData = try await engine.block.export(
      page,
      mimeType: .png,
      options: ExportOptions(targetWidth: 800, targetHeight: 600),
    )
    let filename = "greeting-card-\(recipient.name.lowercased()).png"
    try cardData.write(to: outputDir.appendingPathComponent(filename))
  }
  // highlight-useTemplatesProgrammatic-batchProcessing

  // highlight-useTemplatesProgrammatic-dataDriven
  // Reload the saved template before each record so prior edits never carry over.
  let records = [
    (name: "Diana", message: "Welcome to the team!"),
    (name: "Eve", message: "Great work this quarter!"),
  ]
  for record in records {
    try await engine.scene.load(from: templateString)
    guard let recordPage = try engine.block.find(byType: .page).first else { continue }
    try engine.variable.set(key: "recipientName", value: record.name)
    try engine.variable.set(key: "customMessage", value: record.message)

    let recordData = try await engine.block.export(recordPage, mimeType: .png)
    try recordData.write(to: outputDir.appendingPathComponent("record-\(record.name.lowercased()).png"))
  }
  // highlight-useTemplatesProgrammatic-dataDriven

  // highlight-useTemplatesProgrammatic-removeVariable
  // Variable keys are case-sensitive and persist with the scene. Removing a
  // variable leaves its literal token in any text that still references it.
  try engine.variable.remove(key: "customMessage")
  print("Variables after removal:", engine.variable.findAll())
  // highlight-useTemplatesProgrammatic-removeVariable

  // highlight-useTemplatesProgrammatic-loadExisting
  // Load a pre-built template from a URL. This replaces the current scene with
  // the template's pages, blocks, variables, and placeholders.
  let templateAssetURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  try await engine.scene.load(from: templateAssetURL)
  // highlight-useTemplatesProgrammatic-loadExisting
}
