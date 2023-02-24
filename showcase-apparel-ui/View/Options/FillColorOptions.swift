import SwiftUI

struct FillColorOptions: View {
  @EnvironmentObject private var interactor: Interactor

  var body: some View {
    if interactor.hasFill {
      ColorOptions(isEnabled: interactor.bind(property: "fill/enabled", default: false),
                   color: interactor.bind(property: "fill/solid/color", default: .black,
                                          completion: Interactor.Completion.set(property: "fill/enabled", value: true,
                                                                                completion: Interactor.Completion
                                                                                  .addUndoStep)))
    }
  }
}
