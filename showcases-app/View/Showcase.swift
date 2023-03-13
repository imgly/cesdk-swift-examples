import SwiftUI

struct Showcase<Content: View>: View {
  let view: Content
  let title: String
  var subtitle: String?

  @ViewBuilder var label: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
      if let subtitle {
        Text(subtitle).font(.footnote)
      }
    }
  }

  var body: some View {
    NavigationLink(destination: { view.navigationTitle(title) }, label: { label })
      .accessibilityLabel(title)
  }
}
