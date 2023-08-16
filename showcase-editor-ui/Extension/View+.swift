import SwiftUI

// MARK: - Public interface

public extension View {
  func nonDefaultPreviewSettings() -> some View {
    previewDisplayName("Landscape, dark mode, RTL")
      .previewInterfaceOrientation(.landscapeRight)
      .preferredColorScheme(.dark)
      .environment(\.layoutDirection, .rightToLeft)
  }

  @MainActor
  func interactor(_ interactor: Interactor) -> some View {
    selection(interactor.selection?.blocks.first)
      .environmentObject(interactor)
  }

  func colorPalette(_ colors: [NamedColor]?) -> some View {
    environment(\.colorPalette, colors ?? ColorPaletteKey.defaultValue)
  }

  func fontFamilies(_ families: [String]?) -> some View {
    environment(\.fontFamilies, families ?? FontFamiliesKey.defaultValue)
  }
}

extension View {
  func selection(_ id: Interactor.BlockID?) -> some View {
    environment(\.selection, id)
  }

  func canvasAction(anchor: UnitPoint = .top, @ViewBuilder action: @escaping () -> some View) -> some View {
    modifier(CanvasAction(anchor: anchor, action: action))
  }

  func errorAlert(isSheet: Bool) -> some View {
    modifier(ErrorAlert(isSheet: isSheet))
  }

  func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
    background(WillDisappearHandler(onWillDisappear: perform))
  }

  func onReceive(
    _ name: Notification.Name,
    center: NotificationCenter = .default,
    object: AnyObject? = nil,
    perform action: @escaping (Notification) -> Void
  ) -> some View {
    onReceive(center.publisher(for: name, object: object), perform: action)
  }
}
