import IMGLYCore
import SwiftUI

public struct ImageGrid<Empty: View>: View {
  private let interactor: AssetLibraryInteractor
  private let sourceID: String
  @Binding private var search: String
  @ViewBuilder private let empty: (_ search: String) -> Empty

  public init(interactor: AssetLibraryInteractor, sourceID: String, search: Binding<String>,
              @ViewBuilder empty: @escaping (_ search: String) -> Empty = { _ in Message.noResults }) {
    self.interactor = interactor
    self.sourceID = sourceID
    _search = search
    self.empty = empty
  }

  public var body: some View {
    AssetGrid(interactor: interactor, sourceID: sourceID, search: $search,
              columns: [GridItem(.adaptive(minimum: 108, maximum: 152), spacing: 2)],
              spacing: 2, padding: 0) { asset in
      ReloadableAsyncImage(interactor: interactor, asset: asset, sourceID: sourceID) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(minWidth: 0, minHeight: 0)
          .clipped()
          .aspectRatio(1, contentMode: .fit)
      }
    } empty: {
      empty($0)
    }
  }
}
