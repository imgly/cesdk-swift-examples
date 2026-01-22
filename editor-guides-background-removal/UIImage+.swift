import UIKit

public extension UIImage {
  /// Extension to fix orientation of an UIImage without EXIF
  func fixOrientation() -> UIImage {
    guard imageOrientation != .up else { return self }

    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
      draw(at: .zero)
    }
  }
}
