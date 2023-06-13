import IMGLYCore
import SwiftUI

public struct ShapeGrid: View {
  let interactor: AssetLibraryInteractor
  let sourceID: String
  @Binding var search: String

  public init(interactor: AssetLibraryInteractor, sourceID: String, search: Binding<String>) {
    self.interactor = interactor
    self.sourceID = sourceID
    _search = search
  }

  public var body: some View {
    AssetGrid(interactor: interactor, sourceID: sourceID, search: $search,
              columns: [GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)],
              spacing: 8, padding: 8) { asset in
      ZStack {
        GridItemBackground()
          .aspectRatio(1, contentMode: .fit)
        ReloadableAsyncImage(interactor: interactor, asset: asset, sourceID: sourceID) { image in
          image
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .aspectRatio(1, contentMode: .fit)
        }
        .padding(8)
      }
    }
  }
}
