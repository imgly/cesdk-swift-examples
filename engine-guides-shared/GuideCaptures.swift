import Foundation
import IMGLYEngine

/// Verification hook for visual engine guides.
///
/// `GuideCaptures.current` defaults to `.noop` — `engine.captureGuide(...)`
/// calls in guide source become no-ops, so customers reading the example see
/// ordinary engine code with one extra labeled call per checkpoint they can
/// ignore. The IMG.LY test harness sets `GuideCaptures.current = .testing`
/// in its test class init; each `captureGuide(...)` call then fires an
/// `assertSnapshot` at the guide's own source line.
@MainActor
struct GuideCaptures {
  typealias OnCapture = @MainActor (
    Data, String, MIMEType,
    StaticString, StaticString, UInt, UInt
  ) async throws -> Void

  let onCapture: OnCapture?

  /// No-op captures (the default for customer use).
  static let noop = GuideCaptures(onCapture: nil)

  /// Currently installed captures. The test harness sets this to `.testing`
  /// once at engine creation; per-test isolation is handled inside the
  /// installed value (via `Test.current` for the snapshot file name).
  static var current: GuideCaptures = .noop
}

/// Target width, in pixels, used for engine-rendered guide captures.
/// Matches the browser counterpart's hero-capture viewport width
/// (`apps/cesdk_web_examples/guides-*-browser/scripts/capture-hero.mjs`)
/// so iOS heroes render at the same resolution as their web peers.
/// Height is left at the `ExportOptions` default (0) so the engine
/// scales by `targetWidth / blockWidth` alone and the output height
/// follows the block's aspect ratio naturally — e.g. a 400×300 page
/// exports at 1200×900.
private let captureTargetWidth: Float = 1200

extension Engine {
  /// Capture a block's current rendered state for visual regression testing.
  ///
  /// **This is not part of the public CE.SDK Engine API** — it's a guide-test
  /// hook defined in this examples repo. By default `GuideCaptures.current`
  /// is `.noop`, so every call here is a no-op. Customers reading the
  /// example can safely ignore (or delete) `captureGuide(...)` calls; they
  /// only fire snapshot assertions when IMG.LY's test harness installs
  /// `GuideCaptures.current = .testing`.
  ///
  /// The captured PNG (or other raster mime type) is upscaled via
  /// `ExportOptions(targetWidth:)` so a guide's demo `Page` can stay at
  /// its natural teaching dimensions (e.g. 800×600) while the
  /// hero/snapshot still renders sharp at docs resolution.
  @MainActor
  func captureGuide(
    _ id: DesignBlockID,
    label: String,
    mimeType: MIMEType = .png,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
  ) async throws {
    guard let onCapture = GuideCaptures.current.onCapture else { return }
    let options = ExportOptions(targetWidth: captureTargetWidth)
    let data = try await block.export(id, mimeType: mimeType, options: options)
    try await onCapture(data, label, mimeType, fileID, filePath, line, column)
  }

  /// Capture pre-built bytes — for `exportVideo`, `exportAudio`, archives,
  /// scene JSON, or any blob the guide assembled itself.
  ///
  /// Same caveat as the block-overload: not part of the public CE.SDK
  /// Engine API, no-op for customers, only fires assertions under the
  /// IMG.LY test harness.
  @MainActor
  func captureGuide(
    data: Data,
    label: String,
    mimeType: MIMEType,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
  ) async throws {
    try await GuideCaptures.current.onCapture?(
      data, label, mimeType, fileID, filePath, line, column,
    )
  }
}
