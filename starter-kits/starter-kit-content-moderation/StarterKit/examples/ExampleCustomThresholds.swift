import Foundation

// highlight-starter-kit-custom-thresholds
/// Example: Adjust moderation thresholds based on your platform's needs.
///
/// Pass one of these to `ModerationStore(service:)` in place of the
/// service `ContentModerationEditorStarterKit` installs by default, or define your
/// own `ModerationThresholds`.
enum ExampleCustomThresholds {
  /// Family-friendly platforms flag content earlier.
  static func strictService(apiKey: String) -> ModerationService {
    GatewayModerationService(apiKey: apiKey, thresholds: .strict)
  }

  /// Adult-only platforms flag content later.
  static func relaxedService(apiKey: String) -> ModerationService {
    GatewayModerationService(apiKey: apiKey, thresholds: .relaxed)
  }

  /// Custom thresholds for platform-specific rules.
  static func customService(apiKey: String) -> ModerationService {
    GatewayModerationService(
      apiKey: apiKey,
      thresholds: ModerationThresholds(failed: 0.7, warning: 0.3),
    )
  }
}

// highlight-starter-kit-custom-thresholds
