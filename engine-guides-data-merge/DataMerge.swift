import Foundation
import IMGLYEngine

@MainActor
func dataMerge(engine: Engine) async throws {
  // highlight-sample-data
  // Sample record whose fields map to the template's variables and placeholders
  let record: [String: String] = [
    "name": "Alex Smith",
    "title": "Creative Developer",
    "email": "alex.smith@example.com",
  ]
  let photoURL = "https://img.ly/static/ubq_samples/sample_1.jpg"
  // highlight-sample-data

  // highlight-setup-template
  // Demo setup: build a minimal template inline. In production, load a
  // template scene authored on the web with `engine.scene.load(from:)`.
  let scene = try engine.scene.create()
  try engine.scene.setDesignUnit(.px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 400)
  try engine.block.appendChild(to: scene, child: page)

  // A photo placeholder with a semantic name
  let photoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(photoBlock, shape: engine.block.createShape(.rect))
  let photoFill = try engine.block.createFill(.image)
  try engine.block.setString(photoFill, property: "fill/image/imageFileURI", value: photoURL)
  try engine.block.setFill(photoBlock, fill: photoFill)
  try engine.block.setWidth(photoBlock, value: 150)
  try engine.block.setHeight(photoBlock, value: 150)
  try engine.block.setPositionX(photoBlock, value: 50)
  try engine.block.setPositionY(photoBlock, value: 125)
  try engine.block.setName(photoBlock, name: "profile-photo")
  try engine.block.appendChild(to: page, child: photoBlock)

  // A text block referencing variable tokens
  let textBlock = try engine.block.create(.text)
  try engine.block.replaceText(textBlock, text: "{{name}}\n{{title}}\n{{email}}")
  try engine.block.setWidthMode(textBlock, mode: .auto)
  try engine.block.setHeightMode(textBlock, mode: .auto)
  try engine.block.setFloat(textBlock, property: "text/fontSize", value: 32)
  try engine.block.setPositionX(textBlock, value: 230)
  try engine.block.setPositionY(textBlock, value: 140)
  try engine.block.appendChild(to: page, child: textBlock)
  // highlight-setup-template

  // highlight-discover-variables
  // Discover which variables the loaded template expects
  let variableNames = engine.variable.findAll()
  print("Template variables:", variableNames)

  // Confirm the text block actually references variables
  let hasVariables = try engine.block.referencesAnyVariables(textBlock)
  print("Text block references variables:", hasVariables)
  // highlight-discover-variables

  // highlight-set-variables
  // Populate each variable with a value from the record
  for (key, value) in record {
    try engine.variable.set(key: key, value: value)
  }
  // highlight-set-variables

  // highlight-update-placeholder
  // Find a placeholder block by its semantic name and swap its image content
  if let foundPhotoBlock = engine.block.find(byName: "profile-photo").first {
    let fill = try engine.block.getFill(foundPhotoBlock)
    try engine.block.setString(
      fill,
      property: "fill/image/imageFileURI",
      value: "https://img.ly/static/ubq_samples/sample_2.jpg",
    )
  }
  // highlight-update-placeholder

  // highlight-export
  // Export the personalized design as PNG data
  let blob = try await engine.block.export(page, mimeType: .png)
  print("Exported PNG data:", blob.count, "bytes")
  // highlight-export
}
