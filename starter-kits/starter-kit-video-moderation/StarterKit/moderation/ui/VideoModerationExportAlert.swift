import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Moderation Export Alert

/// Asks before an export when the video is not confirmed clean.
///
/// Presented as a sheet rather than a system `alert` because the editor's event
/// handler exposes custom modal content through `openSheet`; the built-in
/// alerts are fixed-purpose. Choosing "Moderate now" swaps this content for the
/// results panel inside the same sheet, which avoids dismiss/present races.
struct VideoModerationExportAlert: View {
  /// Why the export needs confirmation.
  enum Reason: Equatable {
    /// The last run failed, so no verdict exists.
    case lastRunFailed
    case neverValidated
    case contentChanged
    /// The last run flagged this many blocks, as *Certain* or *Likely*.
    case flagged(blocks: Int)
    /// The last run could not check this many blocks.
    case unchecked(blocks: Int)

    /// The reason to ask before exporting, or `nil` when the video is confirmed clean:
    /// checked, unchanged since, nothing flagged and every block checked.
    @MainActor
    static func current(store: VideoModerationStore, engine: Engine) -> Reason? {
      if store.lastRunFailed {
        return .lastRunFailed
      }
      // `refreshNeedsValidation` recomputes rather than reading the cached flag: a
      // missed history update may leave the icon stale, but it must never let an
      // export through on a video the store has not just compared.
      if store.refreshNeedsValidation(engine: engine) {
        return store.hasValidated ? .contentChanged : .neverValidated
      }
      guard let outcome = store.outcome else {
        return .neverValidated
      }
      // Blocks, not category hits, as the results panel counts them.
      let flagged = outcome.groupedUnsuccessfulResults.count
      if flagged > 0 {
        return .flagged(blocks: flagged)
      }
      if !outcome.uncheckedBlocks.isEmpty {
        return .unchecked(blocks: outcome.uncheckedBlocks.count)
      }
      return nil
    }

    var title: String {
      if case .flagged = self {
        return "Restricted content detected"
      }
      return "Content not moderated"
    }

    var message: String {
      switch self {
      case .lastRunFailed:
        "The last check did not finish, so this video may contain restricted content. Export anyway?"
      case .neverValidated:
        "This video hasn't been moderated yet and may contain restricted content. Export anyway?"
      case .contentChanged:
        "This video has changed since the last check and may contain restricted content. Export anyway?"
      case let .flagged(blocks):
        "This video may contain restricted content in \(Self.plural(blocks, "place")). Export anyway?"
      case let .unchecked(blocks):
        "\(Self.plural(blocks, "block")) could not be checked and may contain restricted content. Export anyway?"
      }
    }

    private static func plural(_ count: Int, _ noun: String) -> String {
      "\(count) \(noun)\(count == 1 ? "" : "s")"
    }
  }

  let store: VideoModerationStore
  let reason: Reason
  let engine: Engine
  let eventHandler: any EditorEventHandler
  /// Exports without moderating. Runs on the main actor.
  let onExportAnyway: () -> Void

  @State private var showResults = false

  init(
    store: VideoModerationStore,
    reason: Reason,
    engine: Engine,
    eventHandler: any EditorEventHandler,
    onExportAnyway: @escaping () -> Void,
  ) {
    self.store = store
    self.reason = reason
    self.engine = engine
    self.eventHandler = eventHandler
    self.onExportAnyway = onExportAnyway
  }

  var body: some View {
    if showResults {
      VideoModerationResultsPanel(
        store: store,
        engine: engine,
        eventHandler: eventHandler,
        autoValidate: true,
      )
    } else {
      alertContent
    }
  }

  private var alertContent: some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 44))
        .foregroundStyle(.orange)
        .padding(.top, 32)
      Text(reason.title)
        .font(.headline)
      Text(reason.message)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        // Wraps instead of truncating when the sheet is short.
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 24)

      VStack(spacing: 8) {
        Button {
          showResults = true
        } label: {
          Text("Moderate now")
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)

        Button(role: .destructive) {
          eventHandler.send(.closeSheet)
          onExportAnyway()
        } label: {
          Text("Export anyway")
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(.borderless)

        Button("Cancel") {
          eventHandler.send(.closeSheet)
        }
        .buttonStyle(.borderless)
        .frame(height: 44)
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
    }
  }
}
