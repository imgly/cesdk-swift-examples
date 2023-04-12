import Foundation

enum VerticalAlignment: String, MappedEnum {
  case top = "Top"
  case center = "Center"
  case bottom = "Bottom"

  var description: String {
    switch self {
    case .top: return "Align Top"
    case .center: return "Align Center"
    case .bottom: return "Align Bottom"
    }
  }

  var imageName: String? {
    switch self {
    case .top: return "arrow.up.to.line"
    case .center:
      if #available(iOS 16.0, *) {
        return "arrow.down.and.line.horizontal.and.arrow.up"
      } else {
        return "custom.arrow.down.and.line.horizontal.and.arrow.up"
      }
    case .bottom: return "arrow.down.to.line"
    }
  }

  var isSystemImage: Bool {
    switch self {
    case .center:
      if #available(iOS 16.0, *) {
        return true
      } else {
        return false
      }
    default: return true
    }
  }
}
