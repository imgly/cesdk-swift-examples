import Foundation
import IMGLYEngine

@MainActor
func retrieveMimetype(engine: Engine) async throws {
  // Demo scaffolding: resolve a sample image URL and load its bytes so the
  // example has something concrete to embed and inspect.
  let baseURL = try engine.guidesBaseURL
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  let imageData = try await URLSession.shared.data(from: imageURL).0

  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-retrieveMimetype-detect
  let mimeType = try await engine.editor.getMIMEType(url: imageURL)
  print("Detected MIME type: \(mimeType)")
  // highlight-retrieveMimetype-detect

  // highlight-retrieveMimetype-embed
  let imageBuffer = engine.editor.createBuffer()
  try engine.editor.setBufferData(url: imageBuffer, offset: 0, data: imageData)

  let graphic = try engine.block.create(.graphic)
  try engine.block.setShape(graphic, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: imageBuffer)
  try engine.block.setFill(graphic, fill: imageFill)
  try engine.block.appendChild(to: page, child: graphic)
  // highlight-retrieveMimetype-embed

  // highlight-retrieveMimetype-findTransient
  let transientResources = try engine.editor.findAllTransientResources()
  print("Found \(transientResources.count) transient resources")
  // highlight-retrieveMimetype-findTransient

  // highlight-retrieveMimetype-getMimetype
  var resourcesByType: [String: Int] = [:]
  for resource in transientResources {
    let type = try await engine.editor.getMIMEType(url: resource.url)
    resourcesByType[type, default: 0] += 1
  }
  print("Resources by type: \(resourcesByType)")
  // highlight-retrieveMimetype-getMimetype

  // highlight-retrieveMimetype-filterImages
  var imageResources: [(url: URL, mimeType: String)] = []
  for resource in transientResources {
    let type = try await engine.editor.getMIMEType(url: resource.url)
    if type.hasPrefix("image/") {
      imageResources.append((url: resource.url, mimeType: type))
    }
  }
  print("Found \(imageResources.count) image resources")
  // highlight-retrieveMimetype-filterImages

  // highlight-retrieveMimetype-bufferData
  let bufferMimeType = try await engine.editor.getMIMEType(url: imageBuffer)
  let length = try engine.editor.getBufferLength(url: imageBuffer)
  let data = try engine.editor.getBufferData(url: imageBuffer, offset: 0, length: UInt(truncating: length))

  let fileExtension = switch bufferMimeType {
  case "image/png": "png"
  case "image/webp": "webp"
  default: "jpg"
  }

  let fileURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension(fileExtension)
  try data.write(to: fileURL, options: .atomic)
  print("Saved \(length) bytes as \(fileURL.lastPathComponent)")
  // highlight-retrieveMimetype-bufferData

  // highlight-retrieveMimetype-relocate
  for resource in transientResources {
    // Demo placeholder — in production, use the URL your storage service returns.
    let hostedURL = URL(string: "https://example.com/assets/\(UUID().uuidString)")!
    try engine.editor.relocateResource(currentURL: resource.url, relocatedURL: hostedURL)
  }
  // highlight-retrieveMimetype-relocate

  // highlight-retrieveMimetype-verify
  let remaining = try engine.editor.findAllTransientResources()
  print("Transient resources remaining: \(remaining.count)")
  // highlight-retrieveMimetype-verify
}
