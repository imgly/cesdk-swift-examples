import SwiftUI

class AssetLibrary {
  struct Text {
    let url: URL
    let size: CGFloat
  }

  struct Image: Identifiable {
    var id: URL { url }
    let url: URL
    let label: String
  }

  struct Shape: Identifiable {
    var id: Interactor.BlockType { shape }
    let shape: Interactor.BlockType
    let imageName: String
    let label: LocalizedStringKey
  }

  let shapes = [
    (Interactor.BlockType.rectShape, "rect", "Rectangle"),
    (Interactor.BlockType.lineShape, "line", "Line"),
    (Interactor.BlockType.starShape, "star", "Star"),
    (Interactor.BlockType.polygonShape, "polygon", "Polygon")
  ].map {
    Shape(shape: $0.0, imageName: $0.1, label: $0.2)
  }

  struct Sticker: Identifiable {
    var id: URL { url }
    let url: URL
    let imageName: String
    let label: LocalizedStringKey
  }

  let stickers = [
    "gesture_okay",
    "gesture_thumbs_up",
    "palm_tree",
    "photo_frame",
    "popcorn",
    "rainbow",
    "snowflake",
    "vintage_eye",
    "vintage_nice_cool",
    "wow"
  ].enumerated().map { index, sticker in
    let url = Bundle.bundle.url(forResource: sticker, withExtension: "svg")!
    return Sticker(url: url, imageName: sticker, label: "Sticker \(index + 1)")
  }

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
