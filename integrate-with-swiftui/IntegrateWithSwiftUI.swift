// highlight-import
import IMGLYEngine
// highlight-import
import SwiftUI

struct IntegrateWithSwiftUI: View {
  @State private var engine: Engine?

  var body: some View {
    // highlight-setup
    Group {
      if let engine {
        ContentView(engine: engine)
      } else {
        ProgressView()
      }
    }
    .onAppear {
      Task {
        engine = try await Engine(license: secrets.licenseKey, userID: "guides-user")
      }
    }
    // highlight-setup
  }
}

// highlight-view
struct ContentView: View {
  @StateObject private var engine: Engine

  init(engine: Engine) {
    _engine = .init(wrappedValue: engine)
  }

  var body: some View {
    ZStack {
      Canvas(engine: engine)
      Button("Use the Engine") {
        // highlight-work
        Task {
          let url = URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
          try await engine.scene.load(from: url)

          try engine.block.find(byType: .text).forEach { id in
            try engine.block.setOpacity(id, value: 0.5)
          }
        }
        // highlight-work
      }
    }
  }
}

// highlight-view
