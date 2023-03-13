import SwiftUI

struct LayerOptions: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

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
      .disabled(!interactor.canBringForward(id))
      Group {
        button(.down)
        button(.toBottom)
      }
      .disabled(!interactor.canBringBackward(id))
    }
    .tint(.primary)
    .buttonStyle(.option)
    .labelStyle(.tile(orientation: .vertical))
  }

  var body: some View {
    List {
      if interactor.isAllowed(id, .fillAndStroke) {
        if interactor.hasOpacity(id) {
          Section("Opacity") {
            PropertySlider<Float>("Opacity", in: 0 ... 1, property: .key(.opacity))
          }
        }
        if interactor.hasBlendMode(id) {
          Section {
            PropertyNavigationLink<BlendMode>("Blend Mode", property: .key(.blendMode))
          }
        }
      }
      if interactor.isAllowed(id, .toTop) {
        Section {
          EmptyView()
        } header: {
          layerButtons
        }
        .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        .textCase(.none)
      }
      Section {
        if interactor.isAllowed(id, .duplicate) {
          button(.duplicate)
            .foregroundColor(.primary)
        }
        if interactor.isAllowed(id, .delete) {
          button(.delete)
            .foregroundColor(.red)
        }
      }
    }
  }
}

struct ArrangeOptions_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.layer, .image))
  }
}
