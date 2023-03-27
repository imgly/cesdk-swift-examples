import Foundation

enum SheetType: Labelable, IdentifiableByHash {
  case text, image, shape, sticker, group, upload
  case selectionColors, font, fontSize, color

  var description: String {
    switch self {
    case .text: return "Text"
    case .image: return "Image"
    case .shape: return "Shape"
    case .sticker: return "Sticker"
    case .group: return "Group"
    case .upload: return "Upload"
    case .selectionColors: return "Template Colors"
    case .font: return "Font"
    case .fontSize: return "Size"
    case .color: return "Color"
    }
  }

  var imageName: String? {
    switch self {
    case .text: return "textformat.alt"
    case .image: return "photo"
    case .shape: return "square.on.circle"
    case .sticker: return "custom.face.smiling"
    case .group: return nil
    case .upload: return "square.and.arrow.up"
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
