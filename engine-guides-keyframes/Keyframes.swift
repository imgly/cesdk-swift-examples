import Foundation
import IMGLYEngine

@MainActor
func keyframes(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-keyframes-createBlock
  // A 5 second rectangle with a color fill and a rect shape
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  try engine.block.setWidth(block, value: 600)
  try engine.block.setHeight(block, value: 400)
  try engine.block.setPositionX(block, value: 360)
  try engine.block.setPositionY(block, value: 340)
  try engine.block.appendChild(to: page, child: block)
  try engine.block.setDuration(block, duration: 5)

  // The fill and the shape own their properties and their keyframes
  let fill = try engine.block.getFill(block)
  let shape = try engine.block.getShape(block)
  // highlight-keyframes-createBlock

  // highlight-keyframes-checkAnimatable
  let opacityIsAnimatable = try engine.block.isPropertyAnimatable(block, property: "opacity")
  let fillColorIsAnimatable = try engine.block.isPropertyAnimatable(fill, property: "fill/color/value")
  let visibleIsAnimatable = try engine.block.isPropertyAnimatable(block, property: "visible")
  print("opacity: \(opacityIsAnimatable), fill color: \(fillColorIsAnimatable), visible: \(visibleIsAnimatable)")
  // highlight-keyframes-checkAnimatable

  // highlight-keyframes-fadeIn
  // Fade in during the first 40% of the block's duration (2 seconds)
  try engine.block.setKeyframes(block, property: "opacity", keyframes: [
    Keyframe(time: 0, value: .float(0), easing: .preset(.easeOut)),
    Keyframe(time: 0.4, value: .float(1)),
  ])
  // highlight-keyframes-fadeIn

  // highlight-keyframes-colorHold
  // Orange, then a hold on purple, then a fade to teal
  try engine.block.setKeyframes(fill, property: "fill/color/value", keyframes: [
    Keyframe(time: 0, value: .color(.rgba(r: 1, g: 0.5, b: 0, a: 1))),
    Keyframe(time: 0.5, value: .color(.rgba(r: 0.5, g: 0.2, b: 0.9, a: 1)), easing: .hold),
    Keyframe(time: 0.75, value: .color(.rgba(r: 0.4, g: 0.8, b: 0.8, a: 1))),
    Keyframe(time: 1, value: .color(.rgba(r: 0, g: 0.6, b: 0.6, a: 1))),
  ])
  // highlight-keyframes-colorHold

  // highlight-keyframes-bezier
  // Grow every corner radius with a CSS-style cubic bezier
  for corner in ["TL", "TR", "BL", "BR"] {
    try engine.block.setKeyframes(shape, property: "shape/rect/cornerRadius\(corner)", keyframes: [
      Keyframe(time: 0, value: .float(0), easing: .bezier(out: SIMD2(0.7, 0), in: SIMD2(0.3, 1))),
      Keyframe(time: 1, value: .float(200)),
    ])
  }
  // highlight-keyframes-bezier

  // highlight-keyframes-relative
  // Slide 600 units to the right of the block's static x position
  try engine.block.setKeyframes(block, property: "position/x", keyframes: [
    Keyframe(time: 0, value: .float(0)),
    Keyframe(time: 1, value: .float(600)),
  ], mode: .relative)
  // highlight-keyframes-relative

  // highlight-keyframes-discrete
  // Switch the stroke on halfway; discrete values never interpolate
  try engine.block.setStrokeWidth(block, width: 12)
  try engine.block.setStrokeColor(block, color: .rgba(r: 0, g: 0, b: 0, a: 1))
  try engine.block.setKeyframes(block, property: "stroke/enabled", keyframes: [
    Keyframe(time: 0, value: .discrete(.bool(false))),
    Keyframe(time: 0.5, value: .discrete(.bool(true))),
  ])
  // highlight-keyframes-discrete

  // highlight-keyframes-motionPath
  // A dot follows a curved path. Vec2 keyframes animate `position/x` and
  // `position/y` together, and the tangents bend the path upward.
  let dot = try engine.block.create(.graphic)
  try engine.block.setShape(dot, shape: engine.block.createShape(.ellipse))
  let dotFill = try engine.block.createFill(.color)
  try engine.block.setColor(dotFill, property: "fill/color/value", color: .rgba(r: 0.9, g: 0.2, b: 0.4, a: 1))
  try engine.block.setFill(dot, fill: dotFill)
  try engine.block.setWidth(dot, value: 120)
  try engine.block.setHeight(dot, value: 120)
  try engine.block.appendChild(to: page, child: dot)
  try engine.block.setDuration(dot, duration: 5)
  // The static position is the start of the path.
  try engine.block.setVec2(dot, property: "position", value: [200, 900])

  try engine.block.setKeyframes(dot, property: "position", keyframes: [
    Keyframe(time: 0, value: .vec2([200, 900]), spatialOut: [300, -600], spatialIn: [-300, -600]),
    Keyframe(time: 1, value: .vec2([1600, 900])),
  ])
  // highlight-keyframes-motionPath

  // highlight-keyframes-scale
  // Pulse the dot to 1.5 times its size and back. Its frame does not change.
  for axis in ["x", "y"] {
    try engine.block.setKeyframes(dot, property: "transform/scale/\(axis)", keyframes: [
      Keyframe(time: 0, value: .float(1)),
      Keyframe(time: 0.5, value: .float(1.5)),
      Keyframe(time: 1, value: .float(1)),
    ])
  }
  print(try engine.block.getAnimatedProperties(dot)) // ["position", "transform/scale/x", "transform/scale/y"]
  // highlight-keyframes-scale

  // highlight-keyframes-readBack
  // ["opacity", "position/x", "stroke/enabled"]
  let animatedProperties = try engine.block.getAnimatedProperties(block)

  // The second keyframe reports the default easing, .preset(.linear)
  let opacityKeyframes = try engine.block.getKeyframes(block, property: "opacity")

  // .relative
  let positionMode = try engine.block.getKeyframeMode(block, property: "position/x")
  print(animatedProperties, opacityKeyframes[1].easing, positionMode == .relative)
  // highlight-keyframes-readBack

  // highlight-keyframes-staticValue
  // Changes the static value only. The absolute opacity track still replaces it.
  try engine.block.setOpacity(block, value: 0.5)
  let opacityKeyframeCount = try engine.block.getKeyframes(block, property: "opacity").count
  print(opacityKeyframeCount) // 2
  // highlight-keyframes-staticValue

  // highlight-keyframes-remove
  // The bottom corners return to their static radius of 0
  try engine.block.removeKeyframes(shape, property: "shape/rect/cornerRadiusBL")
  try engine.block.removeKeyframes(shape, property: "shape/rect/cornerRadiusBR")
  let shapeAnimatedProperties = try engine.block.getAnimatedProperties(shape)
  print(shapeAnimatedProperties) // ["shape/rect/cornerRadiusTL", "shape/rect/cornerRadiusTR"]
  // highlight-keyframes-remove

  // highlight-keyframes-errors
  do {
    try engine.block.setKeyframes(block, property: "visible", keyframes: [
      Keyframe(time: 0, value: .discrete(.bool(true))),
    ])
  } catch let error as EngineError {
    print(error.catalogCode == .blockKeyframesPropertyNotAnimatable) // true
  }
  // highlight-keyframes-errors

  // highlight-keyframes-export
  // Export the frame at 2.5 seconds, halfway through the animation
  try engine.block.setPlaybackTime(page, time: 2.5)
  let png = try await engine.block.export(page, mimeType: .png)
  print("Exported \(png.count) bytes")
  // highlight-keyframes-export

  try await engine.captureGuide(page, label: "hero")

  // highlight-keyframes-anchorSkew
  // A bar that leans by 20 degrees and turns half a turn about its centre.
  // The anchor is in design units from the top-left corner of the frame.
  let bar = try engine.block.create(.graphic)
  try engine.block.setShape(bar, shape: engine.block.createShape(.rect))
  try engine.block.setFill(bar, fill: engine.block.createFill(.color))
  try engine.block.setWidth(bar, value: 320)
  try engine.block.setHeight(bar, value: 80)
  try engine.block.setPositionX(bar, value: 120)
  try engine.block.setPositionY(bar, value: 120)
  try engine.block.appendChild(to: page, child: bar)
  try engine.block.setDuration(bar, duration: 5)
  try engine.block.setFloat(bar, property: "transform/anchor/x", value: 160)
  try engine.block.setFloat(bar, property: "transform/anchor/y", value: 40)
  try engine.block.setFloat(bar, property: "transform/skew", value: 20)
  try engine.block.setKeyframes(bar, property: "rotation", keyframes: [
    Keyframe(time: 0, value: .float(0)),
    Keyframe(time: 1, value: .float(.pi)),
  ])
  // highlight-keyframes-anchorSkew

  // highlight-keyframes-hasAnchor
  // The bar has an anchor, so its rotation track turns it about the anchor.
  // A graphic or text without an anchor turns about its frame centre.
  print(try engine.block.hasTransformAnchor(bar)) // true
  // highlight-keyframes-hasAnchor

  // highlight-keyframes-autoOrient
  // A bar on a wavy path turns to follow the direction of its motion
  let arrow = try engine.block.create(.graphic)
  try engine.block.setShape(arrow, shape: engine.block.createShape(.rect))
  let arrowFill = try engine.block.createFill(.color)
  try engine.block.setColor(arrowFill, property: "fill/color/value", color: .rgba(r: 0.1, g: 0.6, b: 0.3, a: 1))
  try engine.block.setFill(arrow, fill: arrowFill)
  try engine.block.setWidth(arrow, value: 160)
  try engine.block.setHeight(arrow, value: 40)
  try engine.block.appendChild(to: page, child: arrow)
  try engine.block.setDuration(arrow, duration: 5)
  try engine.block.setFloat(arrow, property: "transform/anchor/x", value: 80)
  try engine.block.setFloat(arrow, property: "transform/anchor/y", value: 20)
  try engine.block.setVec2(arrow, property: "position", value: [700, 140])
  try engine.block.setKeyframes(arrow, property: "position", keyframes: [
    Keyframe(time: 0, value: .vec2([700, 140]), spatialOut: [300, 150], spatialIn: [-300, -150]),
    Keyframe(time: 1, value: .vec2([1600, 140])),
  ])
  try engine.block.setBool(arrow, property: "transform/autoOrient", value: true)
  // highlight-keyframes-autoOrient

  // highlight-keyframes-transformParent
  // A square rides in front of the arrow. Its position is read in the
  // arrow's local space, so it moves and turns with the arrow.
  let rider = try engine.block.create(.graphic)
  try engine.block.setShape(rider, shape: engine.block.createShape(.rect))
  let riderFill = try engine.block.createFill(.color)
  try engine.block.setColor(riderFill, property: "fill/color/value", color: .rgba(r: 0.95, g: 0.7, b: 0.1, a: 1))
  try engine.block.setFill(rider, fill: riderFill)
  try engine.block.setWidth(rider, value: 40)
  try engine.block.setHeight(rider, value: 40)
  try engine.block.setPositionX(rider, value: 170)
  try engine.block.setPositionY(rider, value: 0)
  try engine.block.appendChild(to: page, child: rider)
  try engine.block.setTransformParent(rider, parent: arrow)
  print(try engine.block.getTransformParent(rider) == arrow) // true

  do {
    // The arrow cannot follow a block that follows the arrow
    try engine.block.setTransformParent(arrow, parent: rider)
  } catch let error as EngineError {
    print(error.catalogCode == .blockTransformParentCycle) // true
  }
  // highlight-keyframes-transformParent
}
