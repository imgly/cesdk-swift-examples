import Foundation
import IMGLYEngine

@MainActor
func createTemplateFromScratch(engine: Engine) async throws {
  // Resolve sample assets (fonts, image) against the engine's configured base URL.
  let baseURL = try engine.guidesBaseURL

  // highlight-createTemplateFromScratch-createScene
  let scene = try engine.scene.create(designUnit: .px, fontSizeUnit: .px)

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 1000)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-createTemplateFromScratch-createScene

  // highlight-createTemplateFromScratch-addBackground
  let backgroundFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    backgroundFill,
    property: "fill/color/value",
    color: .rgba(r: 0.98, g: 0.98, b: 0.99, a: 1),
  )
  try engine.block.setFill(page, fill: backgroundFill)
  // highlight-createTemplateFromScratch-addBackground

  // highlight-createTemplateFromScratch-addText
  let brandTypeface = Typeface(
    name: "Brand Sans",
    fonts: [
      Font(
        uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Regular.ttf"),
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
      Font(
        uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Bold.ttf"),
        subFamily: "Bold",
        weight: .bold,
        style: .normal,
      ),
    ],
  )
  let brandRegularFont = brandTypeface.fonts[0]

  let headline = try engine.block.create(.text)
  try engine.block.replaceText(headline, text: "{{title}}")
  try engine.block.setFont(headline, fontFileURL: brandRegularFont.uri, typeface: brandTypeface)
  try engine.block.setTextFontSize(headline, fontSize: 72)
  try engine.block.setTextColor(headline, color: .rgba(r: 0.09, g: 0.09, b: 0.09, a: 1))
  try engine.block.setPositionX(headline, value: 72)
  try engine.block.setPositionY(headline, value: 96)
  try engine.block.setWidth(headline, value: 656)
  try engine.block.setHeightMode(headline, mode: .auto)
  try engine.block.appendChild(to: page, child: headline)

  let subtitle = try engine.block.create(.text)
  try engine.block.replaceText(subtitle, text: "{{subtitle}}")
  try engine.block.setFont(subtitle, fontFileURL: brandRegularFont.uri, typeface: brandTypeface)
  try engine.block.setTextFontSize(subtitle, fontSize: 32)
  try engine.block.setTextColor(subtitle, color: .rgba(r: 0.32, g: 0.32, b: 0.32, a: 1))
  try engine.block.setPositionX(subtitle, value: 72)
  try engine.block.setPositionY(subtitle, value: 194)
  try engine.block.setWidth(subtitle, value: 620)
  try engine.block.setHeightMode(subtitle, mode: .auto)
  try engine.block.appendChild(to: page, child: subtitle)

  let cta = try engine.block.create(.text)
  try engine.block.replaceText(cta, text: "{{cta}}")
  try engine.block.setFont(cta, fontFileURL: brandRegularFont.uri, typeface: brandTypeface)
  try engine.block.setTextFontSize(cta, fontSize: 36)
  try engine.block.setTextColor(cta, color: .rgba(r: 0.09, g: 0.09, b: 0.09, a: 1))
  try engine.block.setPositionX(cta, value: 72)
  try engine.block.setPositionY(cta, value: 858)
  try engine.block.setWidth(cta, value: 400)
  try engine.block.setHeightMode(cta, mode: .auto)
  try engine.block.appendChild(to: page, child: cta)
  // highlight-createTemplateFromScratch-addText

  // highlight-createTemplateFromScratch-addVariables
  try engine.variable.set(key: "title", value: "Summer Sale")
  try engine.variable.set(key: "subtitle", value: "Up to 50% off all items")
  try engine.variable.set(key: "cta", value: "Learn More")

  let variableNames = engine.variable.findAll()
  print("Template variables:", variableNames)
  // highlight-createTemplateFromScratch-addVariables

  // highlight-createTemplateFromScratch-addGraphic
  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setName(imageBlock, name: "hero-image")
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(imageBlock, value: 72)
  try engine.block.setPositionY(imageBlock, value: 300)
  try engine.block.setWidth(imageBlock, value: 656)
  try engine.block.setHeight(imageBlock, value: 500)
  try engine.block.setContentFillMode(imageBlock, mode: .cover)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.appendChild(to: page, child: imageBlock)
  // highlight-createTemplateFromScratch-addGraphic

  // highlight-createTemplateFromScratch-configurePlaceholder
  let placeholderFill = try engine.block.getFill(imageBlock)
  if try engine.block.supportsPlaceholderBehavior(placeholderFill) {
    try engine.block.setPlaceholderBehaviorEnabled(placeholderFill, enabled: true)
  }

  try engine.block.setPlaceholderEnabled(imageBlock, enabled: true)
  if try engine.block.supportsPlaceholderControls(imageBlock) {
    try engine.block.setPlaceholderControlsOverlayEnabled(imageBlock, enabled: true)
    try engine.block.setPlaceholderControlsButtonEnabled(imageBlock, enabled: true)
  }
  // highlight-createTemplateFromScratch-configurePlaceholder

  // highlight-createTemplateFromScratch-applyConstraints
  try engine.editor.setGlobalScope(key: "layer/move", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/resize", value: .defer)
  try engine.editor.setGlobalScope(key: "fill/change", value: .defer)

  for block in [headline, subtitle, cta, imageBlock] {
    try engine.block.setScopeEnabled(block, key: "layer/move", enabled: false)
    try engine.block.setScopeEnabled(block, key: "layer/resize", enabled: false)
  }
  try engine.block.setScopeEnabled(imageBlock, key: "fill/change", enabled: true)

  let imageCanMove = try engine.block.isAllowedByScope(imageBlock, key: "layer/move")
  let imageFillCanChange = try engine.block.isAllowedByScope(imageBlock, key: "fill/change")
  print("Image can move:", imageCanMove, "— fill can change:", imageFillCanChange)
  // highlight-createTemplateFromScratch-applyConstraints

  // Most-evolved scene — the finished promotional card, promoted to the guide's hero image.
  try await engine.captureGuide(page, label: "hero")

  // highlight-createTemplateFromScratch-saveTemplate
  try await engine.block.forceLoadResources([page])
  let templateString = try await engine.scene.saveToString()
  let templateArchive = try await engine.scene.saveToArchive()
  print("Template string characters:", templateString.count)
  print("Template archive bytes:", templateArchive.count)
  // highlight-createTemplateFromScratch-saveTemplate
}
