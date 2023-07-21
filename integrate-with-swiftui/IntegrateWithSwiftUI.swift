// highlight-import
import IMGLYEngine
// highlight-import
import SwiftUI

struct IntegrateWithSwiftUI: View {
  // highlight-setup
  @StateObject private var engine = Engine()
  // highlight-setup

  var body: some View {
    ZStack {
      // highlight-view
      Canvas(engine: engine)
      // highlight-view
      Button("Use the engine") {
        // highlight-work
        Task {
          let url = URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
          try? await engine.scene.load(from: url)

          try? engine.block.find(byType: .text).forEach { id in
            try? engine.block.setOpacity(id, value: 0.5)
          }
        }
        // highlight-work
      }
    }
  }
}
