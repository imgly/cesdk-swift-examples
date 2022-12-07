import SwiftUI

extension View {
  func canvasAction(anchor: UnitPoint = .top, @ViewBuilder action: @escaping () -> some View) -> some View {
    modifier(CanvasAction(anchor: anchor, action: action))
  }

  func errorAlert(isSheet: Bool) -> some View {
    modifier(ErrorAlert(isSheet: isSheet))
  }

  func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
    background(WillDisappearHandler(onWillDisappear: perform))
  }

  func nonDefaultPreviewSettings() -> some View {
    previewDisplayName("Landscape, dark mode, RTL")
      .previewInterfaceOrientation(.landscapeRight)
      .preferredColorScheme(.dark)
      .environment(\.layoutDirection, .rightToLeft)
  }
}
