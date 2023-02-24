import Foundation

enum SheetMode: Labelable, IdentifiableByHash {
  case add, replace, edit, style, arrange

  var description: String {
    switch self {
    case .add: return "Add"
    case .replace: return "Replace"
    case .edit: return "Edit"
    case .style: return "Style"
    case .arrange: return "Arrange"
    }
  }

  var imageName: String? {
    switch self {
    case .add: return "plus"
    case .replace: return "arrow.triangle.swap"
    case .edit: return "keyboard"
    case .style: return "paintbrush"
    case .arrange: return "square.3.layers.3d.down.left"
    }
  }
}
