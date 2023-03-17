import SwiftUI

struct UploadSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var assets: AssetLibrary { interactor.assets }
  private var sheet: SheetModel { interactor.sheet.model }

  @ViewBuilder var imageGrid: some View {
    VStack {
      UploadGrid(sourceID: ImageSource.uploads.sourceID, search: $searchText.debouncedValue)
    }
  }

  @StateObject private var searchText = Debouncer(initialValue: "")

  var body: some View {
    BottomSheet {
      switch sheet.mode {
      case .add, .replace:
        imageGrid
          .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
              AddImageButton()
            }
            ToolbarItemGroup(placement: .principal) {
              SearchField(searchText: $searchText.value, prompt: Text("Search Uploads"))
            }
          }
      case .layer: LayerOptions()
      default: EmptyView()
      }
    }
  }
}

struct UploadSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .upload))
  }
}
