import SwiftUI

struct ShapeOptions: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  @ViewBuilder var shapeOptions: some View {
    switch interactor.blockType(id) {
    case .lineShape:
      Section("Line Width") {
        let setter: Interactor.PropertySetter<Float> = { engine, blocks, _, _, value, completion in
          let changed = try blocks.filter {
            try engine.block.getHeight($0) != value
          }

          try changed.forEach {
            try engine.block.setWidth($0, value: engine.block.getFrameWidth($0))
            try engine.block.setHeight($0, value: value)
          }

          let didChange = !changed.isEmpty
          return try (completion?(engine, blocks, didChange) ?? false) || didChange
        }
        PropertySlider<Float>("Line Width", in: 0.1 ... 30, property: .key(.lastFrameHeight), setter: setter)
      }
    case .starShape:
      Section("Points") {
        PropertySlider<Float>("Points", in: 3 ... 12, property: .key(.shapesStarPoints))
      }
      Section("Inner Diameter") {
        PropertySlider<Float>("Inner Diameter", in: 0.1 ... 1, property: .key(.shapesStarInnerDiameter))
      }
    case .polygonShape:
      Section("Sides") {
        PropertySlider<Float>("Sides", in: 3 ... 12, property: .key(.shapesPolygonSides))
      }
    default:
      EmptyView()
    }
  }

  var body: some View {
    List {
      if interactor.sheetType(id) == .shape {
        shapeOptions
      }
    }
  }
}
