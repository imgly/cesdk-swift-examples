import SwiftUI

struct CanvasMenuSizeKey: PreferenceKey {
  static let defaultValue: CGSize? = nil
  static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
    value = value ?? nextValue()
  }
}
