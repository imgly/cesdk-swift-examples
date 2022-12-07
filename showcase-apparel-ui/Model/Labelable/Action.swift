import Foundation

enum Action: CustomStringConvertible, Labelable {
  case undo, redo, previewMode, editMode, export, toTop, up, down, toBottom, duplicate, delete

  var description: String {
    switch self {
    case .undo: return "Undo"
    case .redo: return "Redo"
    case .previewMode: return "Preview"
    case .editMode: return "Edit"
    case .export: return "Export"
    case .toTop: return "To Top"
    case .up: return "Up"
    case .down: return "Down"
    case .toBottom: return "To Bottom"
    case .duplicate: return "Duplicate"
    case .delete: return "Delete"
    }
  }

  var systemImage: String {
    switch self {
    case .undo: return "arrow.uturn.backward.circle"
    case .redo: return "arrow.uturn.forward.circle"
    case .previewMode: return "eye"
    case .editMode: return "square.and.pencil"
    case .export: return "square.and.arrow.up"
    case .toTop: return "square.3.stack.3d.top.fill"
    case .up: return "square.2.stack.3d.top.fill"
    case .down: return "square.2.stack.3d.bottom.fill"
    case .toBottom: return "square.3.stack.3d.bottom.fill"
    case .duplicate: return "plus.square.on.square"
    case .delete: return "trash"
    }
  }
}
