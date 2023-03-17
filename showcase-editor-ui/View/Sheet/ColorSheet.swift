import SwiftUI

struct ColorSheet: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  var fillColor: Binding<CGColor> {
    interactor.bind(id, property: .key(.fillSolidColor), default: .black,
                    setter: Interactor.Setter.set(overrideScope: .key(.designStyle)),
                    completion: nil)
  }

  var body: some View {
    BottomSheet {
      List {
        if interactor.hasFill(id) {
          ColorOptions(title: "Color", color: fillColor, addUndoStep: interactor.addUndoStep)
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
      }
    }
  }
}

struct ColorSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.color(nil, nil), .color))
  }
}
