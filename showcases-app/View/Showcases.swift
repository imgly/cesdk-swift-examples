import IMGLYApparelEditor
import IMGLYPostcardEditor
import SwiftUI

struct Showcases: View {
  @State var mode = ShowcaseMode.navigationLink

  @ViewBuilder var showcases: some View {
    Section(title: "Apparel Editor",
            subtitle: "Customize and export a print-ready design with a mobile apparel editor.") {
      Showcase(
        view: ApparelEditor(settings),
        title: "Default Apparel Editor",
        subtitle: "Loads empty apparel scene."
      )
      Showcase(
        view: CustomApparelEditor(),
        title: "Custom Apparel Editor",
        subtitle: "Loads custom apparel scene and adds Unsplash asset source and library."
      )
    }
    Section(title: "Post- & Greeting-Card Editor",
            subtitle: "Built to facilitate optimal card design, from changing accent colors to selecting fonts.") {
      Showcase(
        view: PostcardEditor(settings),
        title: "Default Postcard Editor",
        subtitle: "Loads empty postcard scene."
      )
      Showcase(
        view: CustomPostcardEditor().showcaseMode(mode),
        title: "Custom Postcard Editor",
        subtitle: "Custom postcard scene selection and adds Unsplash asset source and library."
      ).showcaseMode(.navigationLink)
    }
  }

  var body: some View {
    SwiftUI.Section("Settings") {
      Picker("Presentation Mode", selection: $mode) {
        ForEach(ShowcaseMode.allCases) {
          Text(LocalizedStringKey(String(describing: $0)))
        }
      }
    }
    showcases
      .showcaseMode(mode)
  }
}
