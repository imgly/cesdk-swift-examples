import IMGLYEngine
import SwiftUI

class AssetLibrary {
  struct Image: Identifiable {
    var id: URL { url }
    let url: URL
    let label: LocalizedStringKey
  }

  let images = [
    "image2.jpg",
    "image1.jpg",
    "image4.png",
    "image3.png"
  ].enumerated().map { index, image in
    let url = Bundle.bundle.url(forResource: image, withExtension: nil)!
    return Image(url: url, label: "Image \(index + 1)")
  }

  struct Shape: Identifiable {
    var id: DesignBlockType { shape }
    let shape: DesignBlockType
    let imageName: String
    let label: LocalizedStringKey
  }

  let shapes = [
    (DesignBlockType.rectShape, "rect", "Rectangle"),
    (DesignBlockType.lineShape, "line", "Line"),
    (DesignBlockType.starShape, "star", "Star"),
    (DesignBlockType.polygonShape, "polygon", "Polygon")
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
    "hand_friends",
    "hand_vibes",
    "hand_five",
    "hand_fuck"
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
