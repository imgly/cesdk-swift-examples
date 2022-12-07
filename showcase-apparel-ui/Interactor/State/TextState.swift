import CoreGraphics

struct TextState: BatchMutable {
  var fontID: String?
  var fontFamilyID: String?

  var bold: TextProperty?
  var italic: TextProperty?
  var alignment: TextProperty?

  var color: CGColor = .black

  var isBold: Bool { bold == .bold }
  var isItalic: Bool { italic == .italic }

  mutating func setFontProperties(_ properties: FontProperties?) {
    guard let properties else {
      bold = .notAvailable
      italic = .notAvailable
      return
    }
    if let bold = properties.bold {
      self.bold = bold ? .bold : nil
    } else {
      bold = .notAvailable
    }
    if let italic = properties.italic {
      self.italic = italic ? .italic : nil
    } else {
      italic = .notAvailable
    }
  }

  func fontFamilyName(_ assets: AssetLibrary) -> String? {
    guard let fontFamilyID else {
      return nil
    }
    return assets.fontFamilyFor(id: fontFamilyID)?.name
  }
}
