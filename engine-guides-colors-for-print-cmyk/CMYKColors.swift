import Foundation
import IMGLYEngine

@MainActor
func cmykColors(engine: Engine) async throws {
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-cmykColors-create
  // CMYK components (c, m, y, k) and tint all range from 0.0 to 1.0.
  let cmykCyan = Color.cmyk(c: 1.0, m: 0.0, y: 0.0, k: 0.0, tint: 1.0)
  let cmykMagenta = Color.cmyk(c: 0.0, m: 1.0, y: 0.0, k: 0.0, tint: 1.0)
  let cmykYellow = Color.cmyk(c: 0.0, m: 0.0, y: 1.0, k: 0.0, tint: 1.0)
  let cmykBlack = Color.cmyk(c: 0.0, m: 0.0, y: 0.0, k: 1.0, tint: 1.0)
  // highlight-cmykColors-create

  // highlight-cmykColors-applyFill
  // Create a graphic block, attach a color fill, then assign a CMYK color.
  // The same setColor call works for any CMYK value.
  for cmykColor in [cmykCyan, cmykMagenta, cmykYellow, cmykBlack] {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setWidth(block, value: 150)
    try engine.block.setHeight(block, value: 150)
    try engine.block.appendChild(to: page, child: block)

    let fill = try engine.block.createFill(.color)
    try engine.block.setFill(block, fill: fill)
    try engine.block.setColor(fill, property: "fill/color/value", color: cmykColor)
  }
  // highlight-cmykColors-applyFill

  // highlight-cmykColors-tint
  // The tint value scales color intensity without changing the CMYK components.
  // On screen, a tint below 1.0 is rendered as transparency.
  let tintedBlock = try engine.block.create(.graphic)
  try engine.block.setShape(tintedBlock, shape: engine.block.createShape(.rect))
  try engine.block.appendChild(to: page, child: tintedBlock)
  let tintedFill = try engine.block.createFill(.color)
  try engine.block.setFill(tintedBlock, fill: tintedFill)

  let cmykHalfMagenta = Color.cmyk(c: 0.0, m: 1.0, y: 0.0, k: 0.0, tint: 0.5)
  try engine.block.setColor(tintedFill, property: "fill/color/value", color: cmykHalfMagenta)
  // highlight-cmykColors-tint

  // highlight-cmykColors-stroke
  // Enable the stroke and set its width before applying a CMYK color.
  let strokeBlock = try engine.block.create(.graphic)
  try engine.block.setShape(strokeBlock, shape: engine.block.createShape(.rect))
  try engine.block.appendChild(to: page, child: strokeBlock)

  try engine.block.setStrokeEnabled(strokeBlock, enabled: true)
  try engine.block.setStrokeWidth(strokeBlock, width: 8)
  let cmykStrokeColor = Color.cmyk(c: 0.8, m: 0.2, y: 0.0, k: 0.1, tint: 1.0)
  try engine.block.setColor(strokeBlock, property: "stroke/color", color: cmykStrokeColor)
  // highlight-cmykColors-stroke

  // highlight-cmykColors-shadow
  // Enable the drop shadow before applying a CMYK color.
  let shadowBlock = try engine.block.create(.graphic)
  try engine.block.setShape(shadowBlock, shape: engine.block.createShape(.rect))
  try engine.block.appendChild(to: page, child: shadowBlock)

  try engine.block.setDropShadowEnabled(shadowBlock, enabled: true)
  let cmykShadowColor = Color.cmyk(c: 0.0, m: 0.0, y: 0.0, k: 0.6, tint: 0.8)
  try engine.block.setColor(shadowBlock, property: "dropShadow/color", color: cmykShadowColor)
  // highlight-cmykColors-shadow

  // highlight-cmykColors-read
  // getColor returns a Color enum. Use pattern matching to inspect the CMYK components.
  let readBlock = try engine.block.create(.graphic)
  try engine.block.setShape(readBlock, shape: engine.block.createShape(.rect))
  try engine.block.appendChild(to: page, child: readBlock)
  let readFill = try engine.block.createFill(.color)
  try engine.block.setFill(readBlock, fill: readFill)

  let cmykOrange = Color.cmyk(c: 0.0, m: 0.5, y: 1.0, k: 0.0, tint: 1.0)
  try engine.block.setColor(readFill, property: "fill/color/value", color: cmykOrange)

  let retrievedColor: Color = try engine.block.getColor(readFill, property: "fill/color/value")
  if case let .cmyk(c, m, y, k, tint) = retrievedColor {
    print("CMYK Color - C: \(c), M: \(m), Y: \(y), K: \(k), Tint: \(tint)")
  }
  // highlight-cmykColors-read

  // highlight-cmykColors-convert
  // Convert between sRGB and CMYK using the editor API. Conversions are not
  // perfectly reversible because the color gamuts differ.
  let rgbBlue = Color.rgba(r: 0.2, g: 0.4, b: 0.9, a: 1.0)
  let convertedCmyk = try engine.editor.convertColorToColorSpace(color: rgbBlue, colorSpace: .cmyk)
  print("RGB to CMYK conversion: \(convertedCmyk)")

  let cmykGreen = Color.cmyk(c: 0.7, m: 0.0, y: 1.0, k: 0.2, tint: 1.0)
  let convertedRgb = try engine.editor.convertColorToColorSpace(color: cmykGreen, colorSpace: .sRGB)
  print("CMYK to RGB conversion: \(convertedRgb)")
  // highlight-cmykColors-convert

  // highlight-cmykColors-gradient
  // CMYK colors can be used in any gradient color stop.
  let gradientBlock = try engine.block.create(.graphic)
  try engine.block.setShape(gradientBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(gradientBlock, value: 320)
  try engine.block.setHeight(gradientBlock, value: 150)
  try engine.block.appendChild(to: page, child: gradientBlock)

  let gradientFill = try engine.block.createFill(.linearGradient)
  try engine.block.setFill(gradientBlock, fill: gradientFill)

  try engine.block.setGradientColorStops(
    gradientFill,
    property: "fill/gradient/colors",
    colors: [
      GradientColorStop(color: .cmyk(c: 1.0, m: 0.0, y: 0.0, k: 0.0, tint: 1.0), stop: 0.0),
      GradientColorStop(color: .cmyk(c: 0.0, m: 1.0, y: 0.0, k: 0.0, tint: 1.0), stop: 0.5),
      GradientColorStop(color: .cmyk(c: 0.0, m: 0.0, y: 1.0, k: 0.0, tint: 1.0), stop: 1.0),
    ],
  )
  // highlight-cmykColors-gradient
}
