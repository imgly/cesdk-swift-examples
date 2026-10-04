import SwiftUI

// MARK: - Moderation Result Row

/// One flagged category beneath its block: a severity dot, the category name and
/// its description.
///
/// The row carries no action of its own — navigation belongs to the block heading
/// it sits under, because every category flagged on a block selects that same
/// block, and repeating the control per row would offer the same destination
/// several times over.
struct ModerationResultRow: View {
  let result: ModerationResult

  var body: some View {
    HStack(spacing: 16) {
      Circle()
        .fill(dotColor)
        .frame(width: 12, height: 12)
      VStack(alignment: .leading, spacing: 2) {
        Text(result.check.name)
          .font(.body)
          .foregroundStyle(.primary)
        Text(result.check.description)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
      Spacer()
    }
    .padding(.leading, 32)
    .padding(.trailing, 16)
    .frame(height: 60)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text("\(severityLabel): \(result.check.name)"))
    .accessibilityHint(Text(result.check.description))
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
