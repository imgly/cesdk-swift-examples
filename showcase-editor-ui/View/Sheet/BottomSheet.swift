import Introspect
import SwiftUI

struct BottomSheet<Content: View>: View {
  @ViewBuilder let content: Content

  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id
  private var sheet: SheetState { interactor.sheet }

  var title: LocalizedStringKey {
    switch sheet.mode {
    case .add:
      if sheet.isSearchable {
        return "" // Fixes searchbar offset.
      } else {
        return sheet.type.localizedStringKey(suffix: sheet.type != .text ? "s" : "")
      }
    case .replace:
      if sheet.isSearchable {
        return "" // Fixes searchbar offset.
      } else {
        return sheet.model.localizedStringKey
      }
    case .options:
      return LocalizedStringKey("\(String(describing: sheet.type)) \(String(describing: sheet.mode))")
    case .selectionColors, .font, .fontSize, .color:
      return sheet.type.localizedStringKey
    default:
      return sheet.mode.localizedStringKey(id, interactor)
    }
  }

  var toolbarBackground: Visibility {
    switch sheet.mode {
    case .add, .replace:
      return sheet.type == .image ? .hidden : .visible
    default:
      return .automatic
    }
  }

  var body: some View {
    NavigationView {
      content
        .navigationBarTitleDisplayMode(.inline)
        .introspectNavigationController { navigationController in
          let navigationBar = navigationController.navigationBar
          // Fix cases when `.navigationBarTitleDisplayMode(.inline)` does not work.
          navigationBar.prefersLargeTitles = false
          // Fix cases when `.toolbarBackground(toolbarBackground, for: .navigationBar)` does not work.
          if toolbarBackground == .hidden {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactScrollEdgeAppearance = appearance
          }
        }
        .navigationTitle(title)
        .conditionalNavigationBarBackground(toolbarBackground)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            SheetDismissButton()
          }
        }
    }
    .navigationViewStyle(.stack)
  }
}

struct BottomSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .image))
  }
}
