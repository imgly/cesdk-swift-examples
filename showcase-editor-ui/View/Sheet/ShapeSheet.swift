import IMGLYCoreUI
import SwiftUI

struct ShapeSheet: View {
  @EnvironmentObject private var interactor: Interactor

  private var sheet: SheetModel { interactor.sheet.model }

  @StateObject private var searchText = Debouncer(initialValue: "")

  @ViewBuilder var shapeGrid: some View {
    VStack {
      ShapeGrid(interactor: interactor, sourceID: AssetLibrary.shapeSourceID, search: $searchText.debouncedValue)
    }
    .toolbar {
      ToolbarItemGroup(placement: .principal) {
        SearchField(searchText: $searchText.value, prompt: Text("Search Shapes"))
      }
    }
  }

  var body: some View {
    BottomSheet {
      switch sheet.mode {
      case .add: shapeGrid
      case .options: ShapeOptions()
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
