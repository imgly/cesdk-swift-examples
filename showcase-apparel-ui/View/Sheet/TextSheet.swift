import SwiftUI

struct TextSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  @ViewBuilder var textStyleOptions: some View {
    List {
      NavigationLink {
        ScrollViewReader { proxy in
          List(assets.fonts) {
            FontButton(fontFamily: $0, selectedFontFamilyID: $interactor.text.fontFamilyID)
              .id($0.id)
          }
          .safeAreaInset(edge: .top) { Color.clear.frame(height: 15) }
          .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 15) }
          .toolbarBackground(.visible, for: .navigationBar)
          .task {
            proxy.scrollTo(interactor.text.fontFamilyID, anchor: .center)
          }
          .onChange(of: interactor.text.fontFamilyID) { newValue in
            withAnimation {
              proxy.scrollTo(newValue)
            }
          }
        }
        .navigationTitle("Font")
      } label: {
        HStack {
          Text("Font")
          Spacer()
          Text(interactor.text.fontFamilyName(assets) ?? "")
            .foregroundColor(.secondary)
            .lineLimit(1)
        }
      }
      .accessibilityLabel("Font")
      Group {
        HStack(spacing: 32) {
          TextPropertyButton(property: .bold, selection: $interactor.text.bold)
          TextPropertyButton(property: .italic, selection: $interactor.text.italic)
          Spacer()
          TextPropertyButton(property: .alignLeft, selection: $interactor.text.alignment)
          TextPropertyButton(property: .alignCenter, selection: $interactor.text.alignment)
          TextPropertyButton(property: .alignRight, selection: $interactor.text.alignment)
        }
        .padding([.leading, .trailing], 16)
        ColorOptions(selection: $interactor.text.color)
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
    defaultPreviews(sheet: .init(.edit, .text))
  }
}
