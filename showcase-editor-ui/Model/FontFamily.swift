import UIKit

struct FontPair {
  let family: FontFamily
  let font: Font
}

struct FontProperties: Equatable {
  let bold: Bool?
  let italic: Bool?
}

enum FontType {
  case regular, boldItalic, bold, italic, some, title, headline, body
}

struct FontFamily: Identifiable, Comparable {
  static func < (lhs: FontFamily, rhs: FontFamily) -> Bool {
    lhs.id < rhs.id
  }

  var id: String { name }

  static let defaultName = "Roboto"

  let name: String
  private let fonts: [String: Font]

  init(name: String, fonts: [Font]) {
    self.name = name
    self.fonts = Dictionary(fonts.map { ($0.id, $0) }) { first, _ in
      first
    }
  }

  func fontFor(id: String) -> Font? {
    fonts[id]
  }

  func fontFor(url: URL) -> Font? {
    let font = fonts.first { (_, font: Font) in
      font.url == url
    }
    return font?.value
  }

  var regularFont: Font? { font(for: .init(bold: false, italic: false)) }
  var boldItalicFont: Font? { font(for: .init(bold: true, italic: true)) }
  var boldFont: Font? { font(for: .init(bold: true, italic: false)) }
  var italicFont: Font? { font(for: .init(bold: false, italic: true)) }

  var hasRegular: Bool { regularFont != nil }
  var hasBoldItalic: Bool { boldItalicFont != nil }
  var hasBold: Bool { boldFont != nil }
  var hasItalic: Bool { italicFont != nil }

  private var firstSortedFont: Font? { fonts.values.sorted().first }

  var someFont: Font? {
    regularFont ?? boldFont ?? italicFont ?? boldItalicFont ?? firstSortedFont
  }

  var titleFont: Font? {
    font(weights: [700, 800, 900, 600, 500], or: .bold) ?? firstSortedFont
  }

  var headlineFont: Font? {
    font(weights: [500, 600, 700], or: .medium) ?? firstSortedFont
  }

  var bodyFont: Font? {
    font(weights: [400, 300, 500], or: .normal) ?? firstSortedFont
  }

  var someFontName: String?
  var titleFontName: String?
  var headlineFontName: String?
  var bodyFontName: String?

  func font(_ type: FontType) -> Font? {
    switch type {
    case .regular: return regularFont
    case .boldItalic: return boldItalicFont
    case .bold: return boldFont
    case .italic: return italicFont
    case .some: return someFont
    case .title: return titleFont
    case .headline: return headlineFont
    case .body: return bodyFont
    }
  }

  func fontName(_ type: FontType) -> String? {
    switch type {
    case .some: return someFontName
    case .title: return titleFontName
    case .headline: return headlineFontName
    case .body: return bodyFontName
    default: return nil
    }
  }

  mutating func setFontName(_ type: FontType, value: String?) {
    switch type {
    case .some: someFontName = value
    case .title: titleFontName = value
    case .headline: headlineFontName = value
    case .body: bodyFontName = value
    default: break
    }
  }

  func font(weights: [Int], or weight: FontWeightEnum, isItalic: Bool = false) -> Font? {
    for w in weights {
      let font = fonts.values.first { font in
        font.isItalic == isItalic &&
          (font.fontWeight == .integer(w) ||
            font.fontWeight == .enumeration(weight))
      }
      if let font {
        return font
      }
    }
    return nil
  }

  func font(for properties: FontProperties) -> Font? {
    fonts.values.first { font in
      switch properties {
      case .init(bold: false, italic: false): return font.isRegular && !font.isItalic
      case .init(bold: true, italic: false): return font.isBold && !font.isItalic
      case .init(bold: true, italic: true): return font.isBold && font.isItalic
      case .init(bold: false, italic: true): return font.isRegular && font.isItalic
      default:
        return false
      }
    }
  }

  func fontProperties(for fontID: String?) -> FontProperties? {
    guard let fontID, let font = fonts[fontID] else {
      return nil
    }

    switch (hasRegular, hasBoldItalic, hasBold, hasItalic) {
    case (true, true, true, true):
      return FontProperties(bold: font.isBold, italic: font.isItalic)
    case (true, false, false, true):
      return FontProperties(bold: nil, italic: font.isItalic)
    case (true, false, true, false):
      return FontProperties(bold: font.isBold, italic: nil)
    default:
      return nil
    }
  }
}

private func loadFontData(_ fonts: [Font], basePath: URL) async -> [String: Data] {
  await withThrowingTaskGroup(of: (String, Data).self) { group -> [String: Data] in
    for font in fonts {
      let url = basePath.appending(path: font.fontPath)
      group.addTask {
        let (data, _) = try await URLSession.shared.data(from: url)
        return (font.id, data)
      }
    }

    var downloads = [String: Data]()

    while let result = await group.nextResult() {
      if let download = try? result.get() {
        downloads[download.0] = download.1
      }
    }

    return downloads
  }
}

func loadFonts() async throws -> [FontFamily] {
  let basePath = Interactor.basePath.appending(path: Font.basePath.path())
  let url = basePath.appending(path: "manifest.json")
  let (data, _) = try await URLSession.shared.data(from: url)
  let decoder = JSONDecoder()
  let fonts = try decoder.decode(Manifest.self, from: data).assets.first?.assets ?? []

  let families = Dictionary(grouping: fonts) { $0.fontFamily }
  var fontFamilies = families.map { (family: String, fonts: [Font]) in
    FontFamily(name: family, fonts: fonts)
  }
  .sorted()

  func fontTypes(for family: FontFamily) -> [FontType] {
    if family.name == FontFamily.defaultName {
      return [.some, .title, .headline, .body]
    } else {
      return [.some]
    }
  }

  let previewFonts = fontFamilies.flatMap { family in
    fontTypes(for: family).compactMap { family.font($0) }
  }
  let previewFontData = await loadFontData(previewFonts, basePath: basePath)
  let previewFontNames = await FontImporter.importFonts(previewFontData)

  for (index, family) in fontFamilies.enumerated() {
    fontTypes(for: family).forEach {
      if let fontID = family.font($0)?.id {
        fontFamilies[index].setFontName($0, value: previewFontNames[fontID])
      }
    }
  }

  return fontFamilies
}

@MainActor
enum FontImporter {
  private static var registeredFontNames = [String]()

  static func importFonts(_ fonts: [String: Data]) -> [String: String] {
    // There is a bug in Apple's font loading system, dating back to at least 2010
    // (https://lists.apple.com/archives/cocoa-dev/2010/Sep/msg00450.html and
    // http://www.openradar.me/18778790) which can lead to a deadlock when loading custom fonts.
    // This seems to happen very rarely and has only been reproduced with iOS 10 so far, but adding
    // the below line works around the issue, so we're adding it to be on the safe side.
    _ = UIFont()

    var fontIDtoName = [String: String]()

    for font in fonts {
      guard
        let provider = CGDataProvider(data: font.value as CFData),
        let cgfont = CGFont(provider) else {
        continue
      }

      var error: Unmanaged<CFError>?

      guard let fontName = cgfont.postScriptName as String? else {
        continue
      }

      fontIDtoName[font.key] = fontName

      if registeredFontNames.contains(fontName) {
        // Font has already been registered
        continue
      }

      let registered = CTFontManagerRegisterGraphicsFont(cgfont, &error)

      if !registered {
        if let error = error?.takeUnretainedValue() as Swift.Error? {
          print("Failed to register font, error: \(error.localizedDescription)")
        }
      } else {
        registeredFontNames.append(fontName)
      }
    }

    return fontIDtoName
  }
}

extension Font: Comparable {
  static func < (lhs: Font, rhs: Font) -> Bool {
    lhs.id < rhs.id
  }

  static let basePath = URL(string: "/extensions/ly.img.cesdk.fonts")!

  var url: URL { Font.basePath.appending(path: fontPath) }

  var isRegular: Bool {
    switch fontWeight {
    case .integer(400): return true
    case .enumeration(.normal): return true
    default: return false
    }
  }

  var isBold: Bool {
    switch fontWeight {
    case .integer(700): return true
    case .enumeration(.bold): return true
    default: return false
    }
  }

  var isItalic: Bool {
    fontStyle == .italic
  }
}
