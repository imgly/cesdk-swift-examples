import ApparelUI
import SwiftUI

private struct Section<Content: View>: View {
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

private struct Showcase<Content: View>: View {
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

struct ContentView: View {
  private let title = "CE.SDK Showcases"

  var body: some View {
    NavigationView {
      List {
        Section(title: "UI Types", subtitle: "UIs that fit every use case.") {
          Showcase(
            view: ApparelUI.ContentView(),
            title: "Apparel UI",
            subtitle: "Customize and export a print-ready design with a mobile apparel editor."
          )
        }
      }
      .listStyle(.sidebar)
      .navigationTitle(title)
    }
    // Currently, IMGLYEngine.Engine does not support multiple instances.
    // `StackNavigationViewStyle` forces to deinitialize the view and thus its engine when exiting a showcase.
    .navigationViewStyle(.stack)
    .accessibilityIdentifier("showcases")
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
    ContentView()
      .previewInterfaceOrientation(.landscapeRight)
      .preferredColorScheme(.dark)
      .environment(\.layoutDirection, .rightToLeft)
  }
}
