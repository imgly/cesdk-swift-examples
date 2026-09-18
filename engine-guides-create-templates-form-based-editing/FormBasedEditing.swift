import Foundation
import IMGLYEngine

@MainActor
func formBasedEditing(engine: Engine) async throws {
  // Resolve sample images against the engine's configured base URL.
  let baseURL = try engine.guidesBaseURL

  // Demo scaffolding: build a small template inline so this example runs
  // standalone. In production, replace everything up to the "Discover" section
  // with a single `engine.scene.load(from: templateURL)` call that loads a
  // template your team authored on the web — its variable tokens, defined
  // variables, and placeholder blocks are already in place.
  // Create the scene with a pixel design unit. Passing the design unit to
  // `create` also pairs the font-size unit to pixels, so the `text/fontSize`
  // values below are interpreted as pixels — the default font-size unit is
  // points, which the scene's DPI would otherwise scale up.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 600)
  try engine.block.setHeight(page, value: 800)
  try engine.block.appendChild(to: scene, child: page)

  // A heading that references the `tag` variable. It renders with the engine's
  // default font and a black fill; the example sets a larger font size than the
  // subtitle for visual hierarchy.
  let title = try engine.block.create(.text)
  try engine.block.replaceText(title, text: "{{tag}}!")
  try engine.block.setFloat(title, property: "text/fontSize", value: 56)
  try engine.block.setWidth(title, value: 500)
  try engine.block.setPositionX(title, value: 50)
  try engine.block.setPositionY(title, value: 50)
  try engine.block.appendChild(to: page, child: title)

  let subtitle = try engine.block.create(.text)
  // highlight-formBasedEditing-useVariableInText
  // Reference a variable in text by wrapping its name in double curly braces.
  // The engine substitutes `{{tagline}}` with the variable's value at render time.
  try engine.block.replaceText(subtitle, text: "{{tagline}}")

  // `referencesAnyVariables(_:)` confirms a block depends on variable tokens.
  let subtitleUsesVariables = try engine.block.referencesAnyVariables(subtitle)
  print("Subtitle references variables:", subtitleUsesVariables)
  // highlight-formBasedEditing-useVariableInText
  // A smaller font size than the heading gives the form a clear hierarchy.
  try engine.block.setFloat(subtitle, property: "text/fontSize", value: 32)
  try engine.block.setWidth(subtitle, value: 500)
  try engine.block.setPositionX(subtitle, value: 50)
  try engine.block.setPositionY(subtitle, value: 140)
  try engine.block.appendChild(to: page, child: subtitle)

  // An image block marked as a placeholder so users can swap its content.
  let image = try engine.block.create(.graphic)
  try engine.block.setShape(image, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(image, fill: imageFill)
  try engine.block.setWidth(image, value: 500)
  try engine.block.setHeight(image, value: 400)
  try engine.block.setPositionX(image, value: 50)
  try engine.block.setPositionY(image, value: 250)
  try engine.block.setPlaceholderEnabled(image, enabled: true)
  try engine.block.appendChild(to: page, child: image)

  // highlight-formBasedEditing-defineVariables
  // Give each variable an initial value. A web-authored template ships with
  // these defaults already set; here we define them so the form has something
  // to show on first load.
  try engine.variable.set(key: "tag", value: "Welcome")
  try engine.variable.set(key: "tagline", value: "Your personalized design")
  // highlight-formBasedEditing-defineVariables

  // highlight-formBasedEditing-discover
  // List every variable the template defines — render one form field per entry.
  let variableNames = engine.variable.findAll()

  // Find image placeholders: graphic blocks flagged as placeholders.
  let graphicBlocks = try engine.block.find(byType: .graphic)
  let placeholders = try graphicBlocks.filter { try engine.block.isPlaceholderEnabled($0) }
  print("Variables:", variableNames, "Placeholders:", placeholders.count)
  // highlight-formBasedEditing-discover

  // highlight-formBasedEditing-updateVariables
  // Read a variable to seed a form field, then write the user's edit back.
  // In SwiftUI, call the setter from a TextField's `onChange(of:)` handler.
  let currentTag = try engine.variable.get(key: "tag")
  print("Seeding field with:", currentTag)
  try engine.variable.set(key: "tag", value: "Hello")
  // highlight-formBasedEditing-updateVariables

  // highlight-formBasedEditing-getFill
  // Read a placeholder's current image so the form can preview it.
  guard let placeholder = placeholders.first else { return }
  let fill = try engine.block.getFill(placeholder)
  let currentImageURL = try engine.block.getURL(fill, property: "fill/image/imageFileURI")
  print("Current placeholder image:", currentImageURL.lastPathComponent)
  // highlight-formBasedEditing-getFill

  // highlight-formBasedEditing-setFill
  // Swap the placeholder's content when the user picks a new image. Point the
  // fill at any local file URL — a photo from the picker, a bundled asset, or
  // a downloaded file.
  try engine.block.setURL(
    fill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg"),
  )
  // highlight-formBasedEditing-setFill

  // highlight-formBasedEditing-driveUpdates
  // Apply an entire form's current values in one pass — for example when the
  // user taps "Apply". Keep your form state in a dictionary keyed by variable
  // name and write each entry back through the engine.
  let formValues: [String: String] = [
    "tag": "Welcome Back",
    "tagline": "Built from form input",
  ]
  for (key, value) in formValues where variableNames.contains(key) {
    try engine.variable.set(key: key, value: value)
  }
  // highlight-formBasedEditing-driveUpdates

  // highlight-formBasedEditing-validate
  // Before exporting, confirm every variable the form exposes has a value.
  let missingFields = try variableNames.filter { try engine.variable.get(key: $0).isEmpty }
  guard missingFields.isEmpty else {
    print("Cannot export — required fields are empty:", missingFields)
    return
  }

  let exported = try await engine.block.export(page, mimeType: .png)
  print("Exported personalized template:", exported.count, "bytes")
  // highlight-formBasedEditing-validate

  try await engine.captureGuide(page, label: "hero", mimeType: .png)
}
