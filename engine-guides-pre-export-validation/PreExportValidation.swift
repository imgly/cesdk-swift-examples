import Foundation
import IMGLYEngine

// highlight-types
struct BoundingBox {
  let minX: Float
  let minY: Float
  let maxX: Float
  let maxY: Float
}

enum ValidationSeverity {
  case error
  case warning
}

struct ValidationIssue {
  enum Kind {
    case outsidePage
    case protruding
    case textObscured
    case unfilledPlaceholder
  }

  let kind: Kind
  let severity: ValidationSeverity
  let blockID: DesignBlockID
  let blockName: String
  let message: String
}

struct ValidationResult {
  let errors: [ValidationIssue]
  let warnings: [ValidationIssue]
}

// Display name with a kind-based fallback used in issue messages.
@MainActor
private func displayName(engine: Engine, _ blockID: DesignBlockID) throws -> String {
  let name = try engine.block.getName(blockID)
  if !name.isEmpty { return name }
  let kind = try engine.block.getKind(blockID)
  return kind.prefix(1).uppercased() + kind.dropFirst()
}

// highlight-types

// highlight-getBoundingBox
@MainActor
private func boundingBox(engine: Engine, _ blockID: DesignBlockID) throws -> BoundingBox {
  let x = try engine.block.getGlobalBoundingBoxX(blockID)
  let y = try engine.block.getGlobalBoundingBoxY(blockID)
  let width = try engine.block.getGlobalBoundingBoxWidth(blockID)
  let height = try engine.block.getGlobalBoundingBoxHeight(blockID)
  return BoundingBox(minX: x, minY: y, maxX: x + width, maxY: y + height)
}

// Returns the fraction of `box1` that intersects `box2` (0 = none, 1 = fully inside).
private func overlapRatio(_ box1: BoundingBox, _ box2: BoundingBox) -> Float {
  let intersectWidth = max(0, min(box1.maxX, box2.maxX) - max(box1.minX, box2.minX))
  let intersectHeight = max(0, min(box1.maxY, box2.maxY) - max(box1.minY, box2.minY))
  let box1Area = (box1.maxX - box1.minX) * (box1.maxY - box1.minY)
  return box1Area == 0 ? 0 : (intersectWidth * intersectHeight) / box1Area
}

// highlight-getBoundingBox

// highlight-findOutsideBlocks
@MainActor
private func findOutsideBlocks(engine: Engine, page: DesignBlockID) throws -> [ValidationIssue] {
  var issues: [ValidationIssue] = []
  let pageBounds = try boundingBox(engine: engine, page)
  let candidates = try engine.block.find(byType: .text) + engine.block.find(byType: .graphic)
  for blockID in candidates where engine.block.isValid(blockID) {
    let blockBounds = try boundingBox(engine: engine, blockID)
    if overlapRatio(blockBounds, pageBounds) == 0 {
      issues.append(ValidationIssue(
        kind: .outsidePage,
        severity: .error,
        blockID: blockID,
        blockName: try displayName(engine: engine, blockID),
        message: "Element is completely outside the visible page area",
      ))
    }
  }
  return issues
}

// highlight-findOutsideBlocks

// highlight-findProtrudingBlocks
@MainActor
private func findProtrudingBlocks(engine: Engine, page: DesignBlockID) throws -> [ValidationIssue] {
  var issues: [ValidationIssue] = []
  let pageBounds = try boundingBox(engine: engine, page)
  let candidates = try engine.block.find(byType: .text) + engine.block.find(byType: .graphic)
  for blockID in candidates where engine.block.isValid(blockID) {
    let blockBounds = try boundingBox(engine: engine, blockID)
    let overlap = overlapRatio(blockBounds, pageBounds)
    // Partially inside (> 0) but not fully inside (< 1).
    if overlap > 0, overlap < 0.99 {
      issues.append(ValidationIssue(
        kind: .protruding,
        severity: .warning,
        blockID: blockID,
        blockName: try displayName(engine: engine, blockID),
        message: "Element extends beyond page boundaries",
      ))
    }
  }
  return issues
}

// highlight-findProtrudingBlocks

// highlight-findObscuredText
@MainActor
private func findObscuredText(engine: Engine, page: DesignBlockID) throws -> [ValidationIssue] {
  var issues: [ValidationIssue] = []
  let children = try engine.block.getChildren(page)
  let textBlocks = try engine.block.find(byType: .text)

  for textID in textBlocks where engine.block.isValid(textID) {
    guard let textIndex = children.firstIndex(of: textID) else { continue }
    // Children later in the array are rendered on top.
    let blocksAbove = children[(textIndex + 1)...]
    let textBounds = try boundingBox(engine: engine, textID)

    for aboveID in blocksAbove {
      // Skip text-on-text overlaps — text backgrounds are typically transparent.
      if try engine.block.getType(aboveID) == DesignBlockType.text.rawValue { continue }
      if try overlapRatio(textBounds, boundingBox(engine: engine, aboveID)) > 0 {
        issues.append(ValidationIssue(
          kind: .textObscured,
          severity: .warning,
          blockID: textID,
          blockName: try displayName(engine: engine, textID),
          message: "Text may be partially hidden by overlapping elements",
        ))
        break
      }
    }
  }
  return issues
}

// highlight-findObscuredText

// highlight-findUnfilledPlaceholders
@MainActor
private func findUnfilledPlaceholders(engine: Engine) throws -> [ValidationIssue] {
  var issues: [ValidationIssue] = []
  for blockID in engine.block.findAllPlaceholders() where engine.block.isValid(blockID) {
    if try !isPlaceholderFilled(engine: engine, blockID) {
      issues.append(ValidationIssue(
        kind: .unfilledPlaceholder,
        severity: .error,
        blockID: blockID,
        blockName: try displayName(engine: engine, blockID),
        message: "Placeholder has not been filled with content",
      ))
    }
  }
  return issues
}

@MainActor
private func isPlaceholderFilled(engine: Engine, _ blockID: DesignBlockID) throws -> Bool {
  let fillID = try engine.block.getFill(blockID)
  guard engine.block.isValid(fillID) else { return false }

  // Empty `fill/image/imageFileURI` means the image placeholder has not been filled.
  if try engine.block.getType(fillID) == FillType.image.rawValue {
    let uri = try engine.block.getString(fillID, property: "fill/image/imageFileURI")
    return !uri.isEmpty
  }
  // Other fill types are treated as filled.
  return true
}

// highlight-findUnfilledPlaceholders

@MainActor
func preExportValidation(engine: Engine) async throws {
  // The block below builds a demo scene that triggers every validation check.
  // It is not part of the guide content — readers integrate the helpers above
  // into their own scenes and export pipelines.
  let scene = try engine.scene.create()
  let pageID = try engine.block.create(.page)
  try engine.block.setWidth(pageID, value: 800)
  try engine.block.setHeight(pageID, value: 600)
  try engine.block.appendChild(to: scene, child: pageID)
  try addValidationDemoBlocks(engine: engine, page: pageID)

  // highlight-validateDesign
  let allIssues = try findOutsideBlocks(engine: engine, page: pageID)
    + findProtrudingBlocks(engine: engine, page: pageID)
    + findObscuredText(engine: engine, page: pageID)
    + findUnfilledPlaceholders(engine: engine)
  let result = ValidationResult(
    errors: allIssues.filter { $0.severity == .error },
    warnings: allIssues.filter { $0.severity == .warning },
  )

  if let firstError = result.errors.first, engine.block.isValid(firstError.blockID) {
    // Select the first error block to help the user locate the issue.
    try engine.block.select(firstError.blockID)
  }
  // highlight-validateDesign

  // Suppress unused-variable warning for the demo summary.
  _ = result.warnings
}

// MARK: - Demo scene scaffolding (not part of the guide)

@MainActor
private func addValidationDemoBlocks(engine: Engine, page: DesignBlockID) throws {
  try addOutsideImage(engine: engine, page: page)
  try addProtrudingImage(engine: engine, page: page)
  try addObscuredTextWithOverlap(engine: engine, page: page)
  try addUnfilledPlaceholder(engine: engine, page: page)
}

@MainActor
private func addOutsideImage(engine: Engine, page: DesignBlockID) throws {
  let block = try engine.block.create(.graphic)
  try engine.block.setName(block, name: "Outside Image")
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let fill = try engine.block.createFill(.image)
  try engine.block.setString(
    fill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg",
  )
  try engine.block.setFill(block, fill: fill)
  try engine.block.setWidth(block, value: 150)
  try engine.block.setHeight(block, value: 100)
  try engine.block.setPositionX(block, value: -200)
  try engine.block.setPositionY(block, value: 100)
  try engine.block.appendChild(to: page, child: block)
}

@MainActor
private func addProtrudingImage(engine: Engine, page: DesignBlockID) throws {
  let block = try engine.block.create(.graphic)
  try engine.block.setName(block, name: "Protruding Image")
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let fill = try engine.block.createFill(.image)
  try engine.block.setString(
    fill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_2.jpg",
  )
  try engine.block.setFill(block, fill: fill)
  try engine.block.setWidth(block, value: 150)
  try engine.block.setHeight(block, value: 100)
  try engine.block.setPositionX(block, value: 725)
  try engine.block.setPositionY(block, value: 100)
  try engine.block.appendChild(to: page, child: block)
}

@MainActor
private func addObscuredTextWithOverlap(engine: Engine, page: DesignBlockID) throws {
  let text = try engine.block.create(.text)
  try engine.block.setName(text, name: "Obscured Text")
  try engine.block.setPositionX(text, value: 200)
  try engine.block.setPositionY(text, value: 250)
  try engine.block.setWidth(text, value: 200)
  try engine.block.setHeight(text, value: 100)
  try engine.block.replaceText(text, text: "Hidden")
  try engine.block.appendChild(to: page, child: text)

  // Overlapping shape rendered above the text (later in stacking order).
  let shape = try engine.block.create(.graphic)
  try engine.block.setName(shape, name: "Overlapping Shape")
  try engine.block.setShape(shape, shape: engine.block.createShape(.rect))
  try engine.block.setFill(shape, fill: engine.block.createFill(.color))
  try engine.block.setPositionX(shape, value: 200)
  try engine.block.setPositionY(shape, value: 250)
  try engine.block.setWidth(shape, value: 200)
  try engine.block.setHeight(shape, value: 100)
  try engine.block.appendChild(to: page, child: shape)
}

@MainActor
private func addUnfilledPlaceholder(engine: Engine, page: DesignBlockID) throws {
  let block = try engine.block.create(.graphic)
  try engine.block.setName(block, name: "Unfilled Placeholder")
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  let fill = try engine.block.createFill(.image)
  try engine.block.setFill(block, fill: fill)
  try engine.block.setWidth(block, value: 150)
  try engine.block.setHeight(block, value: 100)
  try engine.block.setPositionX(block, value: 50)
  try engine.block.setPositionY(block, value: 400)
  try engine.block.appendChild(to: page, child: block)
  try engine.block.setScopeEnabled(block, key: "fill/change", enabled: true)
  try engine.block.setPlaceholderBehaviorEnabled(fill, enabled: true)
  try engine.block.setPlaceholderEnabled(block, enabled: true)
}
