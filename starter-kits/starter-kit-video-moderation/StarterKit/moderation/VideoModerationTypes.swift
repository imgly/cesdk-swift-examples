import Foundation
import IMGLYEngine

// MARK: - Moderation Types

/// Severity level derived from a moderation confidence score.
public enum VideoModerationState: Int, Sendable, Comparable {
  case success = 0
  case warning = 1
  case failed = 2

  public static func < (lhs: VideoModerationState, rhs: VideoModerationState) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

/// A content category check returned by a moderation service.
public struct VideoModerationCheckResult: Sendable, Hashable {
  /// The category name, e.g. "Weapons".
  public let name: String
  /// A short description of what the category covers.
  public let description: String
  /// The severity derived from the service's confidence score.
  public let state: VideoModerationState

  public init(name: String, description: String, state: VideoModerationState) {
    self.name = name
    self.description = description
    self.state = state
  }
}

/// A piece of content a moderation service can check.
public enum VideoModerationContent: Sendable, Hashable {
  /// A video, identified by the URL of its source file. Remote unless the service
  /// accepts local files.
  case video(URL)
  /// An image, identified by URL. Remote unless the service accepts local files.
  case image(URL)
  /// The text of a text block.
  case text(String)
}

/// The categories a service found in one sampled frame of a video, or in an image or
/// a text.
public struct VideoModerationFrame: Sendable, Hashable {
  /// The frame's position in the source file, in seconds from its start. This is
  /// source time: it ignores the trim, the playback speed and the place of the clip on
  /// the timeline. An image or a text is a single frame at `0`.
  public let position: TimeInterval
  /// The categories scored for this frame.
  public let checks: [VideoModerationCheckResult]

  public init(position: TimeInterval, checks: [VideoModerationCheckResult]) {
    self.position = position
    self.checks = checks
  }
}

/// A block whose content can be moderated: a video clip on the timeline, a graphic
/// with an image fill, or a text block.
public struct VideoModerationBlock: Sendable, Hashable {
  public let blockID: DesignBlockID
  public let blockName: String
  public let content: VideoModerationContent
  /// The source seconds a clip shows, from the trim offset to the end of the shorter of
  /// the trim length and the block duration. `0...0` for an image or a text.
  public let played: ClosedRange<TimeInterval>
  /// The playback speed of a clip's fill. One second of the clip shows `speed` source
  /// seconds. `1` for an image or a text.
  public let speed: Double

  public init(
    blockID: DesignBlockID,
    blockName: String,
    content: VideoModerationContent,
    played: ClosedRange<TimeInterval> = 0 ... 0,
    speed: Double = 1,
  ) {
    self.blockID = blockID
    self.blockName = blockName
    self.content = content
    self.played = played
    self.speed = speed
  }

  /// A short label for the block in the results panel. Text blocks show an excerpt of
  /// their own content, because "Text" alone does not identify which one. A clip or an
  /// image the user never named falls back to "Video" or "Image" rather than to the
  /// engine's generic "Block".
  public var displayName: String {
    switch content {
    case .video:
      blockName.isEmpty ? "Video" : blockName
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

  /// Converts a position in the source file to seconds from the start of the clip.
  public func clipTime(ofSourceTime sourceTime: TimeInterval) -> TimeInterval {
    (sourceTime - played.lowerBound) / speed
  }
}

/// A moderation check result tied to a specific clip, image or text block.
public struct VideoModerationResult: Sendable, Hashable, Identifiable {
  public let id: String
  public let blockID: DesignBlockID
  public let blockName: String
  /// The label the panel shows for the block this result belongs to.
  public let blockDisplayName: String
  /// The category with the worst state of the frames that play.
  public let check: VideoModerationCheckResult
  /// The parts of a clip where the category is not `.success`, in seconds from the
  /// start of the clip on the timeline. Empty when the category is clean, and always
  /// empty for an image or a text, which has no time of its own.
  public let flaggedRanges: [ClosedRange<TimeInterval>]

  public init(
    id: String,
    blockID: DesignBlockID,
    blockName: String,
    blockDisplayName: String,
    check: VideoModerationCheckResult,
    flaggedRanges: [ClosedRange<TimeInterval>],
  ) {
    self.id = id
    self.blockID = blockID
    self.blockName = blockName
    self.blockDisplayName = blockDisplayName
    self.check = check
    self.flaggedRanges = flaggedRanges
  }

  /// Convenience accessor for the check's severity.
  public var state: VideoModerationState {
    check.state
  }
}

/// Every finding for one block, as the results panel presents them.
public struct VideoModerationBlockFindings: Sendable, Hashable, Identifiable {
  public let blockID: DesignBlockID
  public let displayName: String
  public let results: [VideoModerationResult]

  public init(blockID: DesignBlockID, displayName: String, results: [VideoModerationResult]) {
    self.blockID = blockID
    self.displayName = displayName
    self.results = results
  }

  public var id: DesignBlockID {
    blockID
  }

  /// The most severe finding on this block, which orders it against the others.
  public var severity: VideoModerationState {
    results.map(\.state).max() ?? .success
  }

  /// The earliest flagged moment of a clip, in seconds from its start. `0` for an image
  /// or a text, which selects the block where it starts.
  public var firstFlaggedTime: TimeInterval {
    results.compactMap { $0.flaggedRanges.first?.lowerBound }.min() ?? 0
  }
}

/// The outcome of scanning a scene: per-category results for every checkable block plus
/// the blocks that could not be checked (e.g. a file the service cannot reach).
public struct VideoModerationScanOutcome: Sendable {
  public let results: [VideoModerationResult]
  public let uncheckedBlocks: [VideoModerationBlock]
  /// Messages for blocks the service was asked to check but failed on. Those blocks also
  /// appear in `uncheckedBlocks`: a failed check is an unknown, not a pass, so it still
  /// withholds certification.
  public let failures: [String]
  /// Whether any block failed because the service rejected the credentials rather than
  /// the content. A host app reads this to re-prompt for an API key instead of showing
  /// an error the user cannot act on.
  public let authenticationFailed: Bool

  public init(
    results: [VideoModerationResult],
    uncheckedBlocks: [VideoModerationBlock],
    failures: [String] = [],
    authenticationFailed: Bool = false,
  ) {
    self.results = results
    self.uncheckedBlocks = uncheckedBlocks
    self.failures = failures
    self.authenticationFailed = authenticationFailed
  }

  /// Results that require attention, most severe first.
  public var unsuccessfulResults: [VideoModerationResult] {
    results
      .filter { $0.state != .success }
      .sorted { $0.state > $1.state }
  }

  /// Findings that require attention, grouped by the block they belong to, most severe
  /// block first. A block that trips several categories is one entry with its categories
  /// beneath it.
  public var groupedUnsuccessfulResults: [VideoModerationBlockFindings] {
    let grouped = Dictionary(grouping: unsuccessfulResults, by: \.blockID)
    return grouped
      .map { blockID, results in
        VideoModerationBlockFindings(
          blockID: blockID,
          displayName: results.first?.blockDisplayName ?? "",
          results: results.sorted { $0.state > $1.state },
        )
      }
      .sorted { lhs, rhs in
        // Most severe block first; ties broken by name so the order is stable across
        // runs rather than following the dictionary's.
        if lhs.severity != rhs.severity {
          return lhs.severity > rhs.severity
        }
        return lhs.displayName < rhs.displayName
      }
  }

  /// Results that represent policy violations.
  public var violations: [VideoModerationResult] {
    results.filter { $0.state == .failed }
  }

  /// Whether this scan certifies the video: no violations, and every block was actually
  /// checked. A block the service could not check is unknown, not clean.
  public var isCertifiablyClean: Bool {
    violations.isEmpty && uncheckedBlocks.isEmpty
  }
}

// MARK: - Thresholds

/// Maps moderation confidence scores to severity levels.
///
/// Adjust the thresholds based on your platform's needs or add custom presets.
public struct VideoModerationThresholds: Sendable {
  /// Scores above this value are reported as `.failed`.
  public let failed: Double
  /// Scores above this value (and at or below `failed`) are reported as `.warning`.
  public let warning: Double

  public init(failed: Double, warning: Double) {
    self.failed = failed
    self.warning = warning
  }

  /// Family-friendly platforms.
  public static let strict = VideoModerationThresholds(failed: 0.5, warning: 0.2)
  /// General audience (default).
  public static let moderate = VideoModerationThresholds(failed: 0.8, warning: 0.4)
  /// Adult-only platforms.
  public static let relaxed = VideoModerationThresholds(failed: 0.95, warning: 0.7)

  /// Converts a confidence score to a moderation state.
  public func state(for confidence: Double) -> VideoModerationState {
    if confidence > failed {
      .failed
    } else if confidence > warning {
      .warning
    } else {
      .success
    }
  }
}
