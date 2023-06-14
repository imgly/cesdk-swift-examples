import IMGLYCore
import SwiftUI

@main
struct ShowcasesApp: App {
  @Environment(\.scenePhase) var scenePhase

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .onChange(of: scenePhase) { _ in
      if ProcessInfo.isUITesting,
         let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
         let window = scene.windows.first {
        window.layer.speed = 100
      }
    }
  }
}
