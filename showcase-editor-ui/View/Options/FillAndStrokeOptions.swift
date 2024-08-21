import SwiftUI

struct FillAndStrokeOptions: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  @ViewBuilder var fillAndStrokeOptions: some View {
    if interactor.hasFill(id) {
      Section("Fill") {
        FillColorOptions()
      }
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Fill")
    }
    if interactor.hasStroke(id) {
      Section("Stroke") {
        StrokeOptions(isEnabled: interactor.bind(id, property: .key(.strokeEnabled), default: false))
      }
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Stroke")
    }
  }

  var body: some View {
    List {
      fillAndStrokeOptions
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless) // or .plain will do the job
    }
  }
}
