import SwiftUI

struct Sheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var sheet: SheetState { interactor.sheet }

  @Environment(\.verticalSizeClass) private var verticalSizeClass

  // swiftlint:disable:next cyclomatic_complexity
  @ViewBuilder func sheet(_ type: SheetType) -> some View {
    switch type {
    case .image: ImageSheet()
    case .text: TextSheet()
    case .shape: ShapeSheet()
    case .sticker: StickerSheet()
    case .upload: UploadSheet()
    case .group: GroupSheet()
    case .selectionColors: SelectionColorsSheet()
    case .font: FontSheet()
    case .fontSize: FontSizeSheet()
    case .color: ColorSheet()
    case .page: PageSheet()
    }
  }

  var tabs: [SheetType] { [.image, .text, .shape, .sticker, .upload] }

  var dragIndicatorVisibility: Visibility {
    if sheet.isSearchable {
      return .hidden
    }
    if verticalSizeClass == .compact {
      return .hidden
    }
    return .visible
  }

  var body: some View {
    Group {
      if sheet.mode == .add {
        TabView(selection: $interactor.sheet.model.type) {
          ForEach(tabs) { type in
            sheet(type)
              .tabItem {
                type.label(suffix: type != .text ? "s" : "")
              }
              .tag(type)
          }
        }
      } else {
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
