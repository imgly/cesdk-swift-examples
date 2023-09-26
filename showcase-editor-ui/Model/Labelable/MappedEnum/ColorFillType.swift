import Foundation

enum FillType: String, MappedEnum {
  case solid = "//ly.img.ubq/fill/color"
  case gradient = "//ly.img.ubq/fill/gradient/linear"
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
