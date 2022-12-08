import SwiftUI

struct CanvasMenu: View {
  @EnvironmentObject private var interactor: Interactor

  enum ButtonType: IdentifiableByHash {
    case sheet(SheetMode)
    case action(Action)
  }

  @ViewBuilder func button(_ type: ButtonType) -> some View {
    switch type {
    case let .sheet(mode):
      button(mode)
    case let .action(action):
      button(action)
    }
  }

  @ViewBuilder func button(_ mode: SheetMode) -> some View {
    Button {
      interactor.canvasMenuButtonTapped(for: mode)
    } label: {
      mode.label(suffix: .ellipsis)
    }
    .padding(8)
    .labelStyle(.titleOnly)
  }

  @ViewBuilder func button(_ action: Action) -> some View {
    Button {
      interactor.actionButtonTapped(for: action)
    } label: {
      action.label
    }
    .padding(8)
    .labelStyle(.iconOnly)
  }

  @ViewBuilder var divider: some View {
    Divider()
      .overlay(.tertiary)
  }

  func buttons(for type: SheetType) -> [ButtonType] {
    var buttons = [ButtonType]()

    func button(_ type: ButtonType) {
      switch type {
      case let .sheet(mode):
        if interactor.isAllowed(mode) {
          buttons.append(type)
        }
      case let .action(action):
        if interactor.isAllowed(action) {
          buttons.append(type)
        }
      }
    }

    if type == .text {
      button(.sheet(.edit))
    }
    if type == .text || type == .shape {
      button(.sheet(.style))
    } else if type == .image || type == .sticker {
      button(.sheet(.replace))
    }
    button(.sheet(.arrange))
    button(.action(.duplicate))
    button(.action(.delete))

    return buttons
  }

  @ViewBuilder var menu: some View {
    if let type = interactor.sheetTypeForSelection {
      let buttons = buttons(for: type)
      if let last = buttons.last {
        HStack {
          if buttons.count > 1 {
            ForEach(buttons.dropLast()) {
              button($0)
              divider
            }
          }
          button(last)
        }
        .padding([.leading, .trailing], 8)
        .background(
          RoundedRectangle(cornerRadius: 8).fill(.bar)
            .shadow(color: .black.opacity(0.2), radius: 10)
        )
      }
    }
  }

  @State private var size: CGSize?

  private var halfHeight: CGFloat { (size?.height ?? 0) / 2 }

  var body: some View {
    menu
      .fixedSize()
      .background {
        GeometryReader { geo in
          Color.clear
            .preference(key: CanvasMenuSizeKey.self, value: geo.size)
        }
      }
      .onPreferenceChange(CanvasMenuSizeKey.self) { newValue in
        size = newValue
      }
      .offset(y: -halfHeight - 24)
  }
}

struct CanvasMenu_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
