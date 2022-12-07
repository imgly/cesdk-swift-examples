import SwiftUI

struct BottomToolbar: View {
  @EnvironmentObject private var interactor: Interactor

  @ViewBuilder func button(_ type: SheetType) -> some View {
    Button {
      interactor.toolbarButtonTapped(for: type)
    } label: {
      type.label
    }
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        Spacer(minLength: 0)
        HStack(spacing: 0) {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              Group {
                button(.text)
                button(.image)
                button(.shape)
                button(.sticker)
              }
              .fixedSize()
            }
            .buttonStyle(.toolbar)
            .labelStyle(.adaptiveTile)
            .padding([.leading, .trailing], 8)
            .padding([.top], 10) // Counteracts shrinked toolbar button hit area by scroll view
            .padding([.bottom], 8) // Prevent clipped shadows
            .frame(minWidth: geometry.size.width)
          }
        }
      }
    }
    .disabled(interactor.isLoading)
  }
}

struct BottomToolbar_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
