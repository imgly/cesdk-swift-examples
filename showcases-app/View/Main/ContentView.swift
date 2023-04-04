import IMGLYApparelUI
import IMGLYEditorUI
import IMGLYPostcardUI
import SwiftUI

struct ContentView: View {
  private let title = "CE.SDK Showcases"

  @ViewBuilder var postcardUI: some View {
    SceneSelection<PostcardUI>(scenes: [
      ("Thank you", colorPalette: [
        ("Petite Orchid", .hex("#E09F96")!),
        ("White", .hex("#FFFFFF")!),
        ("Claret", .hex("#761E40")!),
        ("Kimberly", .hex("#7471A3")!),
        ("Gondola", .hex("#20121F")!),
        ("Dove Gray", .hex("#696969")!),
        ("Dusty Gray", .hex("#999999")!)
      ]),
      ("Merry Christmas", colorPalette: [
        ("Fern Frond", .hex("#536F1A")!),
        ("White", .hex("#FFFFFF")!),
        ("Metallic Copper", .hex("#6B2923")!),
        ("Fuel Yellow", .hex("#F3AE2B")!),
        ("Black Bean", .hex("#051111")!),
        ("Dove Gray", .hex("#696969")!),
        ("Dusty Gray", .hex("#999999")!)
      ]),
      ("Bonjour Paris", colorPalette: [
        ("Black", .hex("#000000")!),
        ("White", .hex("#FFFFFF")!),
        ("Purple Heart", .hex("#4932D1")!),
        ("Persimmon", .hex("#FE6755")!),
        ("Scorpion", .hex("#606060")!),
        ("Dove Gray", .hex("#696969")!),
        ("Dusty Gray", .hex("#999999")!)
      ]),
      ("Wish you were here", colorPalette: [
        ("Mandy", .hex("#E75050")!),
        ("White", .hex("#FFFFFF")!),
        ("Cod Gray", .hex("#111111")!),
        ("Shark", .hex("#282929")!),
        ("Patina", .hex("#619888")!),
        ("Dove Gray", .hex("#696969")!),
        ("Dusty Gray", .hex("#999999")!)
      ])
    ])
  }

  var body: some View {
    NavigationView {
      List {
        Section(title: "UI Types", subtitle: "UIs that fit every use case.") {
          Showcase(
            view: ApparelUI(scene: Bundle.main.url(forResource: "apparel-ui-b-1", withExtension: "scene")!),
            title: "Apparel UI",
            subtitle: "Customize and export a print-ready design with a mobile apparel editor."
          )
          Showcase(
            view: postcardUI,
            title: "Post- & Greeting-Card UI",
            subtitle: "Built to facilitate optimal card design, from changing accent colors to selecting fonts."
          )
        }
      }
      .listStyle(.sidebar)
      .navigationTitle(title)
      .toolbar {
        ToolbarItemGroup(placement: .bottomBar) {
          if !ProcessInfo.processInfo.arguments.contains("UI-Testing"),
             let branch = Bundle.main.infoDictionary?["GitBranch"] as? String,
             let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            Text("branch: " + branch + ", build: " + build)
              .font(.system(size: 10))
              .monospaced()
          }
        }
      }
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
      .nonDefaultPreviewSettings()
  }
}
