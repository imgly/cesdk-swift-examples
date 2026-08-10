import Foundation
import IMGLYEngine

struct DesignGenerationGuideResult {
  let pngData: Data
  let outputURL: URL
  let referencedVariableNames: [String]
  let variableValuesAfterSet: [String: String]
  let imageBlockCount: Int
  let imageFillType: String
  let replacementImageURL: URL
  let storedImageURL: URL
}

@MainActor
func designGeneration(engine: Engine) async throws -> DesignGenerationGuideResult {
  let baseURL = try engine.guidesBaseURL
  let templateURL = try await makeDesignGenerationGuideTemplate(engine: engine, baseURL: baseURL)
  defer { try? FileManager.default.removeItem(at: templateURL) }

  // highlight-designGeneration-load
  @MainActor
  func loadDesignGenerationTemplate(engine: Engine, from templateURL: URL) async throws -> [DesignBlockID] {
    try await engine.scene.load(
      from: templateURL,
      overrideEditorConfig: true,
      waitForResources: true,
    )
    return try engine.scene.getPages()
  }
  // highlight-designGeneration-load

  // highlight-designGeneration-validate
  struct DesignGenerationGuideRecord {
    let firstName: String
    let lastName: String
    let address: String
    let city: String
    let imageURL: URL
  }

  struct ValidatedDesignGenerationGuideTemplate {
    let page: DesignBlockID
    let record: DesignGenerationGuideRecord
    let referencedVariableNames: [String]
    let imageBlock: DesignBlockID
    let imageFill: DesignBlockID
    let imageBlockCount: Int
    let imageFillType: String
  }

  enum DesignGenerationGuideError: LocalizedError {
    case expectedSinglePage(Int)
    case missingVariables([String])
    case missingVariableReferences
    case namedImageCount(name: String, count: Int)
    case unexpectedFillType(String)

    var errorDescription: String? {
      switch self {
      case let .expectedSinglePage(count):
        "Expected the template to contain one page, found \(count)."
      case let .missingVariables(keys):
        "Template is missing required variables: \(keys.joined(separator: ", "))."
      case .missingVariableReferences:
        "Template text blocks do not reference any variables."
      case let .namedImageCount(name, count):
        "Expected one image block named \(name), found \(count)."
      case let .unexpectedFillType(type):
        "Expected the named image block to use an image fill, found \(type)."
      }
    }
  }

  @MainActor
  func validateDesignGenerationTemplate(
    engine: Engine,
    pages: [DesignBlockID],
    baseURL: URL,
  ) throws -> ValidatedDesignGenerationGuideTemplate {
    guard pages.count == 1, let page = pages.first else {
      throw DesignGenerationGuideError.expectedSinglePage(pages.count)
    }

    let record = DesignGenerationGuideRecord(
      firstName: "John",
      lastName: "Doe",
      address: "123 Main St.",
      city: "Anytown",
      imageURL: baseURL.appendingPathComponent("ly.img.image/images/sample_2.jpg"),
    )
    let requiredVariableKeys = Set(["first_name", "last_name", "address", "city"])
    let textBlocks = try engine.block.find(byType: .text)
    let hasVariableReferences = try textBlocks.contains {
      try engine.block.referencesAnyVariables($0)
    }
    guard hasVariableReferences else {
      throw DesignGenerationGuideError.missingVariableReferences
    }
    let variableTokenPattern = try NSRegularExpression(pattern: #"\{\{\s*([^{}]+?)\s*\}\}"#)
    let referencedVariableNames = Set(try textBlocks.flatMap { block -> [String] in
      let content = try engine.block.getString(block, property: "text/text")
      let range = NSRange(content.startIndex ..< content.endIndex, in: content)
      return variableTokenPattern.matches(in: content, range: range).compactMap { match in
        Range(match.range(at: 1), in: content).map {
          String(content[$0]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }
    })
    let missingVariableKeys = requiredVariableKeys.subtracting(referencedVariableNames).sorted()
    guard missingVariableKeys.isEmpty else {
      throw DesignGenerationGuideError.missingVariables(missingVariableKeys)
    }

    let imageBlockName = "profile-photo"
    let namedBlocks = engine.block.find(byName: imageBlockName)
    guard namedBlocks.count == 1, let namedBlock = namedBlocks.first else {
      throw DesignGenerationGuideError.namedImageCount(name: imageBlockName, count: namedBlocks.count)
    }

    let fill = try engine.block.getFill(namedBlock)
    let fillType = try engine.block.getType(fill)
    guard fillType == FillType.image.rawValue else {
      throw DesignGenerationGuideError.unexpectedFillType(fillType)
    }

    return ValidatedDesignGenerationGuideTemplate(
      page: page,
      record: record,
      referencedVariableNames: referencedVariableNames.sorted(),
      imageBlock: namedBlock,
      imageFill: fill,
      imageBlockCount: namedBlocks.count,
      imageFillType: fillType,
    )
  }
  // highlight-designGeneration-validate

  // highlight-designGeneration-populateText
  @MainActor
  func populateDesignGenerationText(engine: Engine, record: DesignGenerationGuideRecord) throws {
    try engine.variable.set(key: "first_name", value: record.firstName)
    try engine.variable.set(key: "last_name", value: record.lastName)
    try engine.variable.set(key: "address", value: record.address)
    try engine.variable.set(key: "city", value: record.city)
  }
  // highlight-designGeneration-populateText

  // highlight-designGeneration-replaceImage
  @MainActor
  func replaceDesignGenerationImage(
    engine: Engine,
    imageBlock: DesignBlockID,
    imageFill: DesignBlockID,
    imageURL: URL,
  ) throws -> URL {
    try engine.block.setURL(
      imageFill,
      property: "fill/image/imageFileURI",
      value: imageURL,
    )
    try engine.block.resetCrop(imageBlock)
    return try engine.block.getURL(imageFill, property: "fill/image/imageFileURI")
  }
  // highlight-designGeneration-replaceImage

  // highlight-designGeneration-export
  @MainActor
  func exportDesignGenerationPage(engine: Engine, page: DesignBlockID) async throws -> (Data, URL) {
    try await engine.block.forceLoadResources([page])
    let pngData = try await engine.block.export(page, mimeType: .png)
    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("personalized-design-\(UUID().uuidString).png")
    try pngData.write(to: outputURL, options: .atomic)
    return (pngData, outputURL)
  }
  // highlight-designGeneration-export

  let pages = try await loadDesignGenerationTemplate(engine: engine, from: templateURL)
  let validatedTemplate = try validateDesignGenerationTemplate(engine: engine, pages: pages, baseURL: baseURL)
  try populateDesignGenerationText(engine: engine, record: validatedTemplate.record)
  let storedImageURL = try replaceDesignGenerationImage(
    engine: engine,
    imageBlock: validatedTemplate.imageBlock,
    imageFill: validatedTemplate.imageFill,
    imageURL: validatedTemplate.record.imageURL,
  )
  let (pngData, outputURL) = try await exportDesignGenerationPage(engine: engine, page: validatedTemplate.page)

  try await engine.captureGuide(data: pngData, label: "hero", mimeType: .png)

  let variableValuesAfterSet = [
    "first_name": try engine.variable.get(key: "first_name"),
    "last_name": try engine.variable.get(key: "last_name"),
    "address": try engine.variable.get(key: "address"),
    "city": try engine.variable.get(key: "city"),
  ]

  return DesignGenerationGuideResult(
    pngData: pngData,
    outputURL: outputURL,
    referencedVariableNames: validatedTemplate.referencedVariableNames,
    variableValuesAfterSet: variableValuesAfterSet,
    imageBlockCount: validatedTemplate.imageBlockCount,
    imageFillType: validatedTemplate.imageFillType,
    replacementImageURL: validatedTemplate.record.imageURL,
    storedImageURL: storedImageURL,
  )
}

@MainActor
private func makeDesignGenerationGuideTemplate(engine: Engine, baseURL: URL) async throws -> URL {
  let scene = try engine.scene.create(designUnit: .px, fontSizeUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1200)
  try engine.block.setHeight(page, value: 800)
  try engine.block.appendChild(to: scene, child: page)

  let pageFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    pageFill,
    property: "fill/color/value",
    color: .rgba(r: 0.96, g: 0.97, b: 0.98, a: 1),
  )
  try engine.block.setFill(page, fill: pageFill)

  let accent = try engine.block.create(.graphic)
  try engine.block.setShape(accent, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(accent, value: 0)
  try engine.block.setPositionY(accent, value: 0)
  try engine.block.setWidth(accent, value: 18)
  try engine.block.setHeight(accent, value: 800)
  let accentFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    accentFill,
    property: "fill/color/value",
    color: .rgba(r: 0.04, g: 0.49, b: 0.47, a: 1),
  )
  try engine.block.setFill(accent, fill: accentFill)
  try engine.block.appendChild(to: page, child: accent)

  let eyebrow = try engine.block.create(.text)
  try engine.block.replaceText(eyebrow, text: "PERSONALIZED DELIVERY")
  try engine.block.setPositionX(eyebrow, value: 80)
  try engine.block.setPositionY(eyebrow, value: 92)
  try engine.block.setWidth(eyebrow, value: 500)
  try engine.block.setHeightMode(eyebrow, mode: .auto)
  try engine.block.setTextFontSize(eyebrow, fontSize: 22)
  try engine.block.setTextColor(eyebrow, color: .rgba(r: 0.04, g: 0.49, b: 0.47, a: 1))
  try engine.block.appendChild(to: page, child: eyebrow)

  let recipient = try engine.block.create(.text)
  try engine.block.replaceText(recipient, text: "{{first_name}}\n{{last_name}}")
  try engine.block.setPositionX(recipient, value: 80)
  try engine.block.setPositionY(recipient, value: 152)
  try engine.block.setWidth(recipient, value: 500)
  try engine.block.setHeightMode(recipient, mode: .auto)
  try engine.block.setTextFontSize(recipient, fontSize: 80)
  try engine.block.setTextColor(recipient, color: .rgba(r: 0.08, g: 0.11, b: 0.18, a: 1))
  try engine.block.appendChild(to: page, child: recipient)

  let addressLabel = try engine.block.create(.text)
  try engine.block.replaceText(addressLabel, text: "SEND TO")
  try engine.block.setPositionX(addressLabel, value: 80)
  try engine.block.setPositionY(addressLabel, value: 500)
  try engine.block.setWidth(addressLabel, value: 500)
  try engine.block.setHeightMode(addressLabel, mode: .auto)
  try engine.block.setTextFontSize(addressLabel, fontSize: 18)
  try engine.block.setTextColor(addressLabel, color: .rgba(r: 0.42, g: 0.45, b: 0.51, a: 1))
  try engine.block.appendChild(to: page, child: addressLabel)

  let address = try engine.block.create(.text)
  try engine.block.replaceText(address, text: "{{address}}\n{{city}}")
  try engine.block.setPositionX(address, value: 80)
  try engine.block.setPositionY(address, value: 548)
  try engine.block.setWidth(address, value: 500)
  try engine.block.setHeightMode(address, mode: .auto)
  try engine.block.setTextFontSize(address, fontSize: 32)
  try engine.block.setTextColor(address, color: .rgba(r: 0.08, g: 0.11, b: 0.18, a: 1))
  try engine.block.appendChild(to: page, child: address)

  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setName(imageBlock, name: "profile-photo")
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(imageBlock, value: 650)
  try engine.block.setPositionY(imageBlock, value: 72)
  try engine.block.setWidth(imageBlock, value: 470)
  try engine.block.setHeight(imageBlock, value: 656)
  try engine.block.setContentFillMode(imageBlock, mode: .cover)
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.appendChild(to: page, child: imageBlock)

  try engine.variable.set(key: "first_name", value: "First")
  try engine.variable.set(key: "last_name", value: "Last")
  try engine.variable.set(key: "address", value: "Address")
  try engine.variable.set(key: "city", value: "City")
  try await engine.block.forceLoadResources([page])

  let templateString = try await engine.scene.saveToString()
  let templateData = Data(templateString.utf8)
  let templateURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("design-generation-template-\(UUID().uuidString).imgly")
  try templateData.write(to: templateURL, options: .atomic)

  // Ensure the following load, rather than this fixture setup, restores the serialized variables.
  let fixtureVariableKeys = Set(["first_name", "last_name", "address", "city"])
  for key in fixtureVariableKeys where engine.variable.findAll().contains(key) {
    try engine.variable.remove(key: key)
  }
  return templateURL
}
