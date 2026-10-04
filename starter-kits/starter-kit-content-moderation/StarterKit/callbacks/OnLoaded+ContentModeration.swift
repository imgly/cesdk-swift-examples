import IMGLYEditor
import IMGLYEngine

// MARK: - Default OnLoaded

public extension ContentModerationEditorConfiguration {
  /// The default `onLoaded` handler.
  ///
  /// Resets the moderation state and starts change tracking.
  ///
  /// Both belong here rather than in `onCreate` or in a view, because `onLoaded` is the
  /// first point at which the engine and the scene exist. A view cannot stand in for it:
  /// the navigation bar is built before the engine exists, so a `.task` there fires with
  /// no engine and, without an `id:`, never runs again.
  ///
  /// Chaining is not automatic. `configure(_:)` registers one handler per callback —
  /// `builder.onLoaded ?? onLoaded` — so a host that sets `onLoaded` on this
  /// configuration replaces this handler rather than wrapping it, and its `existing()`
  /// chains to whatever was registered before, not to this. Chaining to this handler
  /// works from a second configuration listed after this one in
  /// `.imgly.configuration { }`, which is what the documentation tells integrators.
  ///
  /// - Parameter moderation: The editor's moderation state.
  /// - Returns: A handler that chains to any previously configured `onLoaded`.
  static func defaultOnLoadedHandler(_ moderation: ModerationStore) -> OnLoaded.Handler {
    { context, existing in
      try await existing()
      // A new scene must not inherit the previous one's verdict.
      moderation.reset()
      // `context.task` is the editor's own API for subscriptions that should live as
      // long as the editor: it cancels them when the editor closes, so the store never
      // outlives its engine or keeps it alive.
      context.task {
        await moderation.observeChanges(engine: context.engine)
      }
    }
  }
}
