import Introspect
import SwiftUI
import SwiftUIBackports

// MARK: - Public interface

public extension View {
  @MainActor
  func interactor(_ interactor: Interactor) -> some View {
    selection(interactor.selection?.blocks.first)
      .environmentObject(interactor)
  }

  func colorPalette(_ colors: [NamedColor]?) -> some View {
    environment(\.colorPalette, colors ?? ColorPaletteKey.defaultValue)
  }

  func fontFamilies(_ families: [String]?) -> some View {
    environment(\.fontFamilies, families ?? FontFamiliesKey.defaultValue)
  }

  @MainActor
  func buildInfo() -> some View {
    safeAreaInset(edge: .bottom, spacing: 0) {
      BuildInfo()
    }
  }
}

extension View {
  func selection(_ id: Interactor.BlockID?) -> some View {
    environment(\.selection, id)
  }

  func canvasAction(anchor: UnitPoint = .top, @ViewBuilder action: @escaping () -> some View) -> some View {
    modifier(CanvasAction(anchor: anchor, action: action))
  }

  func errorAlert(isSheet: Bool) -> some View {
    modifier(ErrorAlert(isSheet: isSheet))
  }

  @MainActor @ViewBuilder
  func conditionalNavigationBarBackground(_ visibility: Visibility) -> some View {
    if #available(iOS 16.0, *) {
      toolbarBackground(visibility, for: .navigationBar)
    } else {
      modifier(NavigationBarAppearance(appearance: .init(background: visibility)))
    }
  }

  @ViewBuilder
  func conditionalPresentationDetents(_ detents: Set<PresentationDetent>,
                                      selection: Binding<PresentationDetent>) -> some View {
    if #available(iOS 16.0, *) {
      presentationDetents(Set(detents.map(\.detent)), selection: selection.detent)
    } else {
      backport.presentationDetents(Set(detents.map(\.backport)), selection: selection.backport)
    }
  }

  @MainActor @ViewBuilder
  func conditionalPresentationConfiguration(_ largestUndimmedDetent: PresentationDetent?) -> some View {
    if #available(iOS 16.4, *) {
      #if swift(>=5.8)
        presentationBackgroundInteraction({
          if let largestUndimmedDetent {
            return .enabled(upThrough: largestUndimmedDetent.detent)
          } else {
            return .disabled
          }
        }())
          .presentationContentInteraction(.scrolls)
          .presentationCompactAdaptation(.sheet)
      #else
        #error("Use Xcode 14.3+ otherwise the sheet dimming is broken on iOS 16.4+!")
        legacyPresentationConfiguration(largestUndimmedDetent)
      #endif
    } else {
      legacyPresentationConfiguration(largestUndimmedDetent)
    }
  }

  @MainActor @ViewBuilder
  private func legacyPresentationConfiguration(_ largestUndimmedDetent: PresentationDetent?) -> some View {
    introspectViewController { viewController in
      guard let controller = viewController.sheetPresentationController else {
        return
      }
      controller.presentingViewController.view?.tintAdjustmentMode = .normal
      controller.largestUndimmedDetentIdentifier = largestUndimmedDetent?.identifier
      controller.prefersScrollingExpandsWhenScrolledToEdge = false
      controller.prefersEdgeAttachedInCompactHeight = true
    }
  }

  func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
    background(WillDisappearHandler(onWillDisappear: perform))
  }
}
