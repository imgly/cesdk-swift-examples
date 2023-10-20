import CoreGraphics
import IMGLYEngine

extension RGBA {
  func color() throws -> CGColor {
    let components = [r, g, b, a].map { CGFloat($0) }
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
          let color = CGColor(colorSpace: colorSpace, components: components) else {
      throw Error(errorDescription: "Could not convert sRGB RGBA to CGColor.")
    }

    return color
  }
}
