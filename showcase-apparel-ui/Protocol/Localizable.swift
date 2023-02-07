import SwiftUI

protocol Localizable: CustomStringConvertible {}

extension Localizable {
  var localizedStringKey: LocalizedStringKey {
    localizedStringKey(suffix: nil)
  }

  func localizedStringKey(suffix: String?) -> LocalizedStringKey {
    LocalizedStringKey(String(describing: self) + (suffix ?? ""))
  }
}
