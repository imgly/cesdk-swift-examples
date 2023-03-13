import SwiftUI

struct Section<Content: View>: View {
  let title: String
  var subtitle: String?
  @ViewBuilder let content: Content

  @ViewBuilder var header: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title).font(.headline)
      if let subtitle {
        Text(subtitle).font(.footnote)
      }
    }
    .textCase(.none)
  }

  var body: some View {
    SwiftUI.Section(content: { content }, header: { header })
  }
}
