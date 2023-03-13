import CoreGraphics
import SwiftUI

extension CGColor: HSBAConvertible {
  var hsba: HSBA? { HSBA(self) }
}

public extension CGColor {
  // Colors that stay the same when switching from light to dark color scheme.
  static let red = Color.red.asCGColor
  static let orange = Color.orange.asCGColor
  static let yellow = Color.yellow.asCGColor
  static let green = Color.green.asCGColor
  static let mint = Color.mint.asCGColor
  static let teal = Color.teal.asCGColor
  static let cyan = Color.cyan.asCGColor
  static let blue = Color.blue.asCGColor
  static let indigo = Color.indigo.asCGColor
  static let purple = Color.purple.asCGColor
  static let pink = Color.pink.asCGColor
  static let brown = Color.brown.asCGColor
  static let white = Color.white.asCGColor
  static let gray = Color.gray.asCGColor
  static let black = Color.black.asCGColor

  static func hex(_ hexString: String) -> CGColor? {
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      return nil
    }
    return .init(srgbRed: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}

extension CGColor {
  func rgba() throws -> Interactor.RGBA {
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
          let color = converted(to: colorSpace, intent: .defaultIntent, options: nil),
          let components = color.components else {
      throw Error(errorDescription: "Could not convert CGColor to sRGB RGBA.")
    }

    let rgba = components.map { Float($0) }
    switch rgba.count {
    case 1:
      return Interactor.RGBA(r: rgba[0], g: rgba[0], b: rgba[0], a: 1)
    case 2:
      return Interactor.RGBA(r: rgba[0], g: rgba[0], b: rgba[0], a: rgba[1])
    case 3:
      return Interactor.RGBA(r: rgba[0], g: rgba[1], b: rgba[2], a: 1)
    case 4...:
      return Interactor.RGBA(r: rgba[0], g: rgba[1], b: rgba[2], a: rgba[3])
    default:
      throw Error(errorDescription: "Unsupported cgColor.components.count of \(rgba.count).")
    }
  }
}