import Foundation
import IMGLYEngine

struct VariableBindingsResult {
  let accentType: VariableType
  let cornerRadius: Float
  let colorVariables: [String]
  let textVariables: [String]
  let updatedCardColor: Color
  let cardFillBinding: String?
  let opacityBinding: String?
  let shapeBindings: [String]
  let boundWriteErrorCode: EngineErrorCode?
  let detachedCornerRadius: Float
  let boundCornerRadius: Float
  let renamedBinding: String?
  let renamedText: String
  let renameErrorCodes: [EngineErrorCode?]
  let typeMismatchErrorCode: EngineErrorCode?
  let bindingTypeErrorCode: EngineErrorCode?
}

@MainActor
func variableBindings(engine: Engine) async throws -> VariableBindingsResult {
  // Resolve sample assets (font, images) against the engine's configured base URL.
  let baseURL = try engine.guidesBaseURL

  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-variableBindings-createVariables
  // One variable per type. A setter creates the variable when the key is new.
  let roboto = Typeface(
    name: "Roboto",
    fonts: [
      Font(
        uri: baseURL.appendingPathComponent("ly.img.typeface/fonts/Roboto/Roboto-Regular.ttf"),
        subFamily: "Regular",
        weight: .normal,
        style: .normal,
      ),
    ],
  )
  try engine.variable.set(key: "accent", color: .rgba(r: 0.48, g: 0.23, b: 0.93, a: 1))
  try engine.variable.set(key: "cornerRadius", number: 40)
  try engine.variable.set(
    key: "heroImage",
    imageURL: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.variable.set(key: "headline", typeface: roboto)
  try engine.variable.set(key: "title", value: "Summer Sale")
  // highlight-variableBindings-createVariables

  // highlight-variableBindings-readTypes
  let accentType = try engine.variable.getType(key: "accent") // .color
  let cornerRadius = try engine.variable.getNumber(key: "cornerRadius") // 40
  let colorVariables = engine.variable.findAll(type: .color) // ["accent"]
  // findAll() lists text variables only
  let textVariables = engine.variable.findAll() // ["title"]
  print(accentType, cornerRadius, colorVariables, textVariables)
  // highlight-variableBindings-readTypes

  // highlight-variableBindings-createBlocks
  // A card with a color fill and a rect shape
  let card = try engine.block.create(.graphic)
  try engine.block.setShape(card, shape: engine.block.createShape(.rect))
  try engine.block.setFill(card, fill: engine.block.createFill(.color))
  try engine.block.setWidth(card, value: 720)
  try engine.block.setHeight(card, value: 520)
  try engine.block.setPositionX(card, value: 40)
  try engine.block.setPositionY(card, value: 40)
  try engine.block.appendChild(to: page, child: card)
  let cardFill = try engine.block.getFill(card)
  let cardShape = try engine.block.getShape(card)

  // An image with an image fill
  let image = try engine.block.create(.graphic)
  try engine.block.setShape(image, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setFill(image, fill: imageFill)
  try engine.block.setWidth(image, value: 640)
  try engine.block.setHeight(image, value: 300)
  try engine.block.setPositionX(image, value: 80)
  try engine.block.setPositionY(image, value: 80)
  try engine.block.appendChild(to: page, child: image)

  // A headline that shows the text variable
  let text = try engine.block.create(.text)
  try engine.block.replaceText(text, text: "{{title}}")
  try engine.block.setWidth(text, value: 640)
  try engine.block.setHeightMode(text, mode: .auto)
  try engine.block.setPositionX(text, value: 80)
  try engine.block.setPositionY(text, value: 420)
  try engine.block.appendChild(to: page, child: text)
  // highlight-variableBindings-createBlocks

  // highlight-variableBindings-bindProperties
  // Each binding applies the current value of the variable at once
  try engine.block.setVariableBinding(cardFill, property: "fill/color/value", key: "accent")
  for corner in ["TL", "TR", "BL", "BR"] {
    try engine.block.setVariableBinding(cardShape, property: "shape/rect/cornerRadius\(corner)", key: "cornerRadius")
  }
  try engine.block.setVariableBinding(imageFill, property: "fill/image/imageFileURI", key: "heroImage")
  try engine.block.setVariableBinding(text, property: "text/typeface", key: "headline")
  // highlight-variableBindings-bindProperties

  // highlight-variableBindings-updateVariables
  // Every bound property follows the new values
  try engine.variable.set(key: "accent", color: .rgba(r: 0.05, g: 0.55, b: 0.55, a: 1))
  try engine.variable.set(key: "cornerRadius", number: 24)
  try engine.variable.set(
    key: "heroImage",
    imageURL: baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg"),
  )
  let updatedCardColor: Color = try engine.block.getColor(cardFill, property: "fill/color/value")
  // highlight-variableBindings-updateVariables

  // highlight-variableBindings-readBindings
  let cardFillBinding = try engine.block.getVariableBinding(cardFill, property: "fill/color/value") // "accent"
  let opacityBinding = try engine.block.getVariableBinding(card, property: "opacity") // nil
  // The four corner radius properties of the shape
  let shapeBindings = try engine.block.findAllVariableBindings(cardShape)
  // highlight-variableBindings-readBindings

  // highlight-variableBindings-boundPropertyLocked
  // A bound property changes only through its variable
  var boundWriteErrorCode: EngineErrorCode?
  do {
    try engine.block.setColor(cardFill, property: "fill/color/value", color: .rgba(r: 1, g: 0, b: 0, a: 1))
  } catch let error as EngineError {
    boundWriteErrorCode = error.catalogCode // .blockPropertyBound
  }
  // highlight-variableBindings-boundPropertyLocked

  // highlight-variableBindings-removeBinding
  // The bottom corners keep their current radius and stop following
  try engine.block.removeVariableBinding(cardShape, property: "shape/rect/cornerRadiusBL")
  try engine.block.removeVariableBinding(cardShape, property: "shape/rect/cornerRadiusBR")
  try engine.variable.set(key: "cornerRadius", number: 60)
  let detachedCornerRadius = try engine.block.getFloat(cardShape, property: "shape/rect/cornerRadiusBL") // 24
  let boundCornerRadius = try engine.block.getFloat(cardShape, property: "shape/rect/cornerRadiusTL") // 60
  // highlight-variableBindings-removeBinding

  // highlight-variableBindings-rename
  // Bindings and {{tokens}} in text follow the new name
  try engine.variable.rename(key: "accent", to: "brand/accent")
  try engine.variable.rename(key: "title", to: "campaign/title")
  let renamedBinding = try engine.block.getVariableBinding(cardFill, property: "fill/color/value") // "brand/accent"
  let renamedText = try engine.block.getString(text, property: "text/text") // "{{campaign/title}}"
  // highlight-variableBindings-rename

  // highlight-variableBindings-renameErrors
  // .blockVariableNameInvalid for the first three names,
  // .blockVariableNameTaken for the name of another variable
  var renameErrorCodes: [EngineErrorCode?] = []
  for name in ["", " padded", "a{{b", "campaign/title"] {
    do {
      try engine.variable.rename(key: "brand/accent", to: name)
    } catch let error as EngineError {
      renameErrorCodes.append(error.catalogCode)
    }
  }
  // highlight-variableBindings-renameErrors

  // highlight-variableBindings-typeErrors
  var typeMismatchErrorCode: EngineErrorCode?
  do {
    // A color variable has no number value
    _ = try engine.variable.getNumber(key: "brand/accent")
  } catch let error as EngineError {
    typeMismatchErrorCode = error.catalogCode // .blockVariableTypeMismatch
  }
  var bindingTypeErrorCode: EngineErrorCode?
  do {
    // Opacity is a number property, so it cannot bind to a color variable
    try engine.block.setVariableBinding(card, property: "opacity", key: "brand/accent")
  } catch let error as EngineError {
    bindingTypeErrorCode = error.catalogCode // .blockVariableBindingUnsupported
  }
  // highlight-variableBindings-typeErrors

  // highlight-variableBindings-export
  let png = try await engine.block.export(page, mimeType: .png)
  print("Exported \(png.count) bytes")
  // highlight-variableBindings-export

  return VariableBindingsResult(
    accentType: accentType,
    cornerRadius: cornerRadius,
    colorVariables: colorVariables,
    textVariables: textVariables,
    updatedCardColor: updatedCardColor,
    cardFillBinding: cardFillBinding,
    opacityBinding: opacityBinding,
    shapeBindings: shapeBindings,
    boundWriteErrorCode: boundWriteErrorCode,
    detachedCornerRadius: detachedCornerRadius,
    boundCornerRadius: boundCornerRadius,
    renamedBinding: renamedBinding,
    renamedText: renamedText,
    renameErrorCodes: renameErrorCodes,
    typeMismatchErrorCode: typeMismatchErrorCode,
    bindingTypeErrorCode: bindingTypeErrorCode,
  )
}
