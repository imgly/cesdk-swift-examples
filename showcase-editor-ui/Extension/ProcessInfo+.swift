import Foundation

public extension ProcessInfo {
  static var isUITesting: Bool { ProcessInfo.processInfo.arguments.contains("UI-Testing") }
}
