import SwiftUI

struct TextSheet: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id
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

  @ViewBuilder var textFormatOptions: some View {
    let text = interactor.bindTextState(id, resetFontProperties: false)
    let textReset = interactor.bindTextState(id, resetFontProperties: true)

    List {
      NavigationLinkPicker(title: "Font", data: assets.fonts,
                           selection: textReset.fontFamilyID) { fontFamily, isSelected in
        Label(fontFamily.name, systemImage: "checkmark")
          .labelStyle(.icon(hidden: !isSelected, titleFont: .custom(fontFamily.someFontName ?? "", size: 17)))
      } linkLabel: { selection in
        Text(selection?.name ?? "")
      }

      HStack(spacing: 32) {
        PropertyButton(property: .bold, selection: text.bold)
        PropertyButton(property: .italic, selection: text.italic)
        Spacer()
        let alignment: Binding<HorizontalAlignment?> = interactor.bind(id, property: .key(.textHorizontalAlignment))
        PropertyButton(property: .left, selection: alignment)
        PropertyButton(property: .center, selection: alignment)
        PropertyButton(property: .right, selection: alignment)
      }
      .padding([.leading, .trailing], 16)
      .labelStyle(.iconOnly)
      .buttonStyle(.borderless) // or .plain will do the job

      NavigationLink("Advanced") {
        List {
          textAdvancedOptions
        }
        .navigationTitle("Advanced Text")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            SheetDismissButton()
          }
        }
      }

      Section("Font Size") {
        PropertySlider<Float>("Font Size", in: 6 ... 90, property: .key(.textFontSize))
      }
    }
  }

  @ViewBuilder var textAdvancedOptions: some View {
    Section("Letter Spacing") {
      PropertySlider<Float>("Letter Spacing", in: -0.15 ... 1.4, property: .key(.textLetterSpacing))
    }
    Section("Line Height") {
      PropertySlider<Float>("Line Height", in: 0.5 ... 2.5, property: .key(.textLineHeight))
    }
    if interactor.isAllowed(id, scope: .key(.designArrangeResize)) {
      PropertyStack("Vertical Alignment") {
        let alignment: Binding<VerticalAlignment?> = interactor.bind(id, property: .key(.textVerticalAlignment))
        PropertyButton(property: .top, selection: alignment)
        PropertyButton(property: .center, selection: alignment)
        PropertyButton(property: .bottom, selection: alignment)
      }
      PropertyPicker<SizeMode>("Autosize", property: .key(.heightMode),
                               cases: [
                                 .auto,
                                 .absolute
                               ]) { engine, blocks, propertyBlock, property, value, completion in
        let changed = try blocks.filter {
          try engine.block.get($0, propertyBlock, property: property) != value
        }

        try changed.forEach {
          switch value {
          case .auto:
            let width = try engine.block.getFrameWidth($0)
            try engine.block.setWidth($0, value: width)
          case .absolute:
            let width = try engine.block.getFrameWidth($0)
            let height = try engine.block.getFrameHeight($0)
            try engine.block.setWidth($0, value: width)
            try engine.block.setHeight($0, value: height)
          case .percent:
            break
          }
          try engine.block.set($0, propertyBlock, property: property, value: value)
        }

        let didChange = !changed.isEmpty
        return try (completion?(engine, blocks, didChange) ?? false) || didChange
      }
    }
  }

  var body: some View {
    BottomSheet {
      switch sheet.mode {
      case .add: textList
      case .format: textFormatOptions
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
