import SwiftUI

extension PresentationDetent {
  static let adaptiveSmall = PresentationDetent.custom(AdaptiveSmallPresentationDetent.self)
  static let adaptiveMedium = PresentationDetent.custom(AdaptiveMediumPresentationDetent.self)
  static let adaptiveLarge = PresentationDetent.custom(AdaptiveLargePresentationDetent.self)

  var identifier: UISheetPresentationController.Detent.Identifier? {
    switch self {
    case .large: return .large
    case .medium: return .medium
    case .adaptiveSmall: return AdaptiveSmallPresentationDetent.identifier
    case .adaptiveMedium: return AdaptiveMediumPresentationDetent.identifier
    case .adaptiveLarge: return AdaptiveLargePresentationDetent.identifier
    default: return nil
    }
  }
}

extension CustomPresentationDetent {
  static var identifier: UISheetPresentationController.Detent.Identifier {
    let typeName = String(describing: Self.self)
    return .init("Custom:" + typeName)
  }
}

private struct AdaptiveSmallPresentationDetent: CustomPresentationDetent {
  static func height(in _: Context) -> CGFloat? {
    160
  }
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

private struct AdaptiveLargePresentationDetent: CustomPresentationDetent {
  static func height(in context: Context) -> CGFloat? {
    context.maxDetentValue * 0.95
  }
}
