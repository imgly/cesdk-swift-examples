import SwiftUI

struct ShapeSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  @ViewBuilder var shapeGrid: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 150))]) {
        ForEach(assets.shapes) { asset in
          Image(asset.imageName, bundle: Bundle.bundle, label: Text(asset.label))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(maxHeight: 150)
            .onTapGesture {
              interactor.assetTapped(asset)
            }
        }
      }
    }
  }

  @ViewBuilder var shapeStyleOptions: some View {
    List {
      Group {
        ColorOptions(selection: $interactor.shape.color)
      }
      .labelStyle(.iconOnly)
      .buttonStyle(.borderless)
    }
  }

  var body: some View {
    BottomSheet(title: Text(sheet.localizedStringKey)) {
      switch sheet.mode {
      case .add: EmptyView()
      default: SheetModePicker(sheet: $interactor.sheet.model, modes: [.style, .arrange])
      }
    } content: {
      switch sheet.mode {
      case .add: shapeGrid
      case .style: shapeStyleOptions
      case .arrange: ArrangeOptions()
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
