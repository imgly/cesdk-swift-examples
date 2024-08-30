import SwiftUI

public struct PreviewButton: View {
  @EnvironmentObject private var interactor: Interactor

  public init() {}

  public var body: some View {
    ZStack(alignment: .leading) {
      ActionButton(.previewMode)
        .opacity(interactor.isEditing ? 1 : 0)
        .disabled(!interactor.isEditing)

      ActionButton(.editMode)
        .fixedSize()
        .opacity(interactor.isEditing ? 0 : 1)
        .disabled(interactor.isEditing)
    }
    .disabled(interactor.isLoading)
  }
}
