import Foundation
import IMGLYEngine
import SwiftUI

// MARK: - Moderation Store

/// Observable moderation state for one editor.
///
/// Holds the most recent scan outcome so that every surface — the navigation bar
/// status icon, the results panel, and the export gate — reflects the same state.
/// It also records a fingerprint of the scene's moderatable content at validation
/// time, so the export gate can tell whether the design changed since it was last
/// validated.
///
/// One store belongs to one editor. ``ContentModerationEditorConfiguration`` creates
/// it and hands it to the callbacks and views that need it, so two editors never
/// share a verdict and a test can supply its own.
@MainActor
public final class ModerationStore: ObservableObject {
  /// The result of the most recent successful validation run.
  @Published public private(set) var outcome: ModerationScanOutcome?
  /// Whether a validation run is currently in flight.
  @Published public private(set) var isValidating = false
  /// The error of the most recent failed validation run, if any.
  @Published public private(set) var errorMessage: String?
  /// Whether the results sheet is currently presented.
  @Published public private(set) var isPanelPresented = false
  /// Whether the last run failed because the moderation service rejected the
  /// credentials. Surfaced separately from `errorMessage` so a host app can
  /// re-prompt for an API key instead of parsing an error string.
  @Published public private(set) var authenticationFailed = false

  /// Whether the design must be validated before it may be exported: either it was
  /// never validated, or its moderatable content changed since the last run.
  ///
  /// Maintained by ``observe(engine:)`` rather than computed on demand, because the
  /// navigation bar icon reads it on every render — including every frame of a drag —
  /// and computing it walks every block in the scene.
  ///
  /// Starts `true`: a design nobody has validated needs validating.
  @Published public private(set) var needsValidation = true

  /// The service used to check content.
  ///
  /// Defaults to a ``GatewayModerationService`` with no API key, which fails every
  /// check with ``ModerationServiceError/missingAPIKey`` rather than reporting
  /// content as clean.
  public private(set) var service: ModerationService

  /// Fingerprint of the scene's moderatable content at the time of the last run.
  private var validatedFingerprint: Set<String>?

  /// Identifies the run whose result may still be stored.
  ///
  /// Bumped by ``reset()``, so a run that was in flight when the service changed —
  /// or when a new scene loaded — cannot write a verdict the current state never
  /// asked for.
  private var currentRun = 0

  public init(service: ModerationService = GatewayModerationService(apiKey: "")) {
    self.service = service
  }

  // MARK: - Status

  /// The state the editor should communicate to the user.
  public enum Status: Equatable {
    /// Nothing has been validated yet.
    case notValidated
    /// A verdict existed, and the design has changed since. Distinct from
    /// ``notValidated`` so the label can say which, the way the export alert does.
    case stale
    case validating
    case clean
    case issues(count: Int)
    /// Validated, nothing flagged, but some blocks could not be checked at all.
    /// Deliberately distinct from `clean` — see ``ModerationScanOutcome/isCertifiablyClean``.
    case unchecked(count: Int)
  }

  /// The status to surface for the user.
  ///
  /// A design whose moderatable content changed since the last run reports
  /// `.notValidated`: the stored outcome no longer describes what is on the canvas,
  /// and the export gate will ask for a new run.
  public var status: Status {
    if isValidating {
      return .validating
    }
    guard let outcome, !needsValidation else {
      // The same signal the export gate uses to choose its alert wording.
      return hasValidated ? .stale : .notValidated
    }
    // Blocks, not category hits — the same unit the results panel counts. One
    // caption tripping three text categories is one thing for the user to fix, and
    // a badge reading 3 next to a panel reading 1 would be the app disagreeing with
    // itself.
    let flagged = outcome.groupedUnsuccessfulResults.count
    if flagged > 0 {
      return .issues(count: flagged)
    }
    // Flagged content takes visual precedence because it is actionable; unchecked
    // blocks surface once there is nothing flagged left to report. The results
    // panel lists both regardless.
    if !outcome.uncheckedBlocks.isEmpty {
      return .unchecked(count: outcome.uncheckedBlocks.count)
    }
    return .clean
  }

  /// Whether at least one validation run has completed.
  public var hasValidated: Bool {
    validatedFingerprint != nil
  }

  // MARK: - Change Tracking

  /// Keeps ``needsValidation`` current for as long as the calling task lives.
  ///
  /// Call it from a SwiftUI `.task`, which starts it on appear and cancels it on
  /// disappear. Owning no task of its own means nothing has to remember to stop it,
  /// and the engine outlives nothing — the store never holds a reference to it.
  ///
  /// The signal is the engine's own history stream rather than the editor's
  /// `onChanged` callback: `OnChanged.EditorStateChange` reports page, edit mode,
  /// view mode and gesture changes, none of which fire when a block's content is
  /// replaced. History updates do, and are what the editor's own interactor listens
  /// to.
  ///
  /// Missing an update is a cosmetic fault only. The export gate calls
  /// ``refreshNeedsValidation(engine:)`` and recomputes rather than trusting this.
  public func observeChanges(engine: Engine) async {
    refreshNeedsValidation(engine: engine)
    for await _ in engine.editor.onHistoryUpdatedWithKind {
      if Task.isCancelled {
        return
      }
      refreshNeedsValidation(engine: engine)
    }
  }

  /// Recomputes whether the design changed since the last validation, updates
  /// ``needsValidation``, and returns the exact answer.
  ///
  /// The export gate calls this rather than reading ``needsValidation`` directly. A
  /// missed history update may leave the icon stale, which is a cosmetic fault; it
  /// must never open the export gate on a design this store has not just compared.
  @discardableResult
  public func refreshNeedsValidation(engine: Engine) -> Bool {
    let changed: Bool = if let validatedFingerprint {
      ModerationScanner.contentFingerprint(engine: engine) != validatedFingerprint
    } else {
      true
    }
    if needsValidation != changed {
      needsValidation = changed
    }
    return changed
  }

  // MARK: - Actions

  /// Runs a validation pass and stores the outcome.
  ///
  /// The fingerprint is snapshotted *before* the network round-trip and only
  /// recorded if the content is unchanged when the results arrive. Editing an image
  /// mid-run therefore leaves the design marked as needing validation rather than
  /// certifying content that was never checked.
  public func validate(engine: Engine) async {
    currentRun &+= 1
    let run = currentRun
    isValidating = true
    errorMessage = nil
    authenticationFailed = false
    let service = service
    let fingerprintBeforeRun = ModerationScanner.contentFingerprint(engine: engine)
    do {
      let result = try await ModerationScanner.checkContent(engine: engine, service: service)
      // A run the store has since disowned — the service was swapped, or a new scene
      // loaded — must not install its verdict over the state that replaced it.
      guard run == currentRun else { return }
      outcome = result
      let fingerprintAfterRun = ModerationScanner.contentFingerprint(engine: engine)
      validatedFingerprint = fingerprintAfterRun == fingerprintBeforeRun ? fingerprintBeforeRun : nil
      // Individual blocks can fail without failing the run. Surface the first
      // message; those blocks are already listed as unchecked, so export stays gated.
      errorMessage = result.failures.first
      // A rejected key fails every block rather than the run, so it arrives here and
      // not in the `catch` below. Without this the host app's re-prompt never fires.
      authenticationFailed = result.authenticationFailed
    } catch {
      guard run == currentRun else { return }
      // Discard the previous outcome. Leaving it on screen next to an error would
      // show a verdict for a design this run never managed to check — the same
      // false all-clear the rest of this type is built to prevent.
      outcome = nil
      validatedFingerprint = nil
      errorMessage = error.localizedDescription
      authenticationFailed = Self.isAuthenticationFailure(error)
    }
    refreshNeedsValidation(engine: engine)
    isValidating = false
  }

  /// Whether an error means the service rejected the credentials rather than
  /// the content. Matched on the typed error, not on the message text.
  private static func isAuthenticationFailure(_ error: Error) -> Bool {
    (error as? ModerationServiceError)?.isAuthenticationFailure ?? false
  }

  /// Swaps in a different moderation service and clears the previous outcome.
  ///
  /// The old service holds its own result cache, and any outcome it produced
  /// describes a check made with different credentials — keeping either around
  /// would let a stale result stand in for one this service never made.
  public func setService(_ service: ModerationService) {
    self.service = service
    reset()
  }

  /// Clears a previous error, e.g. when the results panel is opened again.
  public func clearError() {
    errorMessage = nil
    authenticationFailed = false
  }

  /// Tracks presentation of the results sheet so the navigation bar icon can
  /// render as active while it is open.
  ///
  /// Deliberately a plain flag. The editor erases sheet content through `AnyView`,
  /// which does not preserve view identity, so anything keyed on per-presentation
  /// `@State` can miss its own teardown and leave the icon stuck filled. Callers set
  /// it false on every dismissal path they control.
  public func setPanelPresented(_ presented: Bool) {
    isPanelPresented = presented
  }

  /// Clears all moderation state, e.g. when a new scene is loaded.
  ///
  /// Also disowns any run still in flight, so its result cannot arrive afterwards
  /// and re-certify a design this store has just forgotten.
  public func reset() {
    currentRun &+= 1
    outcome = nil
    errorMessage = nil
    authenticationFailed = false
    validatedFingerprint = nil
    isPanelPresented = false
    isValidating = false
    needsValidation = true
  }
}
