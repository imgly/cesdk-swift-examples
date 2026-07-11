import Foundation
import IMGLYEngine

/// Severity level derived from a moderation confidence score.
private enum ModerationState {
  case success
  case warning
  case failed
}

/// A content category returned by a moderation service.
private struct ModerationCategory: Sendable {
  let name: String
  let description: String
  let state: ModerationState
}

/// A graphic block with an image fill, ready to moderate.
private struct ModerationImageBlock: Sendable {
  let blockID: DesignBlockID
  let blockName: String
  let url: URL
}

/// A text block, ready to moderate.
private struct ModerationTextBlock: Sendable {
  let blockID: DesignBlockID
  let blockName: String
  let text: String
}

/// A moderation result tied to a specific design block.
private struct ModerationResult: Sendable {
  let id: String
  let blockID: DesignBlockID
  let blockName: String
  let category: ModerationCategory
  let content: String
}

// Caches keyed by content to avoid redundant moderation calls. In production,
// back these with a persistent store such as NSCache.
@MainActor private var imageModerationCache: [URL: [ModerationCategory]] = [:]
@MainActor private var textModerationCache: [String: [ModerationCategory]] = [:]

@MainActor
func moderateContent(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // Demo scaffolding: build a page with one image block and one text block so
  // there is content to moderate. In your app the scene already holds the
  // user's content.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1200)
  try engine.block.setHeight(page, value: 800)
  try engine.block.appendChild(to: scene, child: page)

  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.setPositionX(imageBlock, value: 100)
  try engine.block.setPositionY(imageBlock, value: 200)
  try engine.block.setWidth(imageBlock, value: 500)
  try engine.block.setHeight(imageBlock, value: 400)
  try engine.block.appendChild(to: page, child: imageBlock)

  let textBlock = try engine.block.create(.text)
  try engine.block.setString(textBlock, property: "text/text", value: "Sample text content for moderation testing")
  try engine.block.setFloat(textBlock, property: "text/fontSize", value: 48)
  try engine.block.setPositionX(textBlock, value: 650)
  try engine.block.setPositionY(textBlock, value: 340)
  try engine.block.setWidth(textBlock, value: 450)
  try engine.block.setHeight(textBlock, value: 120)
  try engine.block.appendChild(to: page, child: textBlock)

  // Find and moderate every image and text block.
  let imageResults = try await checkImageContent(engine: engine)
  let textResults = try await checkTextContent(engine: engine)
  let allResults = imageResults + textResults

  // Report the results, highlight the first violation, and gate export on them.
  displayResults(allResults)
  try selectFirstViolation(engine: engine, results: allResults)
  try await exportIfAllowed(engine: engine, page: page, results: allResults)
}

// highlight-moderateContent-getImageURL
/// Returns the image URL for a graphic block, or `nil` when the block's fill is
/// not an image fill. Filtering by fill type catches every image reliably,
/// regardless of the block's `kind`.
@MainActor
private func getImageURL(engine: Engine, blockID: DesignBlockID) -> URL? {
  guard let fill = try? engine.block.getFill(blockID),
        (try? engine.block.getType(fill)) == FillType.image.rawValue else {
    return nil
  }

  if let url = try? engine.block.getURL(fill, property: "fill/image/imageFileURI") {
    return url
  }

  if let sourceSet = try? engine.block.getSourceSet(fill, property: "fill/image/sourceSet"),
     let first = sourceSet.first {
    return first.uri
  }

  return nil
}

// highlight-moderateContent-getImageURL

// highlight-moderateContent-checkAllImages
/// Finds every graphic block with an image fill and moderates each one concurrently.
@MainActor
private func checkImageContent(engine: Engine) async throws -> [ModerationResult] {
  let graphicBlockIDs = try engine.block.find(byType: .graphic)
  let imageBlocks: [ModerationImageBlock] = try graphicBlockIDs.compactMap { blockID in
    guard let url = getImageURL(engine: engine, blockID: blockID) else { return nil }
    return ModerationImageBlock(
      blockID: blockID,
      blockName: try engine.block.getName(blockID),
      url: url,
    )
  }

  return try await withThrowingTaskGroup(of: [ModerationResult].self) { group in
    for block in imageBlocks {
      group.addTask {
        let categories = try await checkImageContentAPI(url: block.url)
        return categories.map { category in
          ModerationResult(
            id: "\(block.blockID)-\(category.name)",
            blockID: block.blockID,
            blockName: block.blockName,
            category: category,
            content: block.url.absoluteString,
          )
        }
      }
    }

    var results: [ModerationResult] = []
    for try await batch in group {
      results.append(contentsOf: batch)
    }
    return results
  }
}

// highlight-moderateContent-checkAllImages

// highlight-moderateContent-getTextContent
/// Extracts the text content from a text block.
@MainActor
private func getTextContent(engine: Engine, blockID: DesignBlockID) -> String {
  (try? engine.block.getString(blockID, property: "text/text")) ?? ""
}

// highlight-moderateContent-getTextContent

// highlight-moderateContent-checkAllText
/// Finds every text block, extracts its content, and moderates each one concurrently.
@MainActor
private func checkTextContent(engine: Engine) async throws -> [ModerationResult] {
  let textBlockIDs = try engine.block.find(byType: .text)
  let textBlocks: [ModerationTextBlock] = try textBlockIDs.compactMap { blockID in
    let text = getTextContent(engine: engine, blockID: blockID)
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return nil
    }
    return ModerationTextBlock(
      blockID: blockID,
      blockName: try engine.block.getName(blockID),
      text: text,
    )
  }

  return try await withThrowingTaskGroup(of: [ModerationResult].self) { group in
    for block in textBlocks {
      group.addTask {
        let categories = try await checkTextContentAPI(text: block.text)
        return categories.map { category in
          ModerationResult(
            id: "\(block.blockID)-\(category.name)",
            blockID: block.blockID,
            blockName: block.blockName,
            category: category,
            content: block.text,
          )
        }
      }
    }

    var results: [ModerationResult] = []
    for try await batch in group {
      results.append(contentsOf: batch)
    }
    return results
  }
}

// highlight-moderateContent-checkAllText

// highlight-moderateContent-imageModerationAPI
/// Simulates an image moderation API call. Replace this with a real request to
/// your moderation service, proxied through your backend.
@MainActor
private func checkImageContentAPI(url: URL) async throws -> [ModerationCategory] {
  if let cached = imageModerationCache[url] {
    return cached
  }

  // Simulate network latency before the service responds.
  try await Task.sleep(nanoseconds: 100_000_000)

  let categories = [
    ModerationCategory(
      name: "Weapons",
      description: "Handguns, rifles, machine guns, threatening knives",
      state: percentageToState(.random(in: 0.0 ... 0.3)),
    ),
    ModerationCategory(
      name: "Alcohol",
      description: "Wine, beer, cocktails, champagne",
      state: percentageToState(.random(in: 0.0 ... 0.4)),
    ),
    ModerationCategory(
      name: "Drugs",
      description: "Cannabis, syringes, glass pipes, bongs, pills",
      state: percentageToState(.random(in: 0.0 ... 0.2)),
    ),
    ModerationCategory(
      name: "Nudity",
      description: "Raw or partial nudity",
      state: percentageToState(.random(in: 0.0 ... 0.3)),
    ),
  ]

  imageModerationCache[url] = categories
  return categories
}

// highlight-moderateContent-imageModerationAPI

// highlight-moderateContent-textModerationAPI
/// Simulates a text moderation API call. Replace this with a real request to
/// your moderation service, proxied through your backend.
@MainActor
private func checkTextContentAPI(text: String) async throws -> [ModerationCategory] {
  if let cached = textModerationCache[text] {
    return cached
  }

  // Simulate network latency before the service responds.
  try await Task.sleep(nanoseconds: 100_000_000)

  let categories = [
    ModerationCategory(
      name: "Profanity",
      description: "Offensive or vulgar language",
      state: percentageToState(.random(in: 0.0 ... 0.3)),
    ),
    ModerationCategory(
      name: "Hate Speech",
      description: "Content promoting hatred or discrimination",
      state: percentageToState(.random(in: 0.0 ... 0.2)),
    ),
    ModerationCategory(
      name: "Threats",
      description: "Threatening or violent language",
      state: percentageToState(.random(in: 0.0 ... 0.1)),
    ),
  ]

  textModerationCache[text] = categories
  return categories
}

// highlight-moderateContent-textModerationAPI

// highlight-moderateContent-thresholdMapping
/// Maps a moderation confidence score to a severity level.
private func percentageToState(_ percentage: Double) -> ModerationState {
  if percentage > 0.8 {
    .failed
  } else if percentage > 0.4 {
    .warning
  } else {
    .success
  }
}

// highlight-moderateContent-thresholdMapping

// highlight-moderateContent-displayResults
/// Groups results by severity and prints a summary.
private func displayResults(_ results: [ModerationResult]) {
  let failed = results.filter { $0.category.state == .failed }
  let warnings = results.filter { $0.category.state == .warning }
  let passed = results.filter { $0.category.state == .success }

  print("Content moderation results:")
  print("- Total checks: \(results.count)")
  print("- Violations: \(failed.count)")
  print("- Warnings: \(warnings.count)")
  print("- Passed: \(passed.count)")

  for violation in failed {
    print("Violation — \(violation.category.name) in \(violation.blockName): \(violation.content)")
  }
}

// highlight-moderateContent-displayResults

// highlight-moderateContent-interactiveResults
/// Selects the block tied to the first violation so the user can locate it.
@MainActor
private func selectFirstViolation(engine: Engine, results: [ModerationResult]) throws {
  guard let violation = results.first(where: { $0.category.state == .failed }) else {
    return
  }

  for selected in engine.block.findAllSelected() {
    try engine.block.setSelected(selected, selected: false)
  }
  try engine.block.setSelected(violation.blockID, selected: true)
}

// highlight-moderateContent-interactiveResults

// highlight-moderateContent-exportValidation
/// Exports the page only when no moderation violations are present.
@MainActor
private func exportIfAllowed(engine: Engine, page: DesignBlockID, results: [ModerationResult]) async throws {
  let violations = results.filter { $0.category.state == .failed }
  guard violations.isEmpty else {
    print("Export blocked: \(violations.count) policy violation(s) detected.")
    return
  }

  let data = try await engine.block.export(page, mimeType: .png)
  print("Validation passed — exported \(data.count) bytes.")
}

// highlight-moderateContent-exportValidation
