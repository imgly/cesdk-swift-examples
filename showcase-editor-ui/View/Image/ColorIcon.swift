import SwiftUI

struct FillColorIcon: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  var body: some View {
    if interactor.hasFill(id) {
      let isEnabled: Binding<Bool> = interactor.bind(id, property: .key(.fillEnabled), default: false)
      let color: Binding<CGColor> = interactor.bind(id, property: .key(.fillSolidColor), default: .black)

      FillColorImage(isEnabled: isEnabled.wrappedValue, color: color)
    }
  }
}

struct StrokeColorIcon: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  var body: some View {
    if interactor.hasStroke(id) {
      let isEnabled: Binding<Bool> = interactor.bind(id, property: .key(.strokeEnabled), default: false)
      let color: Binding<CGColor> = interactor.bind(id, property: .key(.strokeColor), default: .black)

      StrokeColorImage(isEnabled: isEnabled.wrappedValue, color: color)
    }
  }
}
