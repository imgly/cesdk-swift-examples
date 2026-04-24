import Foundation
import IMGLYEngine

@MainActor
func createCompositionProgrammatic(engine: Engine) async throws {
  // highlight-setup
  // Roboto typeface with all variants for mixed styling
  let robotoBase = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.74.0-rc.0/assets/ly.img.typeface/fonts/Roboto"
  let robotoTypeface = Typeface(
    name: "Roboto",
    fonts: [
      Font(
        uri: URL(string: "\(robotoBase)/Roboto-Regular.ttf")!,
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
      Font(
        uri: URL(string: "\(robotoBase)/Roboto-Bold.ttf")!,
        subFamily: "Bold",
        weight: .bold,
        style: .normal,
      ),
      Font(
        uri: URL(string: "\(robotoBase)/Roboto-Italic.ttf")!,
        subFamily: "Italic",
        weight: .normal,
        style: .italic,
      ),
      Font(
        uri: URL(string: "\(robotoBase)/Roboto-BoldItalic.ttf")!,
        subFamily: "Bold Italic",
        weight: .bold,
        style: .italic,
      ),
    ],
  )
  // highlight-setup

  // highlight-create-scene
  // Create a scene and a page with social media dimensions (1080x1080)
  let scene = try engine.scene.create()
  try engine.block.setFloat(scene, property: "scene/dpi", value: 300)

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1080)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-create-scene

  // highlight-add-background
  // Set page background to a light lavender color
  let backgroundFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    backgroundFill,
    property: "fill/color/value",
    color: .rgba(r: 0.94, g: 0.93, b: 0.98, a: 1.0),
  )
  try engine.block.setFill(page, fill: backgroundFill)
  // highlight-add-background

  // highlight-text-create
  // Add the main headline text with the Roboto typeface
  let headline = try engine.block.create(.text)
  try engine.block.replaceText(headline, text: "Integrate\nCreative Editing\ninto your App")
  try engine.block.setFont(headline, fontFileURL: robotoTypeface.fonts[0].uri, typeface: robotoTypeface)
  try engine.block.setFloat(headline, property: "text/lineHeight", value: 0.78)
  // highlight-text-create

  // highlight-text-style-block
  // Apply bold weight and a black color to the whole headline
  if try engine.block.canToggleBoldFont(headline) {
    try engine.block.toggleBoldFont(headline)
  }
  try engine.block.setTextColor(headline, color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0))
  // highlight-text-style-block

  // highlight-text-auto-size
  // Fix the container size and let the font scale automatically
  try engine.block.setWidthMode(headline, mode: .absolute)
  try engine.block.setHeightMode(headline, mode: .absolute)
  try engine.block.setWidth(headline, value: 960)
  try engine.block.setHeight(headline, value: 300)
  try engine.block.setBool(headline, property: "text/automaticFontSizeEnabled", value: true)
  // highlight-text-auto-size

  try engine.block.setPositionX(headline, value: 60)
  try engine.block.setPositionY(headline, value: 80)
  try engine.block.appendChild(to: page, child: headline)

  // Add the tagline with mixed per-range styling
  let tagline = try engine.block.create(.text)
  let taglineText = "in hours,\nnot months."
  try engine.block.replaceText(tagline, text: taglineText)
  try engine.block.setFont(tagline, fontFileURL: robotoTypeface.fonts[0].uri, typeface: robotoTypeface)
  try engine.block.setFloat(tagline, property: "text/lineHeight", value: 0.78)

  // highlight-text-range-style
  // Style "in hours," — purple and italic
  let inHoursRange = taglineText.range(of: "in hours,")!
  try engine.block.setTextColor(tagline, color: .rgba(r: 0.2, g: 0.2, b: 0.8, a: 1.0), in: inHoursRange)
  if try engine.block.canToggleItalicFont(tagline, in: inHoursRange) {
    try engine.block.toggleItalicFont(tagline, in: inHoursRange)
  }

  // Style "not months." — black and bold
  let notMonthsRange = taglineText.range(of: "not months.")!
  try engine.block.setTextColor(tagline, color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0), in: notMonthsRange)
  if try engine.block.canToggleBoldFont(tagline, in: notMonthsRange) {
    try engine.block.toggleBoldFont(tagline, in: notMonthsRange)
  }
  // highlight-text-range-style

  try engine.block.setWidthMode(tagline, mode: .absolute)
  try engine.block.setHeightMode(tagline, mode: .absolute)
  try engine.block.setWidth(tagline, value: 960)
  try engine.block.setHeight(tagline, value: 220)
  try engine.block.setBool(tagline, property: "text/automaticFontSizeEnabled", value: true)
  try engine.block.setPositionX(tagline, value: 60)
  try engine.block.setPositionY(tagline, value: 551)
  try engine.block.appendChild(to: page, child: tagline)

  // highlight-text-fixed-size
  // Add the CTA title with an explicit font size
  let ctaTitle = try engine.block.create(.text)
  try engine.block.replaceText(ctaTitle, text: "Start a Free Trial")
  try engine.block.setFont(ctaTitle, fontFileURL: robotoTypeface.fonts[0].uri, typeface: robotoTypeface)
  try engine.block.setFloat(ctaTitle, property: "text/fontSize", value: 80)
  try engine.block.setFloat(ctaTitle, property: "text/lineHeight", value: 1.0)
  // highlight-text-fixed-size

  if try engine.block.canToggleBoldFont(ctaTitle) {
    try engine.block.toggleBoldFont(ctaTitle)
  }
  try engine.block.setTextColor(ctaTitle, color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0))

  try engine.block.setWidthMode(ctaTitle, mode: .absolute)
  try engine.block.setHeightMode(ctaTitle, mode: .auto)
  try engine.block.setWidth(ctaTitle, value: 664.6)
  try engine.block.setPositionX(ctaTitle, value: 64)
  try engine.block.setPositionY(ctaTitle, value: 952)
  try engine.block.appendChild(to: page, child: ctaTitle)

  // Add the website URL
  let ctaURL = try engine.block.create(.text)
  try engine.block.replaceText(ctaURL, text: "www.img.ly")
  try engine.block.setFont(ctaURL, fontFileURL: robotoTypeface.fonts[0].uri, typeface: robotoTypeface)
  try engine.block.setFloat(ctaURL, property: "text/fontSize", value: 80)
  try engine.block.setFloat(ctaURL, property: "text/lineHeight", value: 1.0)
  try engine.block.setTextColor(ctaURL, color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0))

  try engine.block.setWidthMode(ctaURL, mode: .absolute)
  try engine.block.setHeightMode(ctaURL, mode: .auto)
  try engine.block.setWidth(ctaURL, value: 664.6)
  try engine.block.setPositionX(ctaURL, value: 64)
  try engine.block.setPositionY(ctaURL, value: 1006)
  try engine.block.appendChild(to: page, child: ctaURL)

  // highlight-shape-create
  // Add a horizontal divider line
  let dividerLine = try engine.block.create(.graphic)
  let lineShape = try engine.block.createShape(.line)
  try engine.block.setShape(dividerLine, shape: lineShape)
  // highlight-shape-create

  // highlight-shape-fill
  let lineFill = try engine.block.createFill(.color)
  try engine.block.setColor(lineFill, property: "fill/color/value", color: .rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0))
  try engine.block.setFill(dividerLine, fill: lineFill)
  // highlight-shape-fill

  try engine.block.setWidth(dividerLine, value: 418)
  try engine.block.setHeight(dividerLine, value: 11.3)
  try engine.block.setPositionX(dividerLine, value: 64)
  try engine.block.setPositionY(dividerLine, value: 460)
  try engine.block.appendChild(to: page, child: dividerLine)

  // highlight-image-create
  // Add the IMG.LY logo image
  let logo = try engine.block.create(.graphic)
  let logoShape = try engine.block.createShape(.rect)
  try engine.block.setShape(logo, shape: logoShape)

  let logoFill = try engine.block.createFill(.image)
  try engine.block.setString(
    logoFill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/imgly_logo.jpg",
  )
  try engine.block.setFill(logo, fill: logoFill)
  // highlight-image-create

  // highlight-block-position
  try engine.block.setContentFillMode(logo, mode: .contain)
  try engine.block.setWidth(logo, value: 200)
  try engine.block.setHeight(logo, value: 65)
  try engine.block.setPositionX(logo, value: 820)
  try engine.block.setPositionY(logo, value: 960)
  try engine.block.appendChild(to: page, child: logo)
  // highlight-block-position

  // highlight-export-api
  // Export the composition as a PNG
  let options = ExportOptions(targetWidth: 1080, targetHeight: 1080)
  let blob = try await engine.block.export(page, mimeType: .png, options: options)
  // highlight-export-api

  // highlight-export-file
  // Write the exported data to disk
  let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("composition.png")
  try blob.write(to: outputURL)
  // highlight-export-file
}
