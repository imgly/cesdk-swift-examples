import Foundation
import IMGLYEngine

@MainActor
func productVariations(engine: Engine) async throws {
  // highlight-productVariations-dataModel
  struct ProductVariant {
    let color: String
    let size: String
    let price: String
    let imageURL: URL
  }

  let variants: [ProductVariant] = [
    ProductVariant(
      color: "Midnight Black",
      size: "M",
      price: "$29.99",
      imageURL: URL(string: "https://img.ly/static/ubq_samples/imgly_logo.jpg")!,
    ),
    ProductVariant(
      color: "Ocean Blue",
      size: "L",
      price: "$34.99",
      imageURL: URL(string: "https://img.ly/static/ubq_samples/imgly_logo.jpg")!,
    ),
  ]
  // highlight-productVariations-dataModel

  // highlight-productVariations-createTemplate
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 500)
  try engine.block.setHeight(page, value: 500)

  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: text)
  try engine.block.setWidth(text, value: 400)
  try engine.block.setHeight(text, value: 50)
  try engine.block.setPositionX(text, value: 50)
  try engine.block.setPositionY(text, value: 50)
  try engine.block.replaceText(text, text: "{{ProductName}} – {{ProductColor}}")

  let priceText = try engine.block.create(.text)
  try engine.block.appendChild(to: page, child: priceText)
  try engine.block.setWidth(priceText, value: 200)
  try engine.block.setHeight(priceText, value: 40)
  try engine.block.setPositionX(priceText, value: 50)
  try engine.block.setPositionY(priceText, value: 120)
  try engine.block.replaceText(priceText, text: "{{ProductPrice}}")

  let imageBlock = try engine.block.create(.graphic)
  try engine.block.appendChild(to: page, child: imageBlock)
  try engine.block.setWidth(imageBlock, value: 300)
  try engine.block.setHeight(imageBlock, value: 300)
  try engine.block.setPositionX(imageBlock, value: 100)
  try engine.block.setPositionY(imageBlock, value: 180)
  try engine.block.setName(imageBlock, name: "ProductImage")
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/imgly_logo.jpg",
  )

  // Save template as a string for further export
  let templateString = try await engine.scene.saveToString()
  // highlight-productVariations-createTemplate

  // highlight-productVariations-discoverVariables
  let variableKeys = engine.variable.findAll()
  print("Template variables: \(variableKeys)")
  // Expected: ["ProductName", "ProductColor", "ProductPrice"]
  // highlight-productVariations-discoverVariables

  // highlight-productVariations-generateLoop
  for variant in variants {
    // Reload the template for each variant
    try await engine.scene.load(from: templateString)

    // highlight-productVariations-setVariables
    // Set text variables for this variant
    try engine.variable.set(key: "ProductName", value: "Classic Tee")
    try engine.variable.set(key: "ProductColor", value: variant.color)
    try engine.variable.set(key: "ProductPrice", value: variant.price)
    // highlight-productVariations-setVariables

    // highlight-productVariations-replaceImage
    // Replace the product image by finding the block by name
    if let block = engine.block.find(byName: "ProductImage").first {
      let fill = try engine.block.getFill(block)
      try engine.block.setString(
        fill,
        property: "fill/image/imageFileURI",
        value: variant.imageURL.absoluteString,
      )
    }
    // highlight-productVariations-replaceImage

    // highlight-productVariations-export
    // Export the current variation
    guard let exportPage = try engine.block.find(byType: .page).first else { continue }
    let blob = try await engine.block.export(exportPage, mimeType: .jpeg)

    // Save to a file
    let dir = FileManager.default.temporaryDirectory
    let fileName = "product-\(variant.color.lowercased().replacingOccurrences(of: " ", with: "-"))-\(variant.size).jpg"
    let fileURL = dir.appendingPathComponent(fileName)
    try blob.write(to: fileURL)
    // highlight-productVariations-export
  }
  // highlight-productVariations-generateLoop
}
