import Foundation
import IMGLYEngine

@MainActor
func enforceBrandGuidelines(engine: Engine) async throws {
  // Demo scaffolding: create the design scene and page that hosts the brand
  // template. In your app this is whatever scene the user is editing.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1200)
  try engine.block.setHeight(page, value: 800)
  try engine.block.appendChild(to: scene, child: page)
  let pageWidth = try engine.block.getWidth(page)
  let pageHeight = try engine.block.getHeight(page)
  // Demo scaffolding: a base URL for the example font files. Point the font
  // URLs below at your own brand font files instead.
  let fontBaseURL = try engine.guidesBaseURL

  // highlight-enforceBrand-restrictFonts
  try engine.asset.addLocalSource(sourceID: "ly.img.typeface")
  try engine.asset.addAsset(to: "ly.img.typeface", asset: AssetDefinition(
    id: "brand-sans",
    payload: AssetPayload(typeface: Typeface(name: "Brand Sans", fonts: [
      Font(
        uri: fontBaseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Regular.ttf"),
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
      Font(
        uri: fontBaseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Bold.ttf"),
        subFamily: "Bold",
        weight: .bold,
        style: .normal,
      ),
    ])),
    label: ["en": "Brand Sans"],
  ))
  // highlight-enforceBrand-restrictFonts

  // highlight-enforceBrand-globalScopeDefer
  try engine.editor.setGlobalScope(key: "layer/move", value: .defer)
  try engine.editor.setGlobalScope(key: "layer/resize", value: .defer)
  try engine.editor.setGlobalScope(key: "fill/change", value: .defer)
  try engine.editor.setGlobalScope(key: "fill/changeType", value: .defer)
  try engine.editor.setGlobalScope(key: "lifecycle/destroy", value: .defer)
  try engine.editor.setGlobalScope(key: "lifecycle/duplicate", value: .defer)
  try engine.editor.setGlobalScope(key: "text/edit", value: .defer)
  try engine.editor.setGlobalScope(key: "text/character", value: .defer)
  // highlight-enforceBrand-globalScopeDefer

  // highlight-enforceBrand-createLogo
  let logoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(logoBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(logoBlock, value: 200)
  try engine.block.setHeight(logoBlock, value: 80)
  try engine.block.setPositionX(logoBlock, value: 40)
  try engine.block.setPositionY(logoBlock, value: 40)

  let logoFill = try engine.block.createFill(.color)
  try engine.block.setColor(logoFill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.4, b: 0.8, a: 1.0))
  try engine.block.setFill(logoBlock, fill: logoFill)
  try engine.block.setName(logoBlock, name: "Company Logo")
  try engine.block.appendChild(to: page, child: logoBlock)
  // highlight-enforceBrand-createLogo

  // highlight-enforceBrand-lockLogo
  try engine.block.setScopeEnabled(logoBlock, key: "layer/move", enabled: false)
  try engine.block.setScopeEnabled(logoBlock, key: "layer/resize", enabled: false)
  try engine.block.setScopeEnabled(logoBlock, key: "fill/change", enabled: false)
  try engine.block.setScopeEnabled(logoBlock, key: "fill/changeType", enabled: false)
  try engine.block.setScopeEnabled(logoBlock, key: "lifecycle/destroy", enabled: false)
  try engine.block.setScopeEnabled(logoBlock, key: "lifecycle/duplicate", enabled: false)
  // highlight-enforceBrand-lockLogo

  // highlight-enforceBrand-createLegalText
  let legalText = try engine.block.create(.text)
  try engine.block.setWidth(legalText, value: pageWidth - 80)
  try engine.block.setHeight(legalText, value: 30)
  try engine.block.setPositionX(legalText, value: 40)
  try engine.block.setPositionY(legalText, value: pageHeight - 50)
  try engine.block.replaceText(legalText, text: "© 2024 Company Name. All rights reserved.")
  try engine.block.setFloat(legalText, property: "text/fontSize", value: 36)
  try engine.block.setName(legalText, name: "Legal Text")
  try engine.block.appendChild(to: page, child: legalText)

  try engine.block.setScopeEnabled(legalText, key: "layer/move", enabled: false)
  try engine.block.setScopeEnabled(legalText, key: "layer/resize", enabled: false)
  try engine.block.setScopeEnabled(legalText, key: "text/edit", enabled: false)
  try engine.block.setScopeEnabled(legalText, key: "text/character", enabled: false)
  try engine.block.setScopeEnabled(legalText, key: "lifecycle/destroy", enabled: false)
  try engine.block.setScopeEnabled(legalText, key: "lifecycle/duplicate", enabled: false)
  // highlight-enforceBrand-createLegalText

  // highlight-enforceBrand-createEditableContent
  let contentBlock = try engine.block.create(.graphic)
  try engine.block.setShape(contentBlock, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(contentBlock, value: 400)
  try engine.block.setHeight(contentBlock, value: 300)
  try engine.block.setPositionX(contentBlock, value: (pageWidth - 400) / 2)
  try engine.block.setPositionY(contentBlock, value: (pageHeight - 300) / 2)

  let contentFill = try engine.block.createFill(.color)
  try engine.block.setColor(contentFill, property: "fill/color/value", color: .rgba(r: 1.0, g: 0.6, b: 0.0, a: 1.0))
  try engine.block.setFill(contentBlock, fill: contentFill)
  try engine.block.setName(contentBlock, name: "Editable Content")
  try engine.block.appendChild(to: page, child: contentBlock)

  try engine.block.setScopeEnabled(contentBlock, key: "layer/move", enabled: true)
  try engine.block.setScopeEnabled(contentBlock, key: "layer/resize", enabled: true)
  try engine.block.setScopeEnabled(contentBlock, key: "fill/change", enabled: true)
  try engine.block.setScopeEnabled(contentBlock, key: "fill/changeType", enabled: true)
  try engine.block.setScopeEnabled(contentBlock, key: "lifecycle/destroy", enabled: true)
  try engine.block.setScopeEnabled(contentBlock, key: "lifecycle/duplicate", enabled: true)
  // highlight-enforceBrand-createEditableContent

  // highlight-enforceBrand-createEditableText
  let editableText = try engine.block.create(.text)
  try engine.block.setWidth(editableText, value: 300)
  try engine.block.setHeight(editableText, value: 60)
  try engine.block.setPositionX(editableText, value: (pageWidth - 300) / 2)
  try engine.block.setPositionY(editableText, value: 150)
  try engine.block.replaceText(editableText, text: "Edit This Headline")
  try engine.block.setFloat(editableText, property: "text/fontSize", value: 64)
  try engine.block.setEnum(editableText, property: "text/horizontalAlignment", value: "Center")
  try engine.block.setName(editableText, name: "Editable Headline")
  try engine.block.appendChild(to: page, child: editableText)

  try engine.block.setScopeEnabled(editableText, key: "layer/move", enabled: true)
  try engine.block.setScopeEnabled(editableText, key: "layer/resize", enabled: true)
  try engine.block.setScopeEnabled(editableText, key: "text/edit", enabled: true)
  try engine.block.setScopeEnabled(editableText, key: "text/character", enabled: true)
  try engine.block.setScopeEnabled(editableText, key: "lifecycle/destroy", enabled: true)
  // highlight-enforceBrand-createEditableText

  // highlight-enforceBrand-validateCompliance
  let canMoveLogo = try engine.block.isAllowedByScope(logoBlock, key: "layer/move")
  let canEditLegal = try engine.block.isAllowedByScope(legalText, key: "text/edit")
  let canEditContent = try engine.block.isAllowedByScope(contentBlock, key: "fill/change")

  print("Logo is locked:", !canMoveLogo) // true
  print("Legal text is locked:", !canEditLegal) // true
  print("Content block is editable:", canEditContent) // true
  // highlight-enforceBrand-validateCompliance

  // highlight-enforceBrand-export
  let blob = try await engine.block.export(page, mimeType: .png)
  let outputURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("enforce-brand-guidelines-result.png")
  try blob.write(to: outputURL)
  // highlight-enforceBrand-export
}
