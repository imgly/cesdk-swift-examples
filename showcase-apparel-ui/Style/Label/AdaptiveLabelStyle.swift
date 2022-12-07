import SwiftUI

private struct AdaptiveLabelStyle<Compact: LabelStyle, Normal: LabelStyle>: LabelStyle {
  @Environment(\.verticalSizeClass) private var verticalSizeClass

  let compactStyle: Compact
  let normalStyle: Normal

  init(compactStyle: Compact, normalStyle: Normal) {
    self.compactStyle = compactStyle
    self.normalStyle = normalStyle
  }

  func makeBody(configuration: Configuration) -> some View {
    if verticalSizeClass == .compact {
      Label(configuration)
        .labelStyle(compactStyle)
    } else {
      Label(configuration)
        .labelStyle(normalStyle)
    }
  }
}

struct AdaptiveTileLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    Label(configuration)
      .labelStyle(AdaptiveLabelStyle(
        compactStyle: .tile(orientation: .horizontal),
        normalStyle: .tile(orientation: .vertical)
      ))
  }
}

struct AdaptiveIconOnlyLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    Label(configuration)
      .labelStyle(AdaptiveLabelStyle(compactStyle: .titleAndIcon, normalStyle: .iconOnly))
  }
}

struct AdaptiveTitleOnlyLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    Label(configuration)
      .labelStyle(AdaptiveLabelStyle(compactStyle: .titleAndIcon, normalStyle: .titleOnly))
  }
}
