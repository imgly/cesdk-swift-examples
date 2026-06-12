import Foundation
import IMGLYEngine

extension Engine {
  /// The single source of truth for where the example guides load their sample
  /// assets from when nothing else is configured: the public CE.SDK CDN.
  ///
  /// For production you should host the assets yourself (or ship them in your
  /// app bundle) and provide your own base URL — see
  /// https://img.ly/docs/cesdk/swift/guides/serve-assets/.
  static let guidesFallbackBaseURL = URL(
    string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.77.0-rc.0/assets",
  )!

  /// Base URL the example guides resolve their sample assets against.
  ///
  /// Returns the engine's `basePath` setting when it is set, and otherwise
  /// falls back to ``guidesFallbackBaseURL`` so the example runs as-is.
  @MainActor
  var guidesBaseURL: URL {
    get throws {
      let basePath = try editor.getSettingString("basePath")
      guard !basePath.isEmpty, let url = URL(string: basePath) else {
        return Self.guidesFallbackBaseURL
      }
      return url
    }
  }
}
