import Foundation
import IMGLYEngine

// highlight-createCustomImporter-model
/// The intermediate model the importer decodes the source format into. In a real
/// importer this mirrors the structure of your own file format.
struct CustomImporterDesign: Decodable {
  let width: Float
  let height: Float
  let background: [Float]? // page background rgba in 0...1
  let elements: [CustomImporterElement]
}

struct CustomImporterElement: Decodable {
  enum Kind: String, Decodable {
    case image
    case text
    case rectangle
  }

  let type: Kind
  let x: Float
  let y: Float
  let width: Float
  let height: Float
  let src: String? // image reference, for `.image`
  let text: String? // text content, for `.text`
  let color: [Float]? // rgba components in 0...1, for `.rectangle`
}

// highlight-createCustomImporter-model

@MainActor
func createCustomImporter(engine: Engine) async throws {
  // Resolve image references against the base URL where the importer's assets
  // live. Kept out of the highlighted snippets so the example runs offline.
  let baseURL = try engine.guidesBaseURL

  // highlight-createCustomImporter-parse
  // The source bytes — here an inline string standing in for a file read from
  // disk, an upload, or your API.
  let sourceJSON = """
  {
    "width": 800,
    "height": 600,
    "background": [1.0, 1.0, 1.0, 1.0],
    "elements": [
      { "type": "rectangle", "x": 0, "y": 0, "width": 800, "height": 140, "color": [0.16, 0.20, 0.45, 1.0] },
      { "type": "image", "x": 80, "y": 200, "width": 320, "height": 320, "src": "ly.img.image/images/sample_4.jpg" },
      { "type": "text", "x": 440, "y": 250, "width": 300, "height": 120, "text": "Imported heading" }
    ]
  }
  """

  let design = try JSONDecoder().decode(CustomImporterDesign.self, from: Data(sourceJSON.utf8))
  // highlight-createCustomImporter-parse

  // highlight-createCustomImporter-scene
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: design.width)
  try engine.block.setHeight(page, value: design.height)
  if let background = design.background, background.count == 4 {
    let pageFill = try engine.block.createFill(.color)
    try engine.block.setColor(
      pageFill,
      property: "fill/color/value",
      color: .rgba(r: background[0], g: background[1], b: background[2], a: background[3]),
    )
    try engine.block.setFill(page, fill: pageFill)
  }
  try engine.block.appendChild(to: scene, child: page)
  // highlight-createCustomImporter-scene

  // highlight-createCustomImporter-mapElements
  for element in design.elements {
    let block: DesignBlockID
    switch element.type {
    case .image:
      block = try engine.block.create(.graphic)
      try engine.block.setShape(block, shape: engine.block.createShape(.rect))
      let fill = try engine.block.createFill(.image)
      if let src = element.src {
        try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: baseURL.appendingPathComponent(src))
      }
      try engine.block.setFill(block, fill: fill)
    case .rectangle:
      block = try engine.block.create(.graphic)
      try engine.block.setShape(block, shape: engine.block.createShape(.rect))
      let fill = try engine.block.createFill(.color)
      if let color = element.color, color.count == 4 {
        try engine.block.setColor(
          fill,
          property: "fill/color/value",
          color: .rgba(r: color[0], g: color[1], b: color[2], a: color[3]),
        )
      }
      try engine.block.setFill(block, fill: fill)
    case .text:
      block = try engine.block.create(.text)
      try engine.block.replaceText(block, text: element.text ?? "")
      try engine.block.setHeightMode(block, mode: .auto)
    }

    try engine.block.setPositionX(block, value: element.x)
    try engine.block.setPositionY(block, value: element.y)
    try engine.block.setWidth(block, value: element.width)
    // Text auto-sizes its height; every other element takes the source height.
    if element.type != .text {
      try engine.block.setHeight(block, value: element.height)
    }
    try engine.block.appendChild(to: page, child: block)
  }
  // highlight-createCustomImporter-mapElements

  try await engine.captureGuide(page, label: "hero")

  // highlight-createCustomImporter-fitVerify
  try engine.scene.enableZoomAutoFit(
    page,
    axis: .both,
    paddingLeft: 40,
    paddingTop: 40,
    paddingRight: 40,
    paddingBottom: 40,
  )

  let pages = try engine.scene.getPages()
  print("Imported design has \(pages.count) page(s)")
  // highlight-createCustomImporter-fitVerify
}
