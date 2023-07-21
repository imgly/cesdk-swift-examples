import Foundation

enum ColorFillType: String, MappedEnum {
  case solid = "Solid"
  case gradient = "Gradient"
  case none

  var description: String {
    switch self {
    case .solid: return "Solid"
    case .gradient: return "Gradient"
    case .none: return "None"
    }
  }

  var imageName: String? { nil }
}
