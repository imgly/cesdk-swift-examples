import IMGLYCoreUI
import SwiftUI

struct EffectOptions<Item: View>: View {
  @Binding var selection: AssetSelection?
  @ViewBuilder var item: (AssetLoader.Asset, Binding<EffectSheetState>) -> Item
  let identifier: ((AssetLoader.Asset) -> AnyHashable?)?
  let sources: [AssetLoader.SourceData]

  @StateObject private var searchState = AssetLibrary.SearchState()
  @State private var sheetState: EffectSheetState = .selection

  @ViewBuilder private var grid: some View {
    VStack {
      AssetGrid { asset in
        switch asset {
        case let .asset(asset):
          item(asset, $sheetState)
        case .placeholder:
          SelectableItem(title: "", selected: false) {
            GridItemBackground()
              .aspectRatio(1, contentMode: .fit)
          }
        }
      } empty: { _ in
        Message.noElements
      } first: {
        NoneItem(selection: $selection)
      } more: {
        EmptyView()
      }
      .assetGrid(axis: .horizontal)
      .assetGrid(items: [GridItem(.adaptive(minimum: 80, maximum: 100))])
      .assetGrid(spacing: 8)
      .assetGrid(edges: [.leading, .trailing])
      .assetGrid(padding: 16)
      .assetGridPlaceholderCount { _, _ in
        10
      }
      .assetGrid(messageTextOnly: true)
      .assetGrid(sourcePadding: 16)
      .assetGridItemIndex { identifier?($0) }
      .assetGridOnAppear { $0.scrollTo(selection?.identifier) }
      .assetLoader(sources: sources, order: .sorted, perPage: 65)
      .frame(height: 110, alignment: .top)
      .environmentObject(searchState)
      Spacer()
    }
    .background(Color(.systemGroupedBackground))
  }

  var body: some View {
    switch sheetState {
    case .selection:
      grid
    case let .properties(asset):
      EffectPropertyOptions(
        title: asset.title,
        properties: asset.properties,
        backTitle: asset.backTitle,
        sheetState: $sheetState
      )
    }
  }
}
