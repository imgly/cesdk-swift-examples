import IMGLYEngine
import SwiftUI

/// A look for the whole slideshow, offered in the Styles sheet.
///
/// The bundled files a style needs, its looping backdrop and its picker thumbnail, come from the
/// ``MemoriesStyleApplier/sourceID`` asset source. A style refers to them by ID, never by file path.
struct MemoriesStyle: Identifiable {
  /// The backdrop a style paints behind the media once the media is scaled below full-bleed.
  enum Background {
    /// No backdrop: the media fills the page.
    case none
    /// A flat color behind the media.
    case solid(IMGLYEngine.Color)
    /// A looping clip from the style asset source, dimmed to `opacity` against the black page.
    /// The engine plays a Lottie through a video fill the same way as an MP4, so either works here.
    case video(assetID: String, opacity: Float = 0.5)
  }

  /// Stable lowercase identifier, also the asset ID of the style's thumbnail.
  let id: String
  let displayName: String
  /// Typeface name as it appears in the `ly.img.typeface` asset source.
  let typeface: String
  /// Preferred font sub-families, most preferred first. Falls back to the typeface's first font.
  let fontWeights: [String]
  /// Adjustment effect properties, such as `("effect/adjustments/saturation", -1)`.
  var adjustments: [(property: String, value: Float)] = []
  /// How much of the page the media fills. 1 is full-bleed; less reveals the ``background``.
  var mediaScale: Float = 1
  var background: Background = .none
  var titleColor: IMGLYEngine.Color = .rgba(r: 1, g: 1, b: 1, a: 1)
  /// How one slide becomes the next. The transition is as much of a style's character as its filter.
  var transition = MemoriesTransition(type: .crossFade)
  /// The picker tile color behind the thumbnail.
  let previewBackground: SwiftUI.Color
}

/// The catalog of styles. To add, remove or tune a style, edit ``all``; ``MemoriesStyleApplier``
/// reads everything it needs from the style.
@MainActor
enum MemoriesStyles {
  /// Neutral: clean modern sans, full-bleed media, no filter or backdrop.
  static let `default` = MemoriesStyle(
    id: "default",
    displayName: "Default",
    typeface: "Montserrat",
    fontWeights: ["SemiBold", "Medium", "Regular"],
    // A long, unhurried dissolve that gets out of the way.
    transition: MemoriesTransition(type: .crossFade),
    previewBackground: SwiftUI.Color(red: 0.94, green: 0.92, blue: 0.91),
  )

  /// Black and white on a white backdrop, with black title type.
  static let noir = MemoriesStyle(
    id: "noir",
    displayName: "Noir",
    typeface: "Playfair Display",
    fontWeights: ["Bold", "SemiBold"],
    adjustments: [
      ("effect/adjustments/saturation", -1),
      ("effect/adjustments/contrast", 0.15),
      ("effect/adjustments/clarity", 0.1),
    ],
    mediaScale: 0.8,
    background: .solid(.rgba(r: 1, g: 1, b: 1, a: 1)),
    titleColor: .rgba(r: 0, g: 0, b: 0, a: 1),
    // Cutting through black is the film-editorial move, and it reads as intent against the white.
    transition: MemoriesTransition(type: .fadeToBlack, duration: 1.8),
    previewBackground: SwiftUI.Color(white: 0.13),
  )

  /// A cool cast over a looping hologram backdrop.
  static let hologram = MemoriesStyle(
    id: "hologram",
    displayName: "Hologram",
    typeface: "VT323",
    fontWeights: ["Regular"],
    adjustments: [
      ("effect/adjustments/temperature", -0.4),
      ("effect/adjustments/contrast", 0.1),
    ],
    mediaScale: 0.8,
    background: .video(assetID: "hologram"),
    // A short warp, so the slides look retransmitted rather than dissolved.
    transition: MemoriesTransition(type: .crossWarp, duration: 1.2) { engine, transition in
      try engine.block.setFloat(transition, property: "transition/cross-warp/zoom", value: 0.85)
    },
    previewBackground: SwiftUI.Color(red: 0.88, green: 0.96, blue: 1),
  )

  /// A playful, saturated filter over a looping bubblegum backdrop.
  static let bubblegum = MemoriesStyle(
    id: "bubblegum",
    displayName: "Bubblegum",
    typeface: "Lobster Two",
    fontWeights: ["Bold", "Regular"],
    adjustments: [
      ("effect/adjustments/saturation", 0.5),
      ("effect/adjustments/brightness", 0.05),
      ("effect/adjustments/contrast", 0.1),
    ],
    mediaScale: 0.8,
    background: .video(assetID: "bubblegum"),
    // A pink wipe sweeping up: the hard-edged counterpart to a dissolve.
    // highlight-starter-kit-transition-spec
    transition: MemoriesTransition(type: .colorWipe, duration: 1) { engine, transition in
      try engine.block.setEnum(transition, property: "transition/color-wipe/direction", value: "Up")
      try engine.block.setColor(transition, property: "transition/color-wipe/color",
                                color: .rgba(r: 1, g: 0.31, b: 0.64, a: 1))
    },
    // highlight-starter-kit-transition-spec
    previewBackground: SwiftUI.Color(red: 0.99, green: 0.89, blue: 0.93),
  )

  /// All styles, in the order of the Styles sheet.
  static let all = [`default`, noir, hologram, bubblegum]

  /// The style with `id`, or ``default``.
  static func style(id: String) -> MemoriesStyle {
    all.first { $0.id == id } ?? MemoriesStyles.default
  }
}
