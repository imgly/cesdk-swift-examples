import SwiftUI

struct FontIcon: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id
  private var assets: AssetLibrary { interactor.assets }

  var body: some View {
    let text = interactor.bindTextState(id, resetFontProperties: true)

    if let fontFamilyID = text.wrappedValue.fontFamilyID,
       let fontFamily = assets.fontFamilyFor(id: fontFamilyID),
       let fontName = fontFamily.someFontName {
      FontImage(font: .custom(fontName, size: 28))
    }
  }
}
