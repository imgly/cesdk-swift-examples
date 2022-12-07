import SwiftUI

struct HiddenIconLabelStyle: LabelStyle {
  let hidden: Bool

  func makeBody(configuration: Configuration) -> some View {
    HStack {
      if hidden {
        configuration.icon.hidden()
      } else {
        configuration.icon
      }
      configuration.title
    }
  }
}
