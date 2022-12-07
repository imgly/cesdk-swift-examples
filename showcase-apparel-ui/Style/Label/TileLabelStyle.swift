import SwiftUI

struct TileLabelStyle: LabelStyle {
  enum Orientation {
    case vertical, horizontal
  }

  let orientation: Orientation

  private func title(_ configuration: Configuration) -> some View {
    configuration.title
      .font(.footnote)
  }

  private func icon(_ configuration: Configuration) -> some View {
    configuration.icon
      .font(.title2)
      .frame(height: 26)
  }

  func makeBody(configuration: Configuration) -> some View {
    if orientation == .horizontal {
      HStack {
        icon(configuration)
        title(configuration)
      }
      .frame(idealWidth: 83 + 33, maxWidth: .infinity)
      .frame(height: 33)
    } else {
      VStack(spacing: 4) {
        icon(configuration)
        title(configuration)
      }
      .frame(idealWidth: 83, maxWidth: .infinity)
      .frame(height: 60)
    }
  }
}
