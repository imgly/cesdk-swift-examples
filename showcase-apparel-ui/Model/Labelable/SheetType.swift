import Foundation

enum SheetType: Labelable {
  case text, image, shape, sticker

  var description: String {
    switch self {
    case .text: return "Text"
    case .image: return "Image"
    case .shape: return "Shape"
    case .sticker: return "Sticker"
    }
  }

  var imageName: String? {
    switch self {
    case .text: return "textformat.alt"
    case .image: return "photo"
    case .shape: return "square.on.circle"
    case .sticker: return "face.smiling"
    }
  }
}
