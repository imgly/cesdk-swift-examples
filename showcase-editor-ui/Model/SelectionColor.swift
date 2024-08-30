import SwiftUI

struct SelectionColor: Identifiable, Localizable {
  var description: String {
    guard let hsba = color.hsba else {
      return ""
    }
    return String(describing: hsba)
  }

  var id: CGColor { color }
  let color: CGColor
  let binding: Binding<CGColor>
}
