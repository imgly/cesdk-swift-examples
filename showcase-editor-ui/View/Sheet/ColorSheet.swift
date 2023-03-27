import SwiftUI

struct ColorSheet: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  var fillColor: Binding<CGColor> {
    let setter: Interactor.PropertySetter<CGColor> = { engine, blocks, propertyBlock, property, value, completion in
      let didChange = try engine.block.overrideAndRestore(blocks, scope: .key(.designStyle)) {
        try engine.block.set($0, propertyBlock, property: property, value: value)
      }
      return try (completion?(engine, blocks, didChange) ?? false) || didChange
    }
    return interactor.bind(id, property: .key(.fillSolidColor), default: .black, setter: setter, completion: nil)
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
