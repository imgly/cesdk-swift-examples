import IMGLYCoreUI
import SwiftUI

struct StickerSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var sheet: SheetModel { interactor.sheet.model }

  @StateObject private var searchText = Debouncer(initialValue: "")

  @ViewBuilder var stickerGrid: some View {
    VStack {
      StickerGrid(interactor: interactor, sourceID: AssetLibrary.stickerSourceID, search: $searchText.debouncedValue)
    }
    .toolbar {
      ToolbarItemGroup(placement: .principal) {
        SearchField(searchText: $searchText.value, prompt: Text("Search Stickers"))
      }
    }
  }

  var body: some View {
    BottomSheet {
      switch sheet.mode {
      case .add, .replace: stickerGrid
      case .layer: LayerOptions()
      default: EmptyView()
      }
    }
  }
}

struct StickerSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .sticker))
  }
}
