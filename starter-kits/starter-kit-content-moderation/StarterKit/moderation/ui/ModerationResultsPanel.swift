import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Moderation Results Panel

/// The "Content Validation" sheet.
///
/// Opening the sheet does **not** start a check: the user sees the idle state
/// and starts validation explicitly with the button at the bottom. Results are
/// listed with severity indicators and a probability legend; selecting a result
/// closes the sheet and navigates to the flagged block on the canvas.
struct ModerationResultsPanel: View {
  let engine: Engine
  let eventHandler: any EditorEventHandler
  /// Starts a validation run as soon as the sheet appears. Only used when the
  /// user already asked for a check elsewhere, e.g. from the export alert.
  let autoValidate: Bool
  /// Whether the panel was opened because an export was blocked.
  let isExportBlocked: Bool

  @ObservedObject private var store: ModerationStore

  init(
    store: ModerationStore,
    engine: Engine,
    eventHandler: any EditorEventHandler,
    autoValidate: Bool = false,
    isExportBlocked: Bool = false,
  ) {
    self.store = store
    self.engine = engine
    self.eventHandler = eventHandler
    self.autoValidate = autoValidate
    self.isExportBlocked = isExportBlocked
  }

  var body: some View {
    VStack(spacing: 0) {
      header
      if store.isValidating {
        // Centred in the space between the header and the button rather than
        // sitting under the header. Still a ScrollView: the medium detent is
        // only 160pt in compact height (landscape), where this would clip.
        ScrollView {
          progressContent
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
      } else {
        ScrollView {
          VStack(spacing: 12) {
            if let errorMessage = store.errorMessage {
              errorBanner(errorMessage)
            }
            if let outcome = store.outcome {
              resultsContent(outcome)
            } else if store.errorMessage == nil {
              idleContent
            }
          }
          .padding(.horizontal, 16)
          .padding(.top, 4)
        }
      }
      validateButton
    }
    .onAppear { store.setPanelPresented(true) }
    .onDisappear { store.setPanelPresented(false) }
    .task {
      // A previous run's error must not greet the user on a fresh open.
      store.clearError()
      // Refreshed on every open, whatever opened the panel: the results below are
      // labelled against this flag, so a panel opened from the navigation bar must not
      // present a verdict the design has already outgrown.
      let needsValidation = store.refreshNeedsValidation(engine: engine)
      // Only revalidate when the panel was opened *because* a check is needed;
      // opening it from the navigation bar never starts a run.
      if autoValidate, !store.isValidating, needsValidation {
        await validate()
      }
    }
  }

  // MARK: - Header

  private var header: some View {
    ZStack {
      Text("Content Validation")
        .font(.headline)
      HStack {
        Spacer()
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.down")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(SwiftUI.Color(.secondaryLabel))
            .frame(width: 30, height: 30)
            .background(SwiftUI.Color(.tertiarySystemFill), in: Circle())
            .frame(width: 44, height: 44)
            .contentShape(Circle())
        }
        // `.plain` stops the button tint from colouring the label; without it
        // both the chevron and its backing pick up the accent colour.
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }

  // MARK: - Content States

  /// Shown before any check has run — the user starts it with the button below.
  private var idleContent: some View {
    VStack(spacing: 16) {
      Image(systemName: "checkmark.shield")
        .font(.system(size: 44))
        .foregroundStyle(.secondary)
        .padding(.top, 16)
      Text("Check your design for content that may violate the rules before exporting.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
  }

  private var progressContent: some View {
    VStack(spacing: 16) {
      ProgressView()
        .controlSize(.large)
      Text("Validating content...")
        .font(.body)
        .foregroundStyle(.secondary)
    }
    .padding(24)
  }

  /// Shown above any previous results so a failed re-run does not hide them.
  private func errorBanner(_ message: String) -> some View {
    HStack(alignment: .top, spacing: 8) {
      Image(systemName: "exclamationmark.triangle.fill")
        .foregroundStyle(.orange)
      Text(message)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Spacer(minLength: 0)
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(SwiftUI.Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
  }

  @ViewBuilder private func resultsContent(_ outcome: ModerationScanOutcome) -> some View {
    let grouped = outcome.groupedUnsuccessfulResults
    let unchecked = outcome.uncheckedBlocks

    if grouped.isEmpty, unchecked.isEmpty {
      VStack(spacing: 16) {
        Image(systemName: "checkmark.shield")
          .font(.system(size: 44))
          .foregroundStyle(.green)
          .padding(.top, 16)
        Text("No content violations found.\nAdd possibly offensive content and run it again.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
    } else {
      if isExportBlocked {
        Label(
          "Export is blocked while the design has violations or content that could not be checked.",
          systemImage: "exclamationmark.octagon.fill",
        )
        .font(.subheadline)
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      // Only rendered when there is something to head; a design whose only finding
      // is unchecked content would otherwise show "0 Results" above an empty card.
      //
      // The count is of blocks, not of category hits. One caption commonly trips
      // several text categories at once, and reporting that as three results would
      // present one thing to fix as three.
      if !grouped.isEmpty {
        Label(
          "\(grouped.count) Result\(grouped.count == 1 ? "" : "s")",
          systemImage: "exclamationmark.shield",
        )
        .font(.body)

        VStack(spacing: 0) {
          ForEach(Array(grouped.enumerated()), id: \.element.id) { index, findings in
            if index > 0 {
              Divider()
            }
            blockFindings(findings)
          }
        }
        .background(SwiftUI.Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 26))
      }

      if !unchecked.isEmpty {
        VStack(spacing: 0) {
          ForEach(Array(unchecked.enumerated()), id: \.element) { index, block in
            if index > 0 {
              Divider()
                .padding(.leading, 44)
            }
            uncheckedRow(block)
          }
        }
        .background(SwiftUI.Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 26))

        Text("This content could not be checked by the moderation service.")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }

      legend
    }
  }

  /// One block and every category flagged on it. The block heads the group and
  /// carries the Select action, so a caption flagged three times is one entry to act
  /// on rather than three rows that all navigate to the same place.
  private func blockFindings(_ findings: ModerationBlockFindings) -> some View {
    VStack(spacing: 0) {
      HStack(spacing: 16) {
        Text(findings.displayName)
          .font(.body)
          .lineLimit(1)
          .truncationMode(.tail)
        Spacer()
        Button("Select") {
          select(findings.blockID)
        }
        .font(.body)
        .buttonStyle(.borderless)
      }
      .padding(.horizontal, 16)
      .frame(height: 52)
      .accessibilityElement(children: .contain)
      .accessibilityLabel(Text(findings.displayName))

      ForEach(findings.results) { result in
        ModerationResultRow(result: result)
      }
    }
  }

  private func uncheckedRow(_ block: ModerationBlock) -> some View {
    HStack(spacing: 16) {
      Circle()
        .fill(.quaternary)
        .frame(width: 12, height: 12)
      VStack(alignment: .leading, spacing: 2) {
        // `displayName`, not `blockName`: a text block is recognizable by an excerpt
        // of what it says, where every one of them is just called "Text".
        Text(block.displayName)
          .font(.body)
          .lineLimit(1)
          .truncationMode(.tail)
        Text("Not checkable")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Button("Select") {
        select(block.blockID)
      }
      .font(.body)
      .buttonStyle(.borderless)
    }
    .padding(.horizontal, 16)
    .frame(height: 68)
  }

  private var legend: some View {
    HStack(spacing: 12) {
      Text("Probability:")
      HStack(spacing: 4) {
        Circle().fill(.red).frame(width: 12, height: 12)
        Text("Certain")
      }
      HStack(spacing: 4) {
        Circle().fill(.orange).frame(width: 12, height: 12)
        Text("Likely")
      }
    }
    .font(.subheadline)
    .foregroundStyle(.secondary)
    .padding(.vertical, 8)
  }

  private var validateButton: some View {
    Button {
      Task { await validate() }
    } label: {
      Text(store.outcome == nil ? "Run Validation" : "Rerun Validation")
        .font(.body.weight(.semibold))
        .frame(maxWidth: .infinity)
        .frame(height: 48)
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.capsule)
    .disabled(store.isValidating)
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }

  // MARK: - Actions

  private func validate() async {
    await store.validate(engine: engine)
  }

  private func select(_ blockID: DesignBlockID) {
    try? ModerationScanner.selectBlock(engine: engine, blockID: blockID)
    dismiss()
  }

  /// Closes the sheet and clears the presented flag directly, rather than
  /// trusting `onDisappear` to fire — it does not always, because the editor
  /// re-erases sheet content through `AnyView`. Swipe-to-dismiss still relies
  /// on `onDisappear`.
  private func dismiss() {
    store.setPanelPresented(false)
    eventHandler.send(.closeSheet)
  }
}
