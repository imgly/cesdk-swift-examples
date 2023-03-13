import Foundation

enum HorizontalAlignment: String, MappedEnum {
  case left = "Left"
  case center = "Center"
  case right = "Right"

  var description: String {
    switch self {
    case .left: return "Align Left"
    case .center: return "Align Center"
    case .right: return "Align Right"
    }
  }

  var imageName: String? {
    switch self {
    case .left: return "text.alignleft"
    case .center: return "text.aligncenter"
    case .right: return "text.alignright"
    }
  }
}
