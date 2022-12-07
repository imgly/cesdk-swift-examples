import SwiftUI

protocol Localizable {}

extension Localizable {
  var localizedStringKey: LocalizedStringKey {
    localizedStringKey(suffix: nil)
  }

  func localizedStringKey(suffix: String?) -> LocalizedStringKey {
    LocalizedStringKey(String(describing: self) + (suffix ?? ""))
  }
}
