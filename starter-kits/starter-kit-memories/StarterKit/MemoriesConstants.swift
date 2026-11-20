import Foundation

/// The knobs for the slideshow. Tweak these to retime, resize, or restyle the montage.
enum MemoriesConstants {
  /// The slideshow page size. Portrait by default; square is 1080 x 1080, landscape 1920 x 1080.
  static let pageWidth: Float = 1080
  static let pageHeight: Float = 1920

  /// Inset in points that keeps the page off the screen edges and the bottom controls.
  static let canvasPadding: CGFloat = 10

  /// Seconds each photo stays on screen.
  static let imageDuration: Double = 8

  /// Seconds two slides overlap by default. A style can ask for its own overlap
  /// (``MemoriesStyle/transition``), and the engine clamps any overlap to half of the shorter clip.
  static let overlapDuration = imageDuration * 0.4

  /// Seconds the title card stays on screen.
  static let titleDuration: Double = 3
  static let titleFontSize: Float = 48

  /// Images flashed behind the title.
  static let burstImageCount = 10
  /// The burst spans this fraction of the title duration.
  static let burstTitleFraction = 0.9

  /// Seconds the loading screen stays at least, so that it does not flash.
  static let minimumLoadingDuration: Double = 2
}
