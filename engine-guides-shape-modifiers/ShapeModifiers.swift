import Foundation
import IMGLYEngine

@MainActor
func shapeModifiers(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-shapeModifiers-createBlocks
  // Adds a 5 second graphic with a shape and a color fill to the page
  func addGraphic(
    _ shapeType: ShapeType,
    x: Float,
    y: Float,
    width: Float,
    height: Float,
    color: Color,
  ) throws -> DesignBlockID {
    let graphic = try engine.block.create(.graphic)
    try engine.block.setShape(graphic, shape: engine.block.createShape(shapeType))
    let fill = try engine.block.createFill(.color)
    try engine.block.setColor(fill, property: "fill/color/value", color: color)
    try engine.block.setFill(graphic, fill: fill)
    try engine.block.setWidth(graphic, value: width)
    try engine.block.setHeight(graphic, value: height)
    try engine.block.setPositionX(graphic, value: x)
    try engine.block.setPositionY(graphic, value: y)
    try engine.block.setDuration(graphic, duration: 5)
    try engine.block.appendChild(to: page, child: graphic)
    return graphic
  }
  // highlight-shapeModifiers-createBlocks

  // highlight-shapeModifiers-createModifier
  let orange = Color.rgba(r: 1, g: 0.5, b: 0, a: 1)
  let outline = try addGraphic(.star, x: 120, y: 360, width: 360, height: 360, color: orange)

  // Modifiers belong to the shape block, not to the graphic block
  let outlineShape = try engine.block.getShape(outline)
  print(try engine.block.supportsModifiers(outlineShape)) // true
  print(try engine.block.supportsModifiers(outline)) // false

  let trim = try engine.block.createModifier(.trim)
  try engine.block.appendModifier(outlineShape, modifierID: trim)
  // highlight-shapeModifiers-createModifier

  // highlight-shapeModifiers-trim
  // Draw the outline only: no fill and a thick stroke
  try engine.block.setFillEnabled(outline, enabled: false)
  try engine.block.setStrokeEnabled(outline, enabled: true)
  try engine.block.setStrokeWidth(outline, width: 16)
  try engine.block.setStrokeColor(outline, color: orange)

  // Keep the first 75% of the path, moved by an eighth of the path length
  try engine.block.setFloat(trim, property: "modifier/trim/start", value: 0)
  try engine.block.setFloat(trim, property: "modifier/trim/end", value: 0.75)
  try engine.block.setFloat(trim, property: "modifier/trim/offset", value: 0.125)
  // "Simultaneous" trims each contour on its own, "Individual" trims all contours as one path
  try engine.block.setEnum(trim, property: "modifier/trim/mode", value: "Simultaneous")
  // highlight-shapeModifiers-trim

  // highlight-shapeModifiers-animateTrim
  // Draw the whole outline during the first 3 seconds of the 5 second block
  try engine.block.setKeyframes(trim, property: "modifier/trim/end", keyframes: [
    Keyframe(time: 0, value: .float(0), easing: .preset(.easeInOut)),
    Keyframe(time: 0.6, value: .float(1)),
  ])
  // highlight-shapeModifiers-animateTrim

  // highlight-shapeModifiers-repeater
  // A 40 x 140 bar, repeated around a point 220 units below its top edge
  let blue = Color.rgba(r: 0.2, g: 0.5, b: 1, a: 1)
  let bar = try addGraphic(.rect, x: 720, y: 320, width: 40, height: 140, color: blue)
  let repeater = try engine.block.createModifier(.repeater)
  try engine.block.setFloat(repeater, property: "modifier/repeater/copies", value: 12)
  // Each copy turns 30 degrees further about the anchor and does not move
  try engine.block.setFloat(repeater, property: "modifier/repeater/anchorX", value: 20)
  try engine.block.setFloat(repeater, property: "modifier/repeater/anchorY", value: 220)
  try engine.block.setFloat(repeater, property: "modifier/repeater/rotation", value: 30)
  try engine.block.setFloat(repeater, property: "modifier/repeater/positionX", value: 0)
  try engine.block.setFloat(repeater, property: "modifier/repeater/positionY", value: 0)
  // The copies fade from full opacity towards 10%
  try engine.block.setFloat(repeater, property: "modifier/repeater/startOpacity", value: 1)
  try engine.block.setFloat(repeater, property: "modifier/repeater/endOpacity", value: 0.1)
  // "Above" draws each copy on top of the copy before it
  try engine.block.setEnum(repeater, property: "modifier/repeater/composite", value: "Above")
  try engine.block.appendModifier(engine.block.getShape(bar), modifierID: repeater)
  // highlight-shapeModifiers-repeater

  // highlight-shapeModifiers-animateRepeater
  // Grow the ring from 1 to 12 bars
  try engine.block.setKeyframes(repeater, property: "modifier/repeater/copies", keyframes: [
    Keyframe(time: 0, value: .float(1)),
    Keyframe(time: 0.8, value: .float(12)),
  ])
  // highlight-shapeModifiers-animateRepeater

  // highlight-shapeModifiers-order
  let purple = Color.rgba(r: 0.5, g: 0.2, b: 0.9, a: 1)
  let badge = try addGraphic(.rect, x: 1000, y: 360, width: 360, height: 360, color: purple)
  let badgeShape = try engine.block.getShape(badge)

  // Smooth peaks and valleys, 6 per side, 12 units from the path
  let zigzag = try engine.block.createModifier(.zigzag)
  try engine.block.setFloat(zigzag, property: "modifier/zigzag/size", value: 12)
  try engine.block.setFloat(zigzag, property: "modifier/zigzag/ridges", value: 6)
  try engine.block.setEnum(zigzag, property: "modifier/zigzag/pointType", value: "Smooth")
  try engine.block.appendModifier(badgeShape, modifierID: zigzag)

  // Insert the rounding at index 0, so it applies before the zig zag
  let roundCorners = try engine.block.createModifier(.roundCorners)
  try engine.block.setFloat(roundCorners, property: "modifier/round_corners/radius", value: 60)
  try engine.block.insertModifier(badgeShape, modifierID: roundCorners, index: 0)
  // highlight-shapeModifiers-order

  // highlight-shapeModifiers-geometry
  let teal = Color.rgba(r: 0, g: 0.6, b: 0.6, a: 1)
  let flower = try addGraphic(.star, x: 1440, y: 360, width: 360, height: 360, color: teal)
  let flowerShape = try engine.block.getShape(flower)

  // A negative amount bloats: it pushes the vertices away from the center
  let puckerBloat = try engine.block.createModifier(.puckerBloat)
  try engine.block.setFloat(puckerBloat, property: "modifier/pucker_bloat/amount", value: -0.3)
  try engine.block.appendModifier(flowerShape, modifierID: puckerBloat)

  // Turn the path 45 degrees at the center of the block, less towards the edge
  let twist = try engine.block.createModifier(.twist)
  try engine.block.setFloat(twist, property: "modifier/twist/angle", value: 45)
  try engine.block.setFloat(twist, property: "modifier/twist/centerX", value: 180)
  try engine.block.setFloat(twist, property: "modifier/twist/centerY", value: 180)
  try engine.block.appendModifier(flowerShape, modifierID: twist)

  // Grow the result by 12 units with round corners
  let offset = try engine.block.createModifier(.offset)
  try engine.block.setFloat(offset, property: "modifier/offset/amount", value: 12)
  try engine.block.setEnum(offset, property: "modifier/offset/join", value: "Round")
  try engine.block.appendModifier(flowerShape, modifierID: offset)
  // highlight-shapeModifiers-geometry

  // highlight-shapeModifiers-readBack
  let badgeModifierTypes = try engine.block.getModifiers(badgeShape).map { try engine.block.getType($0) }
  print(badgeModifierTypes) // ["//ly.img.ubq/modifier/round_corners", "//ly.img.ubq/modifier/zigzag"]

  // Find every trim modifier in the scene
  let foundTrims = try engine.block.find(byType: ModifierType.trim)
  print(foundTrims == [trim]) // true
  // highlight-shapeModifiers-readBack

  // highlight-shapeModifiers-remove
  // Remove the zig zag at index 1. The modifier block still exists.
  try engine.block.removeModifier(badgeShape, index: 1)
  print(engine.block.isValid(zigzag)) // true

  // Destroy it when no shape uses it any more
  try engine.block.destroy(zigzag)
  // highlight-shapeModifiers-remove

  // highlight-shapeModifiers-errors
  do {
    // A graphic block has no modifiers. Pass its shape instead.
    _ = try engine.block.getModifiers(outline)
  } catch let error as EngineError {
    print(error.catalogCode == .blockModifiersUnsupported) // true
  }
  // highlight-shapeModifiers-errors

  // highlight-shapeModifiers-export
  // Export the frame at 2.5 seconds, halfway through the animation
  try engine.block.setPlaybackTime(page, time: 2.5)
  let png = try await engine.block.export(page, mimeType: .png)
  print("Exported \(png.count) bytes")
  // highlight-shapeModifiers-export
}
