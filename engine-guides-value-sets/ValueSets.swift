import Foundation
import IMGLYEngine

struct ValueSetsResult {
  let valueSets: [ValueSetID]
  let valueSetName: String
  let shownName: String
  let defaultName: String
  let shownAccent: Color
  let writtenName: String
  let defaultAfterWrite: String
  let cardColor: Color
  let activeSetKeepsID: Bool
  let foundSetKeepsID: Bool
  let cityAfterLoad: String
  let missingVariableErrorCode: EngineErrorCode?
  let nameTakenErrorCode: EngineErrorCode?
  let activeSetAfterDestroy: ValueSetID?
  let nameAfterDestroy: String
}

@MainActor
func valueSets(engine: Engine) async throws -> ValueSetsResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-valueSets-sceneVariables
  // Scene variables belong to the scene. A save writes them, and undo reverts them.
  try engine.variable.set(key: "first_name", value: "Ada")
  try engine.variable.set(key: "accent", color: .rgba(r: 0.48, g: 0.23, b: 0.93, a: 1))

  let card = try engine.block.create(.graphic)
  try engine.block.setShape(card, shape: engine.block.createShape(.rect))
  try engine.block.setFill(card, fill: engine.block.createFill(.color))
  try engine.block.setWidth(card, value: 720)
  try engine.block.setHeight(card, value: 520)
  try engine.block.setPositionX(card, value: 40)
  try engine.block.setPositionY(card, value: 40)
  try engine.block.appendChild(to: page, child: card)
  let cardFill = try engine.block.getFill(card)
  try engine.block.setVariableBinding(cardFill, property: "fill/color/value", key: "accent")

  let text = try engine.block.create(.text)
  try engine.block.replaceText(text, text: "Hello {{first_name}}")
  try engine.block.setWidth(text, value: 640)
  try engine.block.setHeightMode(text, mode: .auto)
  try engine.block.setPositionX(text, value: 80)
  try engine.block.setPositionY(text, value: 80)
  try engine.block.appendChild(to: page, child: text)
  // highlight-valueSets-sceneVariables

  // highlight-valueSets-createValueSet
  // A value set holds alternative values for some scene variables.
  let longNames = try engine.variable.createValueSet(name: "Long names")
  try engine.variable.set(key: "first_name", value: "Maximiliane Huber-Schwarzenberg", target: .valueSet(longNames))
  let valueSets = engine.variable.findAllValueSets() // [longNames]
  let valueSetName = try engine.variable.getValueSetName(longNames) // "Long names"
  // highlight-valueSets-createValueSet

  // highlight-valueSets-activateValueSet
  // The active set wins over the default values in text, bound properties and getters.
  try engine.variable.setActiveValueSet(longNames)
  let shownName = try engine.variable.get(key: "first_name") // "Maximiliane Huber-Schwarzenberg"
  let defaultName = try engine.variable.get(key: "first_name", target: .defaultValue) // "Ada"
  // A variable that the set has no value for shows its default.
  let shownAccent = try engine.variable.getColor(key: "accent") // the purple default
  // highlight-valueSets-activateValueSet

  // highlight-valueSets-writeThrough
  // A setter without a target writes the layer that the getter reads: the active set
  // when it holds the key, else the default value.
  try engine.variable.set(key: "first_name", value: "Maximiliane Huber")
  let writtenName = try engine.variable.get(key: "first_name") // "Maximiliane Huber"
  let defaultAfterWrite = try engine.variable.get(key: "first_name", target: .defaultValue) // "Ada"
  try engine.variable.set(key: "accent", color: .rgba(r: 0.95, g: 0.45, b: 0.1, a: 1))
  let cardColor: Color = try engine.block.getColor(cardFill, property: "fill/color/value") // the new orange default
  // highlight-valueSets-writeThrough

  // highlight-valueSets-export
  // Exports show the values of the active set, as the canvas does.
  let png = try await engine.block.export(page, mimeType: .png)
  print("Exported \(png.count) bytes")
  // highlight-valueSets-export

  // highlight-valueSets-saveAndLoad
  // A save holds the default values, the value sets and the active set.
  let saved = try await engine.scene.saveToString()
  try await engine.scene.load(from: saved)
  // The scene saves the ID of a set, so it stays the same across a load.
  let activeSetKeepsID = engine.variable.getActiveValueSet() == longNames // true
  let foundSetKeepsID = engine.variable.findValueSet(byName: "Long names") == longNames // true
  // highlight-valueSets-saveAndLoad

  // highlight-valueSets-beforeLoad
  // A variable set while no scene exists waits for the next scene. That scene takes it over
  // its own value, for example to fill a template with the data of one record.
  if let loadedScene = try engine.scene.get() {
    try engine.block.destroy(loadedScene)
  }
  try engine.variable.set(key: "city", value: "Berlin")
  try await engine.scene.load(from: saved)
  let cityAfterLoad = try engine.variable.get(key: "city") // "Berlin"
  // highlight-valueSets-beforeLoad

  // highlight-valueSets-errors
  var missingVariableErrorCode: EngineErrorCode?
  do {
    // A value set holds values only for variables of the scene.
    try engine.variable.set(key: "missing", value: "x", target: .valueSet(longNames))
  } catch let error as EngineError {
    missingVariableErrorCode = error.catalogCode // .blockVariableNotFound
  }
  var nameTakenErrorCode: EngineErrorCode?
  do {
    _ = try engine.variable.createValueSet(name: "Long names")
  } catch let error as EngineError {
    nameTakenErrorCode = error.catalogCode // .blockValueSetNameTaken
  }
  // highlight-valueSets-errors

  // highlight-valueSets-destroyValueSet
  // Destroying the active set shows the default values again.
  try engine.variable.destroyValueSet(longNames)
  let activeSetAfterDestroy = engine.variable.getActiveValueSet() // nil
  let nameAfterDestroy = try engine.variable.get(key: "first_name") // "Ada"
  // highlight-valueSets-destroyValueSet

  return ValueSetsResult(
    valueSets: valueSets,
    valueSetName: valueSetName,
    shownName: shownName,
    defaultName: defaultName,
    shownAccent: shownAccent,
    writtenName: writtenName,
    defaultAfterWrite: defaultAfterWrite,
    cardColor: cardColor,
    activeSetKeepsID: activeSetKeepsID,
    foundSetKeepsID: foundSetKeepsID,
    cityAfterLoad: cityAfterLoad,
    missingVariableErrorCode: missingVariableErrorCode,
    nameTakenErrorCode: nameTakenErrorCode,
    activeSetAfterDestroy: activeSetAfterDestroy,
    nameAfterDestroy: nameAfterDestroy,
  )
}
