@testable import Guides
import XCTest

@MainActor
class QuickstartTest: XCTestCase {
  func testIntegrateWithSwiftUI() {
    _ = IntegrateWithSwiftUI().body
  }

  #if os(iOS)
    func testIntegrateWithUIKit() {
      _ = IntegrateWithUIKit(nibName: nil, bundle: nil).view
    }
  #endif

  #if os(macOS)
    func testIntegrateWithAppKit() {
      _ = IntegrateWithAppKit(nibName: nil, bundle: nil).view
    }
  #endif
}
