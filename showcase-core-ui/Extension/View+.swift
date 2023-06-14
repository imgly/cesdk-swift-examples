import SwiftUI

// MARK: - Public interface

public extension View {
  func nonDefaultPreviewSettings() -> some View {
    previewDisplayName("Landscape, dark mode, RTL")
      .previewInterfaceOrientation(.landscapeRight)
      .preferredColorScheme(.dark)
      .environment(\.layoutDirection, .rightToLeft)
  }
}

extension View {
  func inverseMask(alignment: Alignment = .center, @ViewBuilder _ mask: () -> some View) -> some View {
    self.mask {
      Rectangle()
        .overlay(alignment: alignment) {
          mask()
            .blendMode(.destinationOut)
        }
    }
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
