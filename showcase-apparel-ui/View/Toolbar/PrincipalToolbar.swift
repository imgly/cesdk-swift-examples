import SwiftUI

struct PrincipalToolbar: View {
  @EnvironmentObject private var interactor: Interactor

  @Environment(\.verticalSizeClass) private var verticalSizeClass

  @ViewBuilder func button(_ action: Action) -> some View {
    Button {
      interactor.actionButtonTapped(for: action)
    } label: {
      action.label
    }
  }

  var body: some View {
    HStack {
      Group {
        button(.undo)
          .disabled(!interactor.canUndo)
        button(.redo)
          .disabled(!interactor.canRedo)
      }
      .allowsHitTesting(interactor.isEditing)
      .opacity(interactor.isEditing ? 1 : 0)
      .animation(nil, value: interactor.isEditing)
      Spacer()
        .frame(maxWidth: 42)

      ZStack(alignment: .leading) {
        button(.previewMode)
          .opacity(interactor.isEditing ? 1 : 0)

        button(.editMode)
          .fixedSize()
          .opacity(interactor.isEditing ? 0 : 1)
      }
      .labelStyle(.adaptiveIconOnly)
      .disabled(interactor.isLoading)
    }
  }
}

struct PrincipalToolbar_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
