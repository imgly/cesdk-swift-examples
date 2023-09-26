import IMGLYCoreUI
import SwiftUI

struct Sheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var sheet: SheetState { interactor.sheet }

  @Environment(\.verticalSizeClass) private var verticalSizeClass

  @ViewBuilder func sheet(_ type: SheetType) -> some View {
    switch type {
    case .image: ImageSheet()
    case .text: TextSheet()
    case .shape: ShapeSheet()
    case .sticker: StickerSheet()
    case .group: GroupSheet()
    case .selectionColors: SelectionColorsSheet()
    case .font: FontSheet()
    case .fontSize: FontSizeSheet()
    case .color: ColorSheet()
    case .page: PageSheet()
    }
  }

  @State var hidePresentationDragIndicator: Bool = false

  var dragIndicatorVisibility: Visibility {
    if hidePresentationDragIndicator {
      return .hidden
    }
    if verticalSizeClass == .compact {
      return .hidden
    }
    return .visible
  }

  var assetLibrary: AssetLibrary {
    AssetLibrary(sceneMode: .design)
  }

  var body: some View {
    Group {
      switch sheet.mode {
      case .add: assetLibrary
      case .replace:
        Group {
          switch sheet.type {
          case .image: assetLibrary.imagesTab
          case .sticker: assetLibrary.stickersTab
          default: EmptyView()
          }
        }
        .assetLibraryTitleDisplayMode(.inline)
      default:
        if let id = sheet.mode.pinnedBlockID {
          sheet(sheet.type)
            .selection(id)
            .colorPalette(sheet.mode.colorPalette)
            .fontFamilies(sheet.mode.fontFamilies)
        } else {
          sheet(sheet.type)
        }
      }
    }
    .assetLibraryInteractor(interactor)
    .assetLibraryDismissButton(SheetDismissButton())
    .onPreferenceChange(PresentationDragIndicatorHiddenKey.self) { newValue in
      hidePresentationDragIndicator = newValue
    }
    .pickerStyle(.menu)
    .conditionalPresentationConfiguration(sheet.largestUndimmedDetent)
    .conditionalPresentationDetents(sheet.detents, selection: $interactor.sheet.detent)
    .conditionalPresentationDragIndicator(dragIndicatorVisibility)
  }
}

struct Sheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .image))
  }
}
