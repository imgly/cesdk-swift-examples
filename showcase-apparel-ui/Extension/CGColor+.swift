import CoreGraphics
import IMGLYEngine
import SwiftUI

extension CGColor {
  // Colors that stay the same when switching from light to dark color scheme.
  static let blue = Color.blue.asCGColor
  static let green = Color.green.asCGColor
  static let yellow = Color.yellow.asCGColor
  static let red = Color.red.asCGColor
  static let black = Color.black.asCGColor
  static let white = Color.white.asCGColor

  func rgba() throws -> RGBA {
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
          let color = converted(to: colorSpace, intent: .defaultIntent, options: nil),
          let components = color.components else {
      throw Error(errorDescription: "Could not convert CGColor to sRGB RGBA.")
    }

    let rgba = components.map { Float($0) }
    switch rgba.count {
    case 1:
      return RGBA(r: rgba[0], g: rgba[0], b: rgba[0], a: 1)
    case 2:
      return RGBA(r: rgba[0], g: rgba[0], b: rgba[0], a: rgba[1])
    case 3:
      return RGBA(r: rgba[0], g: rgba[1], b: rgba[2], a: 1)
    case 4...:
      return RGBA(r: rgba[0], g: rgba[1], b: rgba[2], a: rgba[3])
    default:
      throw Error(errorDescription: "Unsupported cgColor.components.count of \(rgba.count).")
    }
  }
}
