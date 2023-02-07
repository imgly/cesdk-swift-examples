import SwiftUI

/// Custom view that looks like `.pickerStyle(.navigationLink)` but allows to keep the picker open and explore different
/// selections.
struct NavigationLinkPicker<Data, ElementLabel: View, LinkLabel: View>: View where
  Data: RandomAccessCollection,
  Data.Element: Identifiable {
  let title: LocalizedStringKey
  let data: Data
  @Binding var selection: Data.Element.ID?

  @ViewBuilder let elementLabel: (_ element: Data.Element, _ isSelected: Bool) -> ElementLabel
  @ViewBuilder let linkLabel: (_ selection: Data.Element?) -> LinkLabel

  private func isSelecetd(_ element: Data.Element) -> Bool { selection == element.id }

  var body: some View {
    NavigationLink {
      ScrollViewReader { proxy in
        List(data) { element in
          Button {
            selection = element.id
          } label: {
            let isSelected = isSelecetd(element)
            elementLabel(element, isSelected)
              .foregroundColor(isSelected ? .accentColor : .primary)
          }
          .id(element.id)
        }
        .safeAreaInset(edge: .top) { Color.clear.frame(height: 15) }
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 15) }
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
          proxy.scrollTo(selection, anchor: .center)
        }
        .onChange(of: selection) { newValue in
          withAnimation {
            proxy.scrollTo(newValue)
          }
        }
      }
      .navigationTitle(title)
    } label: {
      HStack {
        Text(title)
        Spacer()
        linkLabel(data.first(where: isSelecetd))
          .foregroundColor(.accentColor)
          .lineLimit(1)
      }
    }
    .accessibilityLabel(title)
  }
}

struct NavigationLinkPicker_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.arrange, .text))
  }
}
