import SwiftUI

struct FillAndStrokeOptions: View {
  @EnvironmentObject private var interactor: Interactor

  var body: some View {
    if interactor.hasFill {
      Section("Fill") {
        FillColorOptions()
      }
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Fill")
    }
    if interactor.hasStroke {
      Section("Stroke") {
        StrokeOptions(isEnabled: interactor.bind(property: "stroke/enabled", default: false))
      }
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Stroke")
    }
  }
}
