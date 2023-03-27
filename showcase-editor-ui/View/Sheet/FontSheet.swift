import SwiftUI

struct FontSheet: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id
  @Environment(\.fontFamilies) private var fontFamilies
  private var assets: AssetLibrary { interactor.assets }

  var fonts: [FontFamily] {
    if let fontFamilies {
      return fontFamilies.compactMap {
        assets.fontFamilyFor(id: $0)
      }
    } else {
      return assets.fonts
    }
  }

  var body: some View {
    let text = interactor.bindTextState(id)

    BottomSheet {
      ListPicker(data: fonts, selection: text.fontFamilyID) { fontFamily, isSelected in
        Label(fontFamily.name, systemImage: "checkmark")
          .labelStyle(.icon(hidden: !isSelected, titleFont: .custom(fontFamily.someFontName ?? "", size: 17)))
      }
    }
  }
}

struct FontSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.font(nil, nil), .font))
  }
}
