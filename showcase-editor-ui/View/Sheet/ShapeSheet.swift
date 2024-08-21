import SwiftUI

struct ShapeSheet: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  private var sheet: SheetModel { interactor.sheet.model }

  @StateObject private var searchText = Debouncer(initialValue: "")

  @ViewBuilder var shapeGrid: some View {
    VStack {
      ShapeGrid(sourceID: AssetLibrary.shapeSourceID, search: $searchText.debouncedValue)
    }
    .toolbar {
      ToolbarItemGroup(placement: .principal) {
        SearchField(searchText: $searchText.value, prompt: Text("Search Shapes"))
      }
    }
  }

  @ViewBuilder var shapeOptions: some View {
    List {
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
  }

  var body: some View {
    BottomSheet {
      switch sheet.mode {
      case .add: shapeGrid
      case .options: shapeOptions
      case .fillAndStroke: FillAndStrokeOptions()
      case .layer: LayerOptions()
      default: EmptyView()
      }
    }
  }
}

struct ShapeSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .shape))
  }
}
