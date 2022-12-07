import Foundation

enum TextProperty: CustomStringConvertible, IdentifiableByHash, Labelable, CaseIterable {
  case notAvailable, bold, italic, alignLeft, alignCenter, alignRight

  var description: String {
    switch self {
    case .notAvailable: return "Not Available"
    case .bold: return "Bold"
    case .italic: return "Italic"
    case .alignLeft: return "Align Left"
    case .alignCenter: return "Align Center"
    case .alignRight: return "Align Right"
    }
  }

  var systemImage: String {
    switch self {
    case .notAvailable: return "exclamationmark.triangle.fill"
    case .bold: return "bold"
    case .italic: return "italic"
    case .alignLeft: return "text.alignleft"
    case .alignCenter: return "text.aligncenter"
    case .alignRight: return "text.alignright"
    }
  }
}
