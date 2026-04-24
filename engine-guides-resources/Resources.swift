import Foundation
import IMGLYEngine

@MainActor
func resources(engine: Engine) async throws {
  // highlight-resources-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-resources-setup

  // highlight-resources-onDemandLoading
  // Create a graphic block with an image fill.
  // The image loads on-demand when the engine renders the block.
  let imageBlock = try engine.block.create(.graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(imageBlock, shape: rectShape)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(
    imageFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_4.jpg",
  )
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.setEnum(imageBlock, property: "contentFill/mode", value: "Cover")
  try engine.block.appendChild(to: page, child: imageBlock)
  // highlight-resources-onDemandLoading

  // highlight-resources-preloadResources
  // Preload all resources in the scene before rendering.
  try await engine.block.forceLoadResources([scene])

  // Preload specific blocks only.
  let graphics = try engine.block.find(byType: .graphic)
  try await engine.block.forceLoadResources(graphics)
  // highlight-resources-preloadResources

  // highlight-resources-preloadAV
  // Create a video fill and preload its resource to query properties.
  let videoBlock = try engine.block.create(.graphic)
  let videoShape = try engine.block.createShape(.rect)
  try engine.block.setShape(videoBlock, shape: videoShape)

  let videoFill = try engine.block.createFill(.video)
  try engine.block.setString(
    videoFill,
    property: "fill/video/fileURI",
    value: "https://img.ly/static/ubq_video_samples/bbb.mp4",
  )
  try engine.block.setFill(videoBlock, fill: videoFill)
  try engine.block.setEnum(videoBlock, property: "contentFill/mode", value: "Cover")
  try engine.block.appendChild(to: page, child: videoBlock)

  try await engine.block.forceLoadAVResource(videoFill)

  let duration = try engine.block.getAVResourceTotalDuration(videoFill)
  let videoWidth = try engine.block.getVideoWidth(videoFill)
  let videoHeight = try engine.block.getVideoHeight(videoFill)
  print("Video: \(duration)s, \(videoWidth)x\(videoHeight)")
  // highlight-resources-preloadAV

  // highlight-resources-findTransient
  // Find transient resources that won't survive serialization.
  let transientResources = try engine.editor.findAllTransientResources()
  for resource in transientResources {
    print("Transient: \(resource.url), \(resource.size) bytes")
  }
  // highlight-resources-findTransient

  // highlight-resources-findMediaURIs
  // Get all media URIs referenced in the scene.
  let mediaURIs = try engine.editor.findAllMediaURIs()
  for uri in mediaURIs {
    print("Media URI: \(uri)")
  }
  // highlight-resources-findMediaURIs

  // highlight-resources-detectMIMEType
  // Detect the MIME type of a resource.
  let imageURL = URL(string: "https://img.ly/static/ubq_samples/sample_4.jpg")!
  let mimeType = try await engine.editor.getMIMEType(url: imageURL)
  print("MIME type: \(mimeType)")
  // highlight-resources-detectMIMEType

  // highlight-resources-relocate
  // Update a resource's URL mapping after moving it to a new location.
  let currentURL = URL(string: "https://example.com/old-location/image.jpg")!
  let relocatedURL = URL(string: "https://cdn.example.com/new-location/image.jpg")!
  try engine.editor.relocateResource(currentURL: currentURL, relocatedURL: relocatedURL)
  // highlight-resources-relocate

  // highlight-resources-persistTransient
  // Save the scene with a persistence callback for transient resources.
  let sceneString = try await engine.scene.saveToString(
    allowedResourceSchemes: ["http", "https"],
    onDisallowedResourceScheme: { url, _ in
      // Upload the resource to permanent storage and return the new URL.
      // let permanentURL = try await uploadToCDN(url)
      // return permanentURL
      url
    },
  )
  print("Saved scene (\(sceneString.count) characters)")
  // highlight-resources-persistTransient
}
