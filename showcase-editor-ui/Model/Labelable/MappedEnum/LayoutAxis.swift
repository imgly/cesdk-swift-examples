import Foundation

enum LayoutAxis: String, MappedEnum {
  case vertical = "Vertical"
  case horizontal = "Horizontal"
  case depth = "Depth"

  var description: String { rawValue }

  var imageName: String? { nil }
}
