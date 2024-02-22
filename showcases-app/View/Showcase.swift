import SwiftUI

struct Showcase<Content: View>: View {
  let view: Content
  let title: LocalizedStringKey
  var subtitle: LocalizedStringKey?

  @ViewBuilder private var label: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
      if let subtitle {
        Text(subtitle).font(.footnote)
      }
    }
  }

  var body: some View {
    ShowcaseLink {
      view
    } label: {
      label
    }
    .accessibilityLabel(title)
  }
}
