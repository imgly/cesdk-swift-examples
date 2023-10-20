import SwiftUI

struct FillColorOptions: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  var body: some View {
    if interactor.hasFill(id) {
      ColorOptions(title: "Fill Color",
                   isEnabled: interactor.bind(id, property: .key(.fillEnabled), default: false),
                   color: interactor.bind(id, property: .key(.fillSolidColor), default: .black, completion:
                     Interactor.Completion.set(property: .key(.fillEnabled), value: true)),
                   addUndoStep: interactor.addUndoStep)
    }
  }
}
