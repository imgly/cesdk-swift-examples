import SwiftUI

struct ToolbarButtonStyle: PrimitiveButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button(configuration)
      .background(
        RoundedRectangle(cornerRadius: 11)
          .fill(.bar)
          .shadow(color: .black.opacity(0.1), radius: 4, y: 1)
      )
  }
}
