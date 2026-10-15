import Foundation
import IMGLYEngine

// MARK: - Moderation Types

/// Severity level derived from a moderation confidence score.
public enum ModerationState: Int, Sendable, Comparable {
  case success = 0
  case warning = 1
  case failed = 2

  public static func < (lhs: ModerationState, rhs: ModerationState) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

/// A content category check returned by a moderation service.
public struct ModerationCheckResult: Sendable, Hashable {
  /// The category name, e.g. "Weapons".
  public let name: String
  /// A short description of what the category covers.
  public let description: String
  /// The severity derived from the service's confidence score.
  public let state: ModerationState

  public init(name: String, description: String, state: ModerationState) {
    self.name = name
    self.description = description
    self.state = state
  }
}

/// A piece of content a moderation service can check.
public enum ModerationContent: Sendable, Hashable {
  /// An image, identified by URL. Remote unless the service accepts local files.
  case image(URL)
  /// The text of a text block.
  case text(String)
}

/// A block whose content can be moderated: a graphic with an image fill, or a
/// text block.
public struct ModerationBlock: Sendable, Hashable {
  public let blockID: DesignBlockID
  public let blockName: String
  public let content: ModerationContent

  public init(blockID: DesignBlockID, blockName: String, content: ModerationContent) {
    self.blockID = blockID
    self.blockName = blockName
    self.content = content
  }

  /// A short label for the block in the results panel. Text blocks show an excerpt
  /// of their own content, because "Text" alone does not identify which one. An image
  /// the user never named falls back to "Image" rather than to the engine's generic
  /// "Block", which says nothing about what the finding is attached to.
  public var displayName: String {
    switch content {
    case .image:
      blockName.isEmpty ? "Image" : blockName
    case let .text(text):
      Self.excerpt(of: text)
    }
  }

  /// First line, trimmed, capped at 40 characters.
  private static func excerpt(of text: String) -> String {
    let firstLine = text
      .split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
      .first
      .map(String.init) ?? text
    let trimmed = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.count <= 40 ? trimmed : String(trimmed.prefix(39)) + "…"
  }
}

/// A moderation check result tied to a specific design block.
public struct ModerationResult: Sendable, Hashable, Identifiable {
  public let id: String
  public let blockID: DesignBlockID
  public let blockName: String
  /// The label the panel shows for the block this result belongs to.
  public let blockDisplayName: String
  public let check: ModerationCheckResult

  public init(
    id: String,
    blockID: DesignBlockID,
    blockName: String,
    blockDisplayName: String,
    check: ModerationCheckResult,
  ) {
    self.id = id
    self.blockID = blockID
    self.blockName = blockName
    self.blockDisplayName = blockDisplayName
    self.check = check
  }

  /// Convenience accessor for the check's severity.
  public var state: ModerationState {
    check.state
  }
}

/// Every finding for one block, as the results panel presents them.
public struct ModerationBlockFindings: Sendable, Hashable, Identifiable {
  public let blockID: DesignBlockID
  public let displayName: String
  public let results: [ModerationResult]

  public init(blockID: DesignBlockID, displayName: String, results: [ModerationResult]) {
    self.blockID = blockID
    self.displayName = displayName
    self.results = results
  }

  public var id: DesignBlockID {
    blockID
  }

  /// The most severe finding on this block, which orders it against the others.
  public var severity: ModerationState {
    results.map(\.state).max() ?? .success
  }
}

/// The outcome of scanning a scene: per-category results for every checkable
/// block plus the blocks that could not be checked (e.g. an image the remote
/// moderation service cannot fetch).
public struct ModerationScanOutcome: Sendable {
  public let results: [ModerationResult]
  public let uncheckedBlocks: [ModerationBlock]
  /// Messages for blocks the service was asked to check but failed on. Those
  /// blocks also appear in `uncheckedBlocks`: a failed check is an unknown, not a
  /// pass, so it still withholds certification.
  public let failures: [String]
  /// Whether any block failed because the service rejected the credentials rather
  /// than the content. A host app reads this to re-prompt for an API key instead of
  /// showing an error the user cannot act on.
  public let authenticationFailed: Bool

  public init(
    results: [ModerationResult],
    uncheckedBlocks: [ModerationBlock],
    failures: [String] = [],
    authenticationFailed: Bool = false,
  ) {
    self.results = results
    self.uncheckedBlocks = uncheckedBlocks
    self.failures = failures
    self.authenticationFailed = authenticationFailed
  }

  /// Results that require attention, most severe first.
  public var unsuccessfulResults: [ModerationResult] {
    results
      .filter { $0.state != .success }
      .sorted { $0.state > $1.state }
  }

  /// Findings that require attention, grouped by the block they belong to, most
  /// severe block first.
  ///
  /// A single block routinely trips several categories at once — provider text
  /// models in particular overlap heavily, so one abusive caption can score under
  /// `toxic`, `insulting` and `discriminatory` together. Listing those as three
  /// separate rows would misrepresent one problem as three, so the panel presents
  /// the block once with its categories beneath it.
  public var groupedUnsuccessfulResults: [ModerationBlockFindings] {
    let grouped = Dictionary(grouping: unsuccessfulResults, by: \.blockID)
    return grouped
      .map { blockID, results in
        ModerationBlockFindings(
          blockID: blockID,
          displayName: results.first?.blockDisplayName ?? "",
          results: results.sorted { $0.state > $1.state },
        )
      }
      .sorted { lhs, rhs in
        // Most severe block first; ties broken by name so the order is stable
        // across runs rather than following the dictionary's.
        if lhs.severity != rhs.severity {
          return lhs.severity > rhs.severity
        }
        return lhs.displayName < rhs.displayName
      }
  }

  /// Results that represent policy violations.
  public var violations: [ModerationResult] {
    results.filter { $0.state == .failed }
  }

  /// Whether this scan certifies the design: no violations, and every block was
  /// actually checked.
  ///
  /// A block the service could not check is *unknown*, not clean — treating it as
  /// clean would let a design of nothing but local images pass a moderation gate
  /// without a single check being made. The status icon and the export gate both
  /// read this rather than `violations` alone.
  public var isCertifiablyClean: Bool {
    violations.isEmpty && uncheckedBlocks.isEmpty
  }
}

// MARK: - Thresholds

/// Maps moderation confidence scores to severity levels.
///
/// Adjust the thresholds based on your platform's needs or add custom presets.
public struct ModerationThresholds: Sendable {
  /// Scores above this value are reported as `.failed`.
  public let failed: Double
  /// Scores above this value (and at or below `failed`) are reported as `.warning`.
  public let warning: Double

  public init(failed: Double, warning: Double) {
    self.failed = failed
    self.warning = warning
  }

  /// Family-friendly platforms.
  public static let strict = ModerationThresholds(failed: 0.5, warning: 0.2)
  /// General audience (default).
  public static let moderate = ModerationThresholds(failed: 0.8, warning: 0.4)
  /// Adult-only platforms.
  public static let relaxed = ModerationThresholds(failed: 0.95, warning: 0.7)

  /// Converts a confidence score to a moderation state.
  public func state(for confidence: Double) -> ModerationState {
    if confidence > failed {
      .failed
    } else if confidence > warning {
      .warning
    } else {
      .success
    }
  }
}
