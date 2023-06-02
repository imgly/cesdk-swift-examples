@testable import Guides
import XCTest

@MainActor
class QuickstartTest: XCTestCase {
  func testIntegrateWithSwiftUI() {
    _ = IntegrateWithSwiftUI().body
  }

  func testIntegrateWithUIKit() {
    _ = IntegrateWithUIKit().view
  }
}
