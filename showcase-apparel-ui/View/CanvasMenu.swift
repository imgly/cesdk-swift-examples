import SwiftUI

struct CanvasMenu: View {
  @EnvironmentObject private var interactor: Interactor

  @ViewBuilder func button(_ mode: SheetMode) -> some View {
    Button {
      interactor.canvasMenuButtonTapped(for: mode)
    } label: {
      mode.label(suffix: .ellipsis)
    }
    .padding(8)
  }

  @ViewBuilder func button(_ action: Action) -> some View {
    Button {
      interactor.actionButtonTapped(for: action)
    } label: {
      action.label
    }
    .padding(8)
  }

  @ViewBuilder var divider: some View {
    Divider()
      .overlay(.tertiary)
  }

  var body: some View {
    if let type = interactor.sheetTypeForSelection {
      HStack {
        Group {
          if type == .text {
            button(.edit)
            divider
          }
          if type == .text || type == .shape {
            button(.style)
            divider
          } else if type == .image || type == .sticker {
            button(.replace)
            divider
          }
          button(.arrange)
          divider
        }
        .labelStyle(.titleOnly)
        Group {
          button(.duplicate)
          divider
          button(.delete)
        }
        .labelStyle(.iconOnly)
      }
      .padding([.leading, .trailing], 8)
      .background(
        RoundedRectangle(cornerRadius: 8).fill(.bar)
          .shadow(color: .black.opacity(0.2), radius: 10)
      )
      .fixedSize()
      .offset(y: -32)
    }
  }
}

struct CanvasMenu_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
