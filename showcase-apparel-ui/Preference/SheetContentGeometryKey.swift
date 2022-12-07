import SwiftUI

struct SheetContentGeometryKey: PreferenceKey {
  static let defaultValue: Geometry? = nil
  static func reduce(value: inout Geometry?, nextValue: () -> Geometry?) {
    value = value ?? nextValue()
  }
}
