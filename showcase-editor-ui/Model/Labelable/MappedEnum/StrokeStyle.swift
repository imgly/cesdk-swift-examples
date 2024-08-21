import Foundation

enum StrokeStyle: String, MappedEnum {
  case solid = "Solid"
  case dashed = "Dashed"
  case dashedRound = "DashedRound"
  case longDashed = "LongDashed"
  case longDashedRound = "LongDashedRound"
  case dotted = "Dotted"

  var description: String {
    switch self {
    case .solid: return "Solid"
    case .dashed: return "Dashed"
    case .dashedRound: return "Dashed Round"
    case .longDashed: return "Long Dashed"
    case .longDashedRound: return "Long Dashed Round"
    case .dotted: return "Dotted"
    }
  }

  var imageName: String? { nil }
}
