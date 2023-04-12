import SwiftUI

struct NavigationBarAppearance: ViewModifier {
  @MainActor
  struct Appearance {
    var standard: UINavigationBarAppearance
    var compact: UINavigationBarAppearance?
    var scrollEdge: UINavigationBarAppearance?
    var compactScrollEdge: UINavigationBarAppearance?

    func apply(navigationBar: UINavigationBar) {
      navigationBar.standardAppearance = standard
      navigationBar.compactAppearance = compact
      navigationBar.scrollEdgeAppearance = scrollEdge
      navigationBar.compactScrollEdgeAppearance = compactScrollEdge
    }
  }

  let appearance: Appearance

  @State private var navigationBar: UINavigationBar?
  @State private var previous: Appearance?

  func body(content: Content) -> some View {
    content
      .introspectNavigationController { navigationController in
        if navigationBar == nil {
          let navigationBar = navigationController.navigationBar
          previous = .init(navigationBar: navigationBar)
          self.navigationBar = navigationBar
        }
        appearance.apply(navigationBar: navigationController.navigationBar)
      }
      .onWillDisappear {
        if let navigationBar {
          previous?.apply(navigationBar: navigationBar)
        }
      }
  }
}

extension NavigationBarAppearance.Appearance {
  init(all appearance: UINavigationBarAppearance) {
    self.init(standard: appearance, compact: appearance,
              scrollEdge: appearance, compactScrollEdge: appearance)
  }

  init(navigationBar: UINavigationBar) {
    self.init(standard: navigationBar.standardAppearance,
              compact: navigationBar.compactAppearance,
              scrollEdge: navigationBar.scrollEdgeAppearance,
              compactScrollEdge: navigationBar.compactScrollEdgeAppearance)
  }

  init(background: Visibility) {
    let appearance = UINavigationBarAppearance()
    switch background {
    case .automatic:
      appearance.configureWithDefaultBackground()
      self.init(standard: appearance)
    case .visible:
      appearance.configureWithDefaultBackground()
      self.init(all: appearance)
    case .hidden:
      appearance.configureWithTransparentBackground()
      self.init(all: appearance)
    }
  }
}
