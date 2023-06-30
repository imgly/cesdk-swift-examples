import SwiftUI

struct GridItemBackground: View {
  @Environment(\.colorScheme) private var colorScheme

  private var gradientColors: [Color] {
    var colors: [Color] = [.init(uiColor: .quaternarySystemFill),
                           .init(uiColor: .systemFill)]
    if colorScheme == .dark {
      colors.reverse()
    }
    return colors
  }

  var body: some View {
    RoundedRectangle(cornerRadius: 13)
      .fill(.linearGradient(.init(colors: gradientColors),
                            startPoint: .top, endPoint: .bottom))
  }
}
