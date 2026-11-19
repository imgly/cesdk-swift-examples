import Foundation
import IMGLYEngine

@MainActor
func importSVG(engine: Engine) throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-importSVG-svgMarkup
  // A badge with a radial gradient, a stroked star and a dashed line.
  let badgeSVG = """
  <svg xmlns="http://www.w3.org/2000/svg" width="240" height="240" viewBox="0 0 240 240">
    <defs>
      <radialGradient id="glow" cx="120" cy="120" r="110" gradientUnits="userSpaceOnUse">
        <stop offset="0" stop-color="#ffd166"/>
        <stop offset="1" stop-color="#ef476f"/>
      </radialGradient>
    </defs>
    <circle cx="120" cy="120" r="110" fill="url(#glow)"/>
    <polygon points="120,40 143,97 205,97 155,133 174,192 120,156 66,192 85,133 35,97 97,97"
      fill="#ffffff" stroke="#073b4c" stroke-width="6" stroke-linejoin="round"/>
    <path d="M60 212 H180" fill="none" stroke="#073b4c" stroke-width="4"
      stroke-dasharray="12 6" stroke-linecap="round"/>
  </svg>
  """
  // highlight-importSVG-svgMarkup

  // highlight-importSVG-importSVG
  let badge = try engine.block.createFromSVG(badgeSVG)
  try engine.block.appendChild(to: page, child: badge)
  // highlight-importSVG-importSVG

  // highlight-importSVG-inspectResult
  let badgeType = try engine.block.getType(badge)
  print(badgeType == DesignBlockType.group.rawValue) // true
  let children = try engine.block.getChildren(badge)
  for child in children {
    let shape = try engine.block.getShape(child)
    let shapeType = try engine.block.getType(shape)
    print(shapeType == ShapeType.vectorPath.rawValue) // true
  }
  // highlight-importSVG-inspectResult

  // highlight-importSVG-designUnit
  let usesPixels = try engine.scene.getDesignUnit() == .px
  print(usesPixels) // true
  // highlight-importSVG-designUnit

  // highlight-importSVG-fitToPage
  let pageWidth = try engine.block.getWidth(page)
  let pageHeight = try engine.block.getHeight(page)
  let factor = try 0.8 * min(
    pageWidth / engine.block.getWidth(badge),
    pageHeight / engine.block.getHeight(badge),
  )
  // scale(_:to:anchorX:anchorY:) also scales the stroke widths and dashes.
  try engine.block.scale(badge, to: factor)
  try engine.block.setPositionX(badge, value: (pageWidth - engine.block.getWidth(badge)) / 2)
  try engine.block.setPositionY(badge, value: (pageHeight - engine.block.getHeight(badge)) / 2)
  // highlight-importSVG-fitToPage

  // highlight-importSVG-editShapes
  let star = children[1]
  let line = children[2]
  let starFill = try engine.block.getFill(star)
  try engine.block.setColor(
    starFill,
    property: "fill/color/value",
    color: .rgba(r: 0.02, g: 0.84, b: 0.63, a: 1),
  )
  try engine.block.setStrokeWidth(line, width: 12)
  // highlight-importSVG-editShapes

  // highlight-importSVG-handleErrors
  do {
    let block = try engine.block.createFromSVG("<html><body>No SVG here</body></html>")
    try engine.block.appendChild(to: page, child: block)
  } catch let error as EngineError where error.catalogCode == .blockSvgNotReadable {
    print("The markup has no SVG root element: \(error.localizedDescription)")
  }
  // highlight-importSVG-handleErrors

  // A failed import creates no block, so the badge stays the only child of the page.
  let pageChildren = try engine.block.getChildren(page)
  assert(pageChildren == [badge])
  assert(children.count == 3)
}
