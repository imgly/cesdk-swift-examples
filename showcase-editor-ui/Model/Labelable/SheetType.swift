import Foundation

enum SheetType: Labelable, IdentifiableByHash {
  case image, text, shape, sticker, upload, group
  case selectionColors, font, fontSize, color

  var description: String {
    switch self {
    case .image: return "Image"
    case .text: return "Text"
    case .shape: return "Shape"
    case .sticker: return "Sticker"
    case .upload: return "Upload"
    case .group: return "Group"
    case .selectionColors: return "Template Colors"
    case .font: return "Font"
    case .fontSize: return "Size"
    case .color: return "Color"
    }
  }

  var imageName: String? {
    switch self {
    case .image: return "photo"
    case .text: return "textformat.alt"
    case .shape: return "square.on.circle"
    case .sticker: return "custom.face.smiling"
    case .upload: return "arrow.up.circle"
    case .group: return nil
    case .selectionColors, .font, .fontSize, .color: return nil
    }
  }

  var isSystemImage: Bool {
    switch self {
    case .sticker: return false
    default: return true
    }
  }
}
