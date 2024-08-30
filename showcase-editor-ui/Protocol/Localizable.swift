import SwiftUI

public protocol Localizable: CustomStringConvertible {}

public extension Localizable {
  var localizedStringKey: LocalizedStringKey {
    localizedStringKey(suffix: nil)
  }

  func localizedStringKey(suffix: String?) -> LocalizedStringKey {
    LocalizedStringKey(String(describing: self) + (suffix ?? ""))
  }
}
