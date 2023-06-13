import Foundation

extension Bundle {
  private final class CurrentBundleFinder {}

  static let bundle = Bundle(for: CurrentBundleFinder.self)
}
