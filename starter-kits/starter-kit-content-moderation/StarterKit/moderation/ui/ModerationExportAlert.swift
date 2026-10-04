import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Moderation Export Alert

/// Shown when an export is requested while the design has not been validated,
/// or was changed since the last validation.
///
/// Presented as a sheet rather than a system `alert` because the editor's event
/// handler exposes custom modal content through `openSheet`; the built-in
/// alerts are fixed-purpose. Choosing "Validate Now" swaps this content for the
/// results panel inside the same sheet, which avoids dismiss/present races.
struct ModerationExportAlert: View {
  enum Reason {
    case neverValidated
    case contentChanged

    var message: String {
      switch self {
      case .neverValidated:
        "This design has not been checked for content that may violate the rules. Validate it before exporting."
      case .contentChanged:
        "The design changed since the last validation. Validate it again before exporting."
      }
    }
  }

  let store: ModerationStore
  let reason: Reason
  let engine: Engine
  let eventHandler: any EditorEventHandler
  /// Exports without validating. Runs on the main actor.
  let onExportAnyway: () -> Void

  @State private var showResults = false

  init(
    store: ModerationStore,
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
      ModerationResultsPanel(
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
      Image(systemName: "exclamationmark.shield")
        .font(.system(size: 44))
        .foregroundStyle(.orange)
        .padding(.top, 32)
      Text("Content Not Validated")
        .font(.headline)
      Text(reason.message)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)

      VStack(spacing: 8) {
        Button {
          showResults = true
        } label: {
          Text("Validate Now")
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)

        Button {
          eventHandler.send(.closeSheet)
          onExportAnyway()
        } label: {
          Text("Export Anyway")
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
