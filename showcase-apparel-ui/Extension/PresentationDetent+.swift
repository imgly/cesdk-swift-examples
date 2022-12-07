import SwiftUI

extension PresentationDetent {
  static let adaptiveMedium = PresentationDetent.custom(AdaptiveMediumPresentationDetent.self)
}

private struct AdaptiveMediumPresentationDetent: CustomPresentationDetent {
  static func height(in context: Context) -> CGFloat? {
    if context.verticalSizeClass == .compact {
      return 160
    } else {
      return 340
    }
  }
}
