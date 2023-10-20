import SwiftUI

class AssetLibrary {
  struct Text {
    let url: URL
    let size: CGFloat
  }

  static let shapeSourceID = "ly.img.vectorpath.showcase"
  static let stickerSourceID = "ly.img.sticker.showcase"

  var fonts: [FontFamily] = []

  func fontFamilyFor(id fontFamilyID: String) -> FontFamily? {
    fonts.first { family in
      family.id == fontFamilyID
    }
  }

  func fontFor(id fontID: String) -> FontPair? {
    for family in fonts {
      if let font = family.fontFor(id: fontID) {
        return .init(family: family, font: font)
      }
    }
    return nil
  }

  func fontFor(url fontURL: URL) -> FontPair? {
    for family in fonts {
      if let font = family.fontFor(url: fontURL) {
        return .init(family: family, font: font)
      }
    }
    return nil
  }
}
