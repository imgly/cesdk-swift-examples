import SwiftUI

// MARK: - Moderation Result Row

/// One flagged category beneath its block: a severity dot, the category name, the
/// flagged times of a clip and its description.
///
/// The row carries no action of its own — navigation belongs to the block heading
/// it sits under, because every category flagged on a block selects that same
/// block, and repeating the control per row would offer the same destination
/// several times over.
struct VideoModerationResultRow: View {
  let result: VideoModerationResult

  var body: some View {
    HStack(spacing: 16) {
      Circle()
        .fill(dotColor)
        .frame(width: 12, height: 12)
      VStack(alignment: .leading, spacing: 2) {
        Text(result.check.name)
          .font(.body)
          .foregroundStyle(.primary)
        // An image or a text has no time of its own, so it shows no times.
        if !result.flaggedRanges.isEmpty {
          Text(result.flaggedRanges.map(Self.timecode).joined(separator: ", "))
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
        Text(result.check.description)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
      Spacer()
    }
    .padding(.leading, 32)
    .padding(.trailing, 16)
    .frame(minHeight: 60)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text("\(severityLabel): \(result.check.name)"))
    .accessibilityHint(Text(result.check.description))
  }

  /// Formats a range of clip seconds as "0:04–0:10", or as "0:04" when it is shorter
  /// than a second.
  private static func timecode(_ range: ClosedRange<TimeInterval>) -> String {
    let from = Int(range.lowerBound)
    let to = Int(range.upperBound)
    let format = { (seconds: Int) in String(format: "%d:%02d", seconds / 60, seconds % 60) }
    return to <= from ? format(from) : "\(format(from))–\(format(to))"
  }

  /// Spoken severity, so the dot's colour is not the only thing carrying it.
  private var severityLabel: String {
    switch result.state {
    case .failed: "Certain"
    case .warning: "Likely"
    case .success: "Clear"
    }
  }

  /// Severity dot color: red for certain violations, orange for likely ones.
  private var dotColor: Color {
    switch result.state {
    case .failed: .red
    case .warning: .orange
    case .success: .green
    }
  }
}
