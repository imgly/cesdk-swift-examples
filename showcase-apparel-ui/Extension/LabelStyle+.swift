import SwiftUI

extension LabelStyle where Self == TileLabelStyle {
  static func tile(orientation: Self.Orientation) -> Self { Self(orientation: orientation) }
}

extension LabelStyle where Self == HiddenIconLabelStyle {
  static func icon(hidden: Bool) -> Self { Self(hidden: hidden) }
}

extension LabelStyle where Self == AdaptiveTileLabelStyle {
  static var adaptiveTile: Self { Self() }
}

extension LabelStyle where Self == AdaptiveIconOnlyLabelStyle {
  static var adaptiveIconOnly: Self { Self() }
}

extension LabelStyle where Self == AdaptiveTitleOnlyLabelStyle {
  static var adaptiveTitleOnly: Self { Self() }
}
