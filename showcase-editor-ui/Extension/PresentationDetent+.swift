import SwiftUI
import SwiftUIBackports

enum PresentationDetent: Comparable {
  case small, medium, large

  /// If enabled detents with custom heights are used if iOS 16 is available.
  static let customDetentsEnabled = true

  var backport: Backport<Any>.PresentationDetent {
    switch self {
    case .small: return .medium
    case .medium: return .medium
    case .large: return .large
    }
  }

  @available(iOS 16.0, *)
  var detent: SwiftUI.PresentationDetent {
    if Self.customDetentsEnabled {
      switch self {
      case .small: return .adaptiveSmall
      case .medium: return .adaptiveMedium
      case .large: return .adaptiveLarge
      }
    } else {
      switch self {
      case .small: return .medium
      case .medium: return .medium
      case .large: return .large
      }
    }
  }

  var identifier: UISheetPresentationController.Detent.Identifier? {
    if Self.customDetentsEnabled, #available(iOS 16.0, *) {
      switch self {
      case .small: return AdaptiveSmallPresentationDetent.identifier
      case .medium: return AdaptiveMediumPresentationDetent.identifier
      case .large: return AdaptiveLargePresentationDetent.identifier
      }
    } else {
      switch self {
      case .small: return .medium
      case .medium: return .medium
      case .large: return .large
      }
    }
  }

  init?(backport: Backport<Any>.PresentationDetent) {
    switch backport {
    case .medium: self = .medium
    case .large: self = .large
    default:
      print(backport)
      return nil
    }
  }

  @available(iOS 16.0, *)
  init?(detent: SwiftUI.PresentationDetent) {
    switch detent {
    case .medium: self = .medium
    case .large: self = .large
    case .adaptiveSmall: self = .small
    case .adaptiveMedium: self = .medium
    case .adaptiveLarge: self = .large
    default:
      print(detent)
      return nil
    }
  }
}

extension Binding where Value == PresentationDetent {
  var backport: Binding<Backport<Any>.PresentationDetent> {
    .init {
      wrappedValue.backport
    } set: {
      if let value = PresentationDetent(backport: $0) {
        wrappedValue = value
      }
    }
  }

  @available(iOS 16.0, *)
  var detent: Binding<SwiftUI.PresentationDetent> {
    .init {
      wrappedValue.detent
    } set: {
      if let value = PresentationDetent(detent: $0) {
        wrappedValue = value
      }
    }
  }
}

@available(iOS 16.0, *)
extension SwiftUI.PresentationDetent {
  static let adaptiveSmall = Self.custom(AdaptiveSmallPresentationDetent.self)
  static let adaptiveMedium = Self.custom(AdaptiveMediumPresentationDetent.self)
  static let adaptiveLarge = Self.custom(AdaptiveLargePresentationDetent.self)
}

@available(iOS 16.0, *)
extension CustomPresentationDetent {
  static var identifier: UISheetPresentationController.Detent.Identifier {
    let typeName = String(describing: Self.self)
    return .init("Custom:" + typeName)
  }
}

@available(iOS 16.0, *)
private struct AdaptiveSmallPresentationDetent: CustomPresentationDetent {
  static func height(in _: Context) -> CGFloat? {
    160
  }
}

@available(iOS 16.0, *)
private struct AdaptiveMediumPresentationDetent: CustomPresentationDetent {
  static func height(in context: Context) -> CGFloat? {
    if context.verticalSizeClass == .compact {
      return 160
    } else {
      return 340
    }
  }
}

@available(iOS 16.0, *)
private struct AdaptiveLargePresentationDetent: CustomPresentationDetent {
  static func height(in context: Context) -> CGFloat? {
    context.maxDetentValue * 0.95
  }
}
