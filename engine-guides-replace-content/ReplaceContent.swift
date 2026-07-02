import Foundation
import IMGLYEngine

@MainActor
func replaceContent(engine: Engine) async throws {
  // Resolve sample assets against the engine's configured base URL.
  let baseURL = try engine.guidesBaseURL

  // Demo setup: build a minimal template inline so the replacement APIs below
  // have named placeholders and variables to operate on. In production, load a
  // template scene authored on the web with `engine.scene.load(from:)`.
  let scene = try engine.scene.create()
  try engine.scene.setDesignUnit(.px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 400)
  try engine.block.appendChild(to: scene, child: page)

  // An image placeholder with a semantic name.
  let productImage = try engine.block.create(.graphic)
  try engine.block.setShape(productImage, shape: engine.block.createShape(.rect))
  let productFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    productFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(productImage, fill: productFill)
  try engine.block.setWidth(productImage, value: 300)
  try engine.block.setHeight(productImage, value: 300)
  try engine.block.setPositionX(productImage, value: 50)
  try engine.block.setPositionY(productImage, value: 50)
  try engine.block.setName(productImage, name: "product-image")
  try engine.block.setPlaceholderEnabled(productImage, enabled: true)
  try engine.block.appendChild(to: page, child: productImage)

  // A text block driven by a variable token.
  let headline = try engine.block.create(.text)
  try engine.block.replaceText(headline, text: "{{headline}}")
  try engine.block.setWidthMode(headline, mode: .auto)
  try engine.block.setHeightMode(headline, mode: .auto)
  try engine.block.setFloat(headline, property: "text/fontSize", value: 48)
  try engine.block.setPositionX(headline, value: 400)
  try engine.block.setPositionY(headline, value: 120)
  try engine.block.setName(headline, name: "headline")
  try engine.block.appendChild(to: page, child: headline)

  // A plain text block updated through direct replacement.
  let subtitle = try engine.block.create(.text)
  try engine.block.replaceText(subtitle, text: "Original subtitle")
  try engine.block.setWidthMode(subtitle, mode: .auto)
  try engine.block.setHeightMode(subtitle, mode: .auto)
  try engine.block.setFloat(subtitle, property: "text/fontSize", value: 24)
  try engine.block.setPositionX(subtitle, value: 400)
  try engine.block.setPositionY(subtitle, value: 220)
  try engine.block.setName(subtitle, name: "subtitle")
  try engine.block.appendChild(to: page, child: subtitle)

  // highlight-replaceContent-findByName
  // Find a specific block when you know its name. Names are case-sensitive.
  let headlineBlock = engine.block.find(byName: "headline").first
  if let headlineBlock {
    print("Found block named:", try engine.block.getName(headlineBlock))
  }
  // highlight-replaceContent-findByName

  // highlight-replaceContent-findAllPlaceholders
  // Discover every placeholder block so you can iterate over them.
  let placeholders = engine.block.findAllPlaceholders()
  print("Template placeholders:", placeholders.count)
  // highlight-replaceContent-findAllPlaceholders

  // highlight-replaceContent-queryState
  if let imageBlock = engine.block.find(byName: "product-image").first {
    let fill = try engine.block.getFill(imageBlock)
    if try engine.block.supportsPlaceholderBehavior(fill) {
      let enabled = try engine.block.isPlaceholderEnabled(imageBlock)
      print("product-image placeholder enabled:", enabled)
    }
  }
  // highlight-replaceContent-queryState

  // highlight-replaceContent-textVariables
  // The headline block contains "{{headline}}" and updates when the variable is set.
  try engine.variable.set(key: "headline", value: "Summer Sale")
  // highlight-replaceContent-textVariables

  // highlight-replaceContent-manageVariables
  // List every variable the template references and read a current value.
  let variableNames = engine.variable.findAll()
  let headlineValue = try engine.variable.get(key: "headline")
  print("Variables:", variableNames, "headline =", headlineValue)

  // Remove a variable you no longer need.
  try engine.variable.set(key: "legacyTag", value: "obsolete")
  try engine.variable.remove(key: "legacyTag")
  // highlight-replaceContent-manageVariables

  // highlight-replaceContent-replaceImage
  // Swap an image placeholder's source by updating its fill's image URI.
  if let imageBlock = engine.block.find(byName: "product-image").first {
    let fill = try engine.block.getFill(imageBlock)
    try engine.block.setURL(
      fill,
      property: "fill/image/imageFileURI",
      value: baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg"),
    )
  }
  // highlight-replaceContent-replaceImage

  // highlight-replaceContent-directText
  // Replace the full text of a block without using the variable system.
  if let subtitleBlock = engine.block.find(byName: "subtitle").first {
    try engine.block.replaceText(subtitleBlock, text: "Up to 50% off this week")
  }
  // highlight-replaceContent-directText

  // highlight-replaceContent-dataDriven
  // Populate the template once per record, then export each result.
  let records: [[String: String]] = [
    ["headline": "Summer Sale", "subtitle": "Up to 50% off", "image": "ly.img.image/images/sample_1.jpg"],
    ["headline": "Winter Sale", "subtitle": "Cozy deals inside", "image": "ly.img.image/images/sample_2.jpg"],
  ]

  for record in records {
    if let headline = record["headline"] {
      try engine.variable.set(key: "headline", value: headline)
    }
    if let subtitle = record["subtitle"], let subtitleBlock = engine.block.find(byName: "subtitle").first {
      try engine.block.replaceText(subtitleBlock, text: subtitle)
    }
    if let imagePath = record["image"], let imageBlock = engine.block.find(byName: "product-image").first {
      let fill = try engine.block.getFill(imageBlock)
      try engine.block.setURL(
        fill,
        property: "fill/image/imageFileURI",
        value: baseURL.appendingPathComponent(imagePath),
      )
    }
    let blob = try await engine.block.export(page, mimeType: .png)
    print("Exported \(record["headline"] ?? "record"):", blob.count, "bytes")
  }
  // highlight-replaceContent-dataDriven
}
