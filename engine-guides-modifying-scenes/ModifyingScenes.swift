import Foundation
import IMGLYEngine

@MainActor
func modifyingScenes(engine: Engine) async throws {
  // highlight-scene-get-create
  let scene = try engine.scene.get()
  /* In engine only mode we have to create our own scene and page. */

  if scene == nil {
    let scene = try engine.scene.create()
    // highlight-scene-get-create
    // highlight-page-get-create
    let page = try engine.block.create(.page)
    try engine.block.appendChild(to: scene, child: page)
  }

  /* Find all pages in our scene. */
  let pages = try engine.block.find(byType: .page)
  /* Use the first page we found. */
  let page = pages.first!
  // highlight-page-get-create

  // highlight-create-image
  /* Create a graphic block and add it to the scene's page. */
  let block = try engine.block.create(.graphic)
  let fill = try engine.block.createFill(.image)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setFill(block, fill: fill)
  // highlight-create-image

  // highlight-image-properties
  try engine.block.setString(
    fill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/imgly_logo.jpg",
  )

  /* The content fill mode 'Contain' ensures the entire image is visible. */
  try engine.block.setEnum(block, property: "contentFill/mode", value: "Contain")
  // highlight-image-properties

  // highlight-image-append
  try engine.block.appendChild(to: page, child: block)
  // highlight-image-append

  // highlight-zoom-page
  /* Zoom the scene's camera on our page. */
  try await engine.scene.zoom(to: page)
  // highlight-zoom-page
}
