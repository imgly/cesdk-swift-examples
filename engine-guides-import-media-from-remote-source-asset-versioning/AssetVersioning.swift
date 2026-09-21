import Foundation
import IMGLYEngine

@MainActor
func assetVersioning(engine: Engine) async throws {
  // Demo scaffolding: build a small scene with a single image block so every
  // snippet below has an asset URL to inspect and update. In your app the scene
  // is already loaded and its blocks already exist.
  let baseURL = try engine.guidesBaseURL
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  // highlight-assetVersioning-storeURI
  // An asset reference lives on a fill block. Create a graphic, give it an image
  // fill, and store the asset URL in the fill's `fill/image/imageFileURI` property.
  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: imageURL)
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.appendChild(to: page, child: imageBlock)

  // Read the URL back — this is exactly the string a saved scene serializes.
  let storedURL = try engine.block.getURL(imageFill, property: "fill/image/imageFileURI")
  print("Stored image URL:", storedURL.absoluteString)
  // highlight-assetVersioning-storeURI

  // Load the image so the archive below can embed its bytes.
  try await engine.block.forceLoadResources([imageBlock])

  // highlight-assetVersioning-saveScene
  // `saveToString` serializes the scene structure and keeps asset references as
  // URLs. The result is small but depends on those URLs staying reachable.
  let sceneString = try await engine.scene.saveToString()
  // highlight-assetVersioning-saveScene
  _ = sceneString

  // highlight-assetVersioning-saveArchive
  // `saveToArchive` bundles the scene together with the bytes of every reachable
  // asset into a self-contained archive you can write to disk with `write(to:)`.
  let archiveData = try await engine.scene.saveToArchive()
  // highlight-assetVersioning-saveArchive
  _ = archiveData

  // highlight-assetVersioning-updateURI
  // Point a fill at a new asset URL — for example, after moving assets to a new
  // CDN or publishing a new version of an image.
  let migratedURL = URL(string: "https://cdn.example.com/assets/v2/product-photo.jpg")!
  try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: migratedURL)

  let updatedURL = try engine.block.getURL(imageFill, property: "fill/image/imageFileURI")
  print("Updated image URL:", updatedURL.absoluteString)
  // highlight-assetVersioning-updateURI

  // highlight-assetVersioning-findBlocks
  // To migrate assets in bulk, walk every graphic block and rewrite the fills
  // that carry an image. Filter by fill type, since a graphic block can hold a
  // color, gradient, image, or video fill.
  let graphicBlocks = try engine.block.find(byType: .graphic)
  for block in graphicBlocks {
    let fill = try engine.block.getFill(block)
    guard try engine.block.getType(fill) == FillType.image.rawValue else { continue }

    let currentURL = try engine.block.getURL(fill, property: "fill/image/imageFileURI")

    // Rewrite only the assets hosted on the CDN you are retiring.
    if currentURL.absoluteString.contains("old-cdn.example.com") {
      let rewritten = currentURL.absoluteString.replacingOccurrences(
        of: "old-cdn.example.com",
        with: "new-cdn.example.com",
      )
      if let newURL = URL(string: rewritten) {
        try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: newURL)
      }
    }
  }
  // highlight-assetVersioning-findBlocks
}
