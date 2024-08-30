import SwiftUI

public struct UndoRedoButtons: View {
  @EnvironmentObject private var interactor: Interactor

  public init() {}

  public var body: some View {
    Group {
      ActionButton(.undo)
        .disabled(!interactor.canUndo)
      ActionButton(.redo)
        .disabled(!interactor.canRedo)
    }
    .allowsHitTesting(interactor.isEditing)
    .opacity(interactor.isEditing ? 1 : 0)
    .animation(nil, value: interactor.isEditing)
  }
}
