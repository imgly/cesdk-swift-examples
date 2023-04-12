import SwiftUI

struct TextSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  var defaultFontFamily: FontFamily? {
    assets.fonts.first { $0.name == FontFamily.defaultName }
  }

  @ViewBuilder func button(title: LocalizedStringKey? = nil,
                           _ fontFamily: FontFamily, _ type: FontType = .some,
                           size: CGFloat = 24) -> some View {
    Button(title ?? LocalizedStringKey(fontFamily.name)) {
      if let url = fontFamily.font(type)?.url {
        let text = AssetLibrary.Text(url: url, size: size)
        interactor.assetTapped(text)
      }
    }
    .font(.custom(fontFamily.fontName(type) ?? "", size: size))
    .foregroundColor(.primary)
    .padding([.leading], 12)
  }

  @ViewBuilder var textList: some View {
    List {
      Group {
        if let defaultFontFamily {
          Section("Styles") {
            button(title: "Add Title", defaultFontFamily, .title, size: 32)
            button(title: "Add Headline", defaultFontFamily, .headline, size: 18)
            button(title: "Add Body Text", defaultFontFamily, .body, size: 14)
          }
        }
        Section("Fonts") {
          ForEach(assets.fonts) { fontFamily in
            button(fontFamily, size: 24)
          }
        }
      }
      .listRowBackground(EmptyView())
      .listRowSeparator(.hidden)
      .buttonStyle(.borderless)
    }
    .listStyle(.grouped)
  }

  var body: some View {
    BottomSheet {
      switch sheet.mode {
      case .add: textList
      case .format: TextFormatOptions()
      case .fillAndStroke: FillAndStrokeOptions()
      case .layer: LayerOptions()
      default: EmptyView()
      }
    }
  }
}

struct TextSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.format, .text))
  }
}
