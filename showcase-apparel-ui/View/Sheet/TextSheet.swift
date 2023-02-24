import SwiftUI

struct TextSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  @ViewBuilder var textStyleOptions: some View {
    let fontURL: Binding<URL?> = interactor.bind(property: "text/fontFileUri")
    let text = Binding<TextState> {
      if let fontURL = fontURL.wrappedValue {
        let selected = assets.fontFor(url: fontURL)
        var text = TextState()
        text.fontID = selected?.font.id
        text.fontFamilyID = selected?.family.id
        text.setFontProperties(selected?.family.fontProperties(for: selected?.font.id))
        return text
      } else {
        return TextState()
      }
    } set: { text in
      if let fontFamilyID = text.fontFamilyID, let fontFamily = assets.fontFamilyFor(id: fontFamilyID),
         let font = fontFamily.font(for: .init(bold: text.isBold, italic: text.isItalic)) ?? fontFamily.someFont,
         let selected = assets.fontFor(id: font.id) {
        fontURL.wrappedValue = selected.font.url
      }
    }

    List {
      NavigationLinkPicker(title: "Font", data: assets.fonts,
                           selection: text.fontFamilyID) { fontFamily, isSelected in
        Label(fontFamily.name, systemImage: "checkmark")
          .labelStyle(.icon(hidden: !isSelected, titleFont: .custom(fontFamily.someFontName ?? "", size: 17)))
      } linkLabel: { selection in
        Text(selection?.name ?? "")
      }
      Group {
        HStack(spacing: 32) {
          PropertyButton(property: .bold, selection: text.bold)
          PropertyButton(property: .italic, selection: text.italic)
          Spacer()
          let alignment: Binding<HorizontalAlignment?> = interactor.bind(property: "text/horizontalAlignment")
          PropertyButton(property: .left, selection: alignment)
          PropertyButton(property: .center, selection: alignment)
          PropertyButton(property: .right, selection: alignment)
        }
        .padding([.leading, .trailing], 16)
        FillAndStrokeOptions()
      }
      .labelStyle(.iconOnly)
      .buttonStyle(.borderless) // or .plain will do the job
    }
  }

  var body: some View {
    BottomSheet(title: Text(sheet.localizedStringKey)) {
      SheetModePicker(sheet: $interactor.sheet.model, modes: [.edit, .style, .arrange])
    } content: {
      switch sheet.mode {
      case .edit: List { Section { EmptyView() } }
      case .style: textStyleOptions
      case .arrange: ArrangeOptions()
      default: EmptyView()
      }
    }
  }
}

struct TextSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.style, .text))
  }
}
