import SwiftUI

struct ShowcaseLink<Content: View, Label: View>: View {
  @ViewBuilder let content: () -> Content
  @ViewBuilder let label: () -> Label

  @Environment(\.showcaseMode) private var mode

  var body: some View {
    switch mode {
    case .navigationLink:
      NavigationLink(destination: content, label: label)
    case .fullScreenCover:
      ModalEditorLink(editor: content, label: label)
    }
  }
}

extension View {
  func showcaseMode(_ mode: ShowcaseMode) -> some View {
    environment(\.showcaseMode, mode)
  }
}

private struct ShowcaseModeKey: EnvironmentKey {
  static let defaultValue = ShowcaseMode.navigationLink
}

private extension EnvironmentValues {
  var showcaseMode: ShowcaseMode {
    get { self[ShowcaseModeKey.self] }
    set { self[ShowcaseModeKey.self] = newValue }
  }
}
