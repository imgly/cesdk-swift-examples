import SwiftUI

protocol Labelable: Localizable, Hashable {
  var systemImage: String { get }
}

extension Labelable {
  @ViewBuilder var label: some View {
    label(suffix: nil)
  }

  @ViewBuilder func label(suffix: String?) -> some View {
    Label(localizedStringKey(suffix: suffix), systemImage: systemImage)
  }

  @ViewBuilder var taggedLabel: some View {
    taggedLabel(suffix: nil)
  }

  @ViewBuilder func taggedLabel(suffix: String?) -> some View {
    label(suffix: suffix).tag(self)
  }
}
