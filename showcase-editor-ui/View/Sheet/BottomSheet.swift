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
      if Set([.image, .upload]).contains(sheet.type) {
        // Fixes searchbar offset.
        return ""
      } else {
        return sheet.type.localizedStringKey(suffix: sheet.type != .text ? "s" : "")
      }
    case .replace:
      return sheet.model.localizedStringKey
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
          // Fix cases when `.navigationBarTitleDisplayMode(.inline)` does not work.
          navigationController.navigationBar.prefersLargeTitles = false
        }
        .navigationTitle(title)
        .toolbarBackground(toolbarBackground, for: .navigationBar)
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
