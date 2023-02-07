import Introspect
import KeyboardObserver
import Media
import SwiftUI

struct Sheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var sheet: SheetState { interactor.sheet }

  @Environment(\.verticalSizeClass) private var verticalSizeClass

  @State private var sheetContentGeometry: Geometry?

  var body: some View {
    GeometryReader { proxy in
      Group {
        switch sheet.type {
        case .text: TextSheet()
        case .image: ImageSheet()
        case .shape: ShapeSheet()
        case .sticker: StickerSheet()
        }
      }
      .pickerStyle(.menu)
      .onPreferenceChange(SheetContentGeometryKey.self) { newValue in
        sheetContentGeometry = newValue
      }
      .onKeyboardChange { keyboard, _ in
        let keyboardHeight = keyboard.height(in: proxy)
        let detent: PresentationDetent
        if keyboardHeight > 0, let safeAreaInsets = sheetContentGeometry?.safeAreaInsets {
          detent = .height(keyboardHeight + CGFloat(safeAreaInsets.top))
        } else {
          detent = .adaptiveMedium
        }
        interactor.sheet.commit { sheet in
          sheet.detents = [detent, .large]
          sheet.detent = detent
        }
      }
    }
    .presentationDetents(sheet.detents, selection: $interactor.sheet.detent)
    .presentationDragIndicator(sheet.type == .text || verticalSizeClass == .compact ? .hidden : .visible)
    .introspectViewController { viewController in
      viewController.presentingViewController?.view.tintAdjustmentMode = .normal
      viewController.sheetPresentationController?.largestUndimmedDetentIdentifier = .large
      viewController.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
      viewController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
    }
  }
}

struct Sheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .image))
  }
}
