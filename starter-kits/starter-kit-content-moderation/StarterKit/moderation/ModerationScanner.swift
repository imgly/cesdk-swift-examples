import Foundation
import IMGLYEngine

// MARK: - Moderation Scanner

/// Scans a scene for moderatable content and checks every piece of it against a
/// ``ModerationService``.
public enum ModerationScanner {
  /// Checks every image and text block in the scene for inappropriate content.
  ///
  /// Finds every graphic block with an image fill and every text block that carries
  /// text, then moderates each one concurrently. Blocks the service reports it
  /// cannot check — see ``ModerationService/canCheck(_:)`` — are reported as
  /// unchecked instead of being silently skipped.
  @MainActor
  public static func checkContent(
    engine: Engine,
    service: ModerationService,
  ) async throws -> ModerationScanOutcome {
    let blocks = try moderatableBlocks(engine: engine)

    // The service decides what it can reach: the default gateway service uploads
    // local files so they can be checked too, while a service that only fetches
    // remote URLs answers `false` for them. Anything it cannot check is reported
    // as unchecked rather than quietly treated as clean.
    // Asked once per block rather than once per filter: `canCheck` touches the file
    // system for local images.
    let checkable = Dictionary(grouping: blocks) { service.canCheck($0.content) }
    let checkableBlocks = checkable[true] ?? []
    let uncheckedBlocks = checkable[false] ?? []

    // Each block is checked independently: one failure must not discard the
    // verdicts for every other block in the design, which is what a throwing task
    // group would do. A block that fails is reported as unchecked, so it withholds
    // certification exactly like one the service could not reach.
    let checks = await withTaskGroup(of: BlockCheck.self) { group in
      for block in checkableBlocks {
        group.addTask {
          do {
            let results = try await service.check(block.content)
            // An empty result is not an all-clear. The service scored nothing, so this
            // block is unknown — and a service that returns `[]` to mean "nothing
            // detected" would otherwise certify every block it never looked at.
            guard !results.isEmpty else {
              return BlockCheck(
                block: block,
                results: [],
                failure: "The moderation service returned no categories for \(block.displayName).",
                authenticationFailed: false,
              )
            }
            return BlockCheck(block: block, results: results, failure: nil, authenticationFailed: false)
          } catch {
            return BlockCheck(
              block: block,
              results: [],
              failure: error.localizedDescription,
              // Preserved as a flag because the error itself cannot leave the task
              // group: per-block isolation reduces it to a string, and a rejected key
              // has to reach the host app so it can ask for a new one.
              authenticationFailed: (error as? ModerationServiceError)?.isAuthenticationFailure ?? false,
            )
          }
        }
      }

      var checks: [BlockCheck] = []
      for await check in group {
        checks.append(check)
      }
      return checks
    }

    let results = checks.flatMap { check in
      check.results.map { result in
        ModerationResult(
          id: "\(check.block.blockID)-\(result.name)",
          blockID: check.block.blockID,
          blockName: check.block.blockName,
          blockDisplayName: check.block.displayName,
          check: result,
        )
      }
    }
    let failedBlocks = checks.filter { $0.failure != nil }.map(\.block)
    let failures = checks.compactMap(\.failure)

    return ModerationScanOutcome(
      results: results,
      uncheckedBlocks: uncheckedBlocks + failedBlocks,
      failures: failures,
      authenticationFailed: checks.contains { $0.authenticationFailed },
    )
  }

  /// One block's check, successful or not. Carries the failure as a `String` rather
  /// than an `Error` so it can cross the task group's isolation boundary.
  private struct BlockCheck: Sendable {
    let block: ModerationBlock
    let results: [ModerationCheckResult]
    let failure: String?
    /// Whether this block failed because the service rejected the credentials.
    let authenticationFailed: Bool
  }

  /// A fingerprint of everything in the scene that gets moderated: which image and
  /// text blocks exist, which image each graphic shows, and what each text block
  /// says.
  ///
  /// Compared against the fingerprint recorded at validation time to detect whether
  /// the design changed in a way that invalidates the last result. Edits that
  /// moderation cannot see — position, styling, colour — deliberately do not
  /// invalidate it.
  @MainActor
  public static func contentFingerprint(engine: Engine) -> Set<String> {
    let blocks = (try? moderatableBlocks(engine: engine)) ?? []
    return Set(blocks.map { block in
      switch block.content {
      case let .image(url):
        "\(block.blockID)|image|\(url.absoluteString)"
      case let .text(text):
        // The text itself, not just the block's existence: editing a caption after a
        // clean run has to invalidate that run, or the edited words ride out on a
        // verdict that never saw them.
        "\(block.blockID)|text|\(text)"
      }
    })
  }

  /// Every block in the scene whose content can be moderated: graphics with an image
  /// fill, and text blocks that actually carry text.
  @MainActor
  public static func moderatableBlocks(engine: Engine) throws -> [ModerationBlock] {
    try imageBlocks(engine: engine) + textBlocks(engine: engine)
  }

  /// Every graphic block in the scene that carries an image fill.
  @MainActor
  public static func imageBlocks(engine: Engine) throws -> [ModerationBlock] {
    try engine.block.find(byType: .graphic).compactMap { blockID in
      guard let url = imageURL(engine: engine, blockID: blockID) else { return nil }
      return ModerationBlock(
        blockID: blockID,
        blockName: blockName(engine: engine, blockID: blockID),
        content: .image(url),
      )
    }
  }

  /// Every text block in the scene that carries non-empty text.
  ///
  /// Blank blocks are skipped rather than sent: they cannot violate a policy, and
  /// each one would otherwise cost provider operations to be told so.
  @MainActor
  public static func textBlocks(engine: Engine) throws -> [ModerationBlock] {
    try engine.block.find(byType: .text).compactMap { blockID in
      let text = (try? engine.block.getString(blockID, property: "text/text")) ?? ""
      guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
      return ModerationBlock(
        blockID: blockID,
        blockName: blockName(engine: engine, blockID: blockID),
        content: .text(text),
      )
    }
  }

  /// Selects the given block so the user can locate it on the canvas.
  @MainActor
  public static func selectBlock(engine: Engine, blockID: DesignBlockID) throws {
    guard engine.block.isValid(blockID),
          try engine.block.isAllowedByScope(blockID, key: "editor/select") else {
      return
    }
    for selected in engine.block.findAllSelected() {
      try engine.block.setSelected(selected, selected: false)
    }
    try engine.block.setSelected(blockID, selected: true)
  }

  // MARK: - Private

  /// Returns the image URL for a graphic block, or `nil` when the block's fill
  /// is not an image fill. Filtering by fill type catches every image reliably,
  /// regardless of the block's `kind`.
  @MainActor
  private static func imageURL(engine: Engine, blockID: DesignBlockID) -> URL? {
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

  /// Returns the block's name, or an empty string when it has none.
  ///
  /// The fallback label belongs to ``ModerationBlock/displayName``, which knows whether
  /// the block holds an image or text and can name it accordingly.
  @MainActor
  private static func blockName(engine: Engine, blockID: DesignBlockID) -> String {
    (try? engine.block.getName(blockID)) ?? ""
  }
}
