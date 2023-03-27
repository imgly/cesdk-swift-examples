import SwiftUI

struct ShapeSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  @ViewBuilder var shapeGrid: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)], spacing: 8) {
        ForEach(assets.shapes) { asset in
          ZStack {
            GridItemBackground()
              .aspectRatio(1, contentMode: .fit)
            Image(asset.imageName, bundle: Bundle.bundle, label: Text(asset.label))
              .resizable()
              .aspectRatio(contentMode: .fit)
              .aspectRatio(1, contentMode: .fit)
              .padding(8)
          }
          .onTapGesture {
            interactor.assetTapped(asset)
          }
        }
      }
      .padding(8)
    }
  }

  @ViewBuilder var shapeOptions: some View {
    List {
      Section("Points") {
        PropertySlider<Float>("Points", in: 3 ... 12, property: .key(.shapesStarPoints))
      }
      Section("Inner Diameter") {
        PropertySlider<Float>("Inner Diameter", in: 0.1 ... 1, property: .key(.shapesStarInnerDiameter))
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
