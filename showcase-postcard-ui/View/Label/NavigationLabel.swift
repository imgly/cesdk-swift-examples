import SwiftUI

/// Label that looks like the original navigation back button.
struct NavigationLabel: View {
  enum Direction: String {
    case backward = "chevron.backward"
    case forward = "chevron.forward"
  }

  let title: LocalizedStringKey
  let direction: Direction

  init(_ title: LocalizedStringKey, direction: Direction) {
    self.title = title
    self.direction = direction
  }

  var body: some View {
    HStack(spacing: 4.5) {
      switch direction {
      case .backward:
        Image(systemName: direction.rawValue)
          .font(.headline)
          .padding(.leading, -8)
        Text(title)
      case .forward:
        Text(title)
        Image(systemName: direction.rawValue)
          .font(.headline)
          .padding(.trailing, -8)
      }
    }
    .padding(.bottom, 0.5)
  }
}
