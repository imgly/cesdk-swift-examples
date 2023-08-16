import SwiftUI

enum SizeLetter: String, Localizable {
  case small = "Small"
  case medium = "Medium"
  case large = "Large"

  var description: String { rawValue }
}

extension SizeLetter {
  init(_ fontSize: Float) {
    switch fontSize {
    case ...Self.small.fontSize: self = .small
    case ...Self.medium.fontSize: self = .medium
    default: self = .large
    }
  }

  var fontSize: Float {
    switch self {
    case .small: return 14
    case .medium: return 18
    case .large: return 22
    }
  }

  var sizeLetter: String {
    switch self {
    case .small: return "S"
    case .medium: return "M"
    case .large: return "L"
    }
  }

  @ViewBuilder func icon(_ style: SwiftUI.Font.TextStyle) -> some View {
    Text(sizeLetter)
      .font(.system(style, design: .rounded))
  }
}
