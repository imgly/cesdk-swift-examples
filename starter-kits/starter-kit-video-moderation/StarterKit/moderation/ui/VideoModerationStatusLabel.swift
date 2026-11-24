import SwiftUI

// MARK: - Moderation Status Label

/// The navigation bar's validation status icon.
///
/// Reflects the live state of ``VideoModerationStore``: not yet validated, a check
/// in flight, a clean result, or flagged content. Because it observes the
/// store, the icon updates as soon as a run finishes — it is not static.
///
/// `checkmark.shield` is shown for one state only: a completed run that found
/// nothing and left nothing unchecked. Every other resting state — never validated,
/// changed since validation, flagged, or partly unchecked — shows
/// `exclamationmark.shield`, because in all of them nothing vouches for what is on
/// the canvas, and a checkmark would claim otherwise. The checkmark is earned by a
/// run, not assumed. The accessibility label says which of the four it is.
///
/// The fill carries presentation rather than status: filled while the results sheet
/// is open, the way a selected toolbar item is, unfilled once it closes. A run in
/// flight replaces the icon with a spinner.
///
/// Staleness is read from ``VideoModerationStore/needsValidation``, which the store keeps
/// current from the change tracking started in `onLoaded`, because this view re-renders
/// on every editor event and recomputing it would walk the scene each time.
struct VideoModerationStatusLabel: View {
  @ObservedObject var store: VideoModerationStore

  var body: some View {
    symbol
  }

  @ViewBuilder private var symbol: some View {
    switch store.status {
    case .validating:
      ProgressView()
        .controlSize(.small)
        .accessibilityLabel("Moderating content")
    case .notValidated:
      icon(shieldSymbol("exclamationmark.shield"), label: "Content not moderated")
    case .stale:
      icon(shieldSymbol("exclamationmark.shield"), label: "Video changed since it was moderated")
    case .clean:
      icon(shieldSymbol("checkmark.shield"), label: "Content moderated, no issues found")
    case let .issues(count):
      icon(
        shieldSymbol("exclamationmark.shield"),
        label: "Content moderated, \(count) issue\(count == 1 ? "" : "s") found",
      )
    case let .unchecked(count):
      icon(
        shieldSymbol("exclamationmark.shield"),
        label: "\(count) block\(count == 1 ? "" : "s") could not be checked",
      )
    }
  }

  /// Fills the symbol while the results sheet is open, so the navigation bar
  /// item reads as active for as long as the sheet is on screen.
  private func shieldSymbol(_ base: String) -> String {
    guard store.isPanelPresented, !base.hasSuffix(".fill") else { return base }
    return base + ".fill"
  }

  /// The icon carries the state through the symbol alone and inherits the
  /// navigation bar's tint — the design keeps these controls monochrome.
  private func icon(_ systemName: String, label: String) -> some View {
    Label {
      Text("Video moderation")
    } icon: {
      Image(systemName: systemName)
    }
    .labelStyle(.iconOnly)
    .accessibilityLabel(label)
  }
}
