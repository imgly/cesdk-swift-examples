import Foundation
import IMGLYEngine

@MainActor
func boolOps(engine: Engine) async throws {
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let baseURL = try engine.guidesBaseURL

  // Union demo: three overlapping circles in the top-left quadrant.
  let circle1 = try engine.block.create(.graphic)
  try engine.block.setShape(circle1, shape: engine.block.createShape(.ellipse))
  let fill1 = try engine.block.createFill(.color)
  try engine.block.setColor(
    fill1,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.35, b: 0.35, a: 1.0),
  )
  try engine.block.setFill(circle1, fill: fill1)
  try engine.block.setPositionX(circle1, value: 120)
  try engine.block.setPositionY(circle1, value: 90)
  try engine.block.setWidth(circle1, value: 110)
  try engine.block.setHeight(circle1, value: 110)
  try engine.block.appendChild(to: page, child: circle1)

  let circle2 = try engine.block.create(.graphic)
  try engine.block.setShape(circle2, shape: engine.block.createShape(.ellipse))
  let fill2 = try engine.block.createFill(.color)
  try engine.block.setColor(
    fill2,
    property: "fill/color/value",
    color: .rgba(r: 0.30, g: 0.80, b: 0.45, a: 1.0),
  )
  try engine.block.setFill(circle2, fill: fill2)
  try engine.block.setPositionX(circle2, value: 190)
  try engine.block.setPositionY(circle2, value: 90)
  try engine.block.setWidth(circle2, value: 110)
  try engine.block.setHeight(circle2, value: 110)
  try engine.block.appendChild(to: page, child: circle2)

  let circle3 = try engine.block.create(.graphic)
  try engine.block.setShape(circle3, shape: engine.block.createShape(.ellipse))
  let fill3 = try engine.block.createFill(.color)
  try engine.block.setColor(
    fill3,
    property: "fill/color/value",
    color: .rgba(r: 0.25, g: 0.55, b: 0.95, a: 1.0),
  )
  try engine.block.setFill(circle3, fill: fill3)
  try engine.block.setPositionX(circle3, value: 155)
  try engine.block.setPositionY(circle3, value: 140)
  try engine.block.setWidth(circle3, value: 130)
  try engine.block.setHeight(circle3, value: 130)
  try engine.block.appendChild(to: page, child: circle3)

  // highlight-bool-ops-check-combinability
  if try engine.block.isCombinable([circle1, circle2, circle3]) {
    print("Blocks are combinable")
  }
  // highlight-bool-ops-check-combinability

  // highlight-bool-ops-combine-union
  let unionResult = try engine.block.combine(
    [circle1, circle2, circle3],
    booleanOperation: .union,
  )
  try engine.block.setName(unionResult, name: "Union")
  // highlight-bool-ops-combine-union

  try await engine.captureGuide(page, label: "after-union")

  // Difference demo: a star punched out of an image in the top-right quadrant.
  let image = try engine.block.create(.graphic)
  try engine.block.setShape(image, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(image, fill: imageFill)
  try engine.block.setPositionX(image, value: 460)
  try engine.block.setPositionY(image, value: 60)
  try engine.block.setWidth(image, value: 280)
  try engine.block.setHeight(image, value: 180)
  try engine.block.appendChild(to: page, child: image)

  let cutoutStar = try engine.block.create(.graphic)
  try engine.block.setShape(cutoutStar, shape: engine.block.createShape(.star))
  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    starFill,
    property: "fill/color/value",
    color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0),
  )
  try engine.block.setFill(cutoutStar, fill: starFill)
  try engine.block.setPositionX(cutoutStar, value: 520)
  try engine.block.setPositionY(cutoutStar, value: 80)
  try engine.block.setWidth(cutoutStar, value: 160)
  try engine.block.setHeight(cutoutStar, value: 140)
  try engine.block.appendChild(to: page, child: cutoutStar)

  // highlight-bool-ops-combine-difference
  // Load image resources before combining media-backed blocks so the
  // resulting image fill is ready for rendering.
  try await engine.block.forceLoadResources([image])
  // Difference subtracts upper blocks from the bottom-most base block and
  // inherits the base block's fill, so send the image to the back first.
  try engine.block.sendToBack(image)
  let differenceResult = try engine.block.combine(
    [image, cutoutStar],
    booleanOperation: .difference,
  )
  try engine.block.setName(differenceResult, name: "Difference")
  // highlight-bool-ops-combine-difference

  try await engine.captureGuide(page, label: "after-difference")

  // Intersection demo: two overlapping circles in the bottom-left quadrant.
  let lensA = try engine.block.create(.graphic)
  try engine.block.setShape(lensA, shape: engine.block.createShape(.ellipse))
  let lensFillA = try engine.block.createFill(.color)
  try engine.block.setColor(
    lensFillA,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.80, b: 0.25, a: 1.0),
  )
  try engine.block.setFill(lensA, fill: lensFillA)
  try engine.block.setPositionX(lensA, value: 60)
  try engine.block.setPositionY(lensA, value: 360)
  try engine.block.setWidth(lensA, value: 200)
  try engine.block.setHeight(lensA, value: 200)
  try engine.block.appendChild(to: page, child: lensA)

  let lensB = try engine.block.create(.graphic)
  try engine.block.setShape(lensB, shape: engine.block.createShape(.ellipse))
  let lensFillB = try engine.block.createFill(.color)
  try engine.block.setColor(
    lensFillB,
    property: "fill/color/value",
    color: .rgba(r: 0.30, g: 0.70, b: 0.85, a: 1.0),
  )
  try engine.block.setFill(lensB, fill: lensFillB)
  try engine.block.setPositionX(lensB, value: 180)
  try engine.block.setPositionY(lensB, value: 360)
  try engine.block.setWidth(lensB, value: 200)
  try engine.block.setHeight(lensB, value: 200)
  try engine.block.appendChild(to: page, child: lensB)

  // highlight-bool-ops-combine-intersection
  // Intersection inherits the bottom-most block's fill, so send the block
  // whose fill should survive to the back before combining.
  try engine.block.sendToBack(lensA)
  let intersectionResult = try engine.block.combine(
    [lensA, lensB],
    booleanOperation: .intersection,
  )
  try engine.block.setName(intersectionResult, name: "Intersection")
  // highlight-bool-ops-combine-intersection

  try await engine.captureGuide(page, label: "after-intersection")

  // XOR demo: two overlapping circles in the bottom-right quadrant.
  let xorA = try engine.block.create(.graphic)
  try engine.block.setShape(xorA, shape: engine.block.createShape(.ellipse))
  let xorFillA = try engine.block.createFill(.color)
  try engine.block.setColor(
    xorFillA,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.40, b: 0.70, a: 1.0),
  )
  try engine.block.setFill(xorA, fill: xorFillA)
  try engine.block.setPositionX(xorA, value: 460)
  try engine.block.setPositionY(xorA, value: 360)
  try engine.block.setWidth(xorA, value: 200)
  try engine.block.setHeight(xorA, value: 200)
  try engine.block.appendChild(to: page, child: xorA)

  let xorB = try engine.block.create(.graphic)
  try engine.block.setShape(xorB, shape: engine.block.createShape(.ellipse))
  let xorFillB = try engine.block.createFill(.color)
  try engine.block.setColor(
    xorFillB,
    property: "fill/color/value",
    color: .rgba(r: 1.0, g: 0.60, b: 0.20, a: 1.0),
  )
  try engine.block.setFill(xorB, fill: xorFillB)
  try engine.block.setPositionX(xorB, value: 580)
  try engine.block.setPositionY(xorB, value: 360)
  try engine.block.setWidth(xorB, value: 200)
  try engine.block.setHeight(xorB, value: 200)
  try engine.block.appendChild(to: page, child: xorB)

  // highlight-bool-ops-combine-xor
  // XOR inherits the top-most block's fill.
  let xorResult = try engine.block.combine(
    [xorA, xorB],
    booleanOperation: .xor,
  )
  try engine.block.setName(xorResult, name: "XOR")
  // highlight-bool-ops-combine-xor

  try await engine.captureGuide(page, label: "hero")
}
