import SwiftUI

struct ArrangeOptions: View {
  @EnvironmentObject private var interactor: Interactor

  @ViewBuilder func button(_ action: Action) -> some View {
    Button {
      interactor.actionButtonTapped(for: action)
    } label: {
      action.label
    }
  }

  @ViewBuilder var layerButtons: some View {
    HStack(spacing: 8) {
      Group {
        button(.toTop)
        button(.up)
      }
      .disabled(!interactor.canBringForward)
      .foregroundColor(interactor.canBringForward ? .primary : nil)
      Group {
        button(.down)
        button(.toBottom)
      }
      .disabled(!interactor.canBringBackward)
      .foregroundColor(interactor.canBringBackward ? .primary : nil)
    }
    .buttonStyle(.option)
    .labelStyle(.tile(orientation: .vertical))
  }

  var body: some View {
    List {
      Section {
        EmptyView()
      } header: {
        layerButtons
      }
      .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
      .textCase(.none)

      Section {
        button(.duplicate)
      }
      .foregroundColor(.primary)

      Section {
        button(.delete)
      }
      .foregroundColor(.red)
    }
  }
}

struct ArrangeOptions_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.arrange, .image))
  }
}
