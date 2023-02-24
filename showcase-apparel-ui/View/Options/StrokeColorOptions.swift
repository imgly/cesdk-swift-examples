import SwiftUI

struct StrokeColorOptions: View {
  @EnvironmentObject private var interactor: Interactor

  var body: some View {
    if interactor.hasStroke {
      ColorOptions(isEnabled: interactor.bind(property: "stroke/enabled", default: false),
                   color: interactor.bind(property: "stroke/color", default: .black,
                                          completion: Interactor.Completion.set(property: "stroke/enabled", value: true,
                                                                                completion: Interactor.Completion
                                                                                  .addUndoStep)))
    }
  }
}
