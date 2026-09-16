// highlight-integrateSwiftUI-import
import IMGLYEngine
import SwiftUI

// highlight-integrateSwiftUI-import

// highlight-integrateSwiftUI-canvas
struct IntegrateWithSwiftUI: View {
  @State private var engine: Engine?

  var body: some View {
    Group {
      if let engine {
        Canvas(engine: engine)
      } else {
        ProgressView("Starting the engine…")
      }
    }
    .onAppear {
      guard engine == nil else { return }
      Task {
        do {
          let engine = try await Engine(
            license: secrets.licenseKey, // pass nil for evaluation mode with watermark
            userID: "<your unique user id>",
          )
          let scene = try engine.scene.create()
          let page = try engine.block.create(.page)
          try engine.block.setWidth(page, value: 800)
          try engine.block.setHeight(page, value: 600)
          try engine.block.appendChild(to: scene, child: page)

          let text = try engine.block.create(.text)
          try engine.block.setString(text, property: "text/text", value: "Hello, CE.SDK!")
          try engine.block.setPositionX(text, value: 80)
          try engine.block.setPositionY(text, value: 260)
          try engine.block.setWidth(text, value: 640)
          try engine.block.appendChild(to: page, child: text)

          try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)
          self.engine = engine
        } catch {
          print("Engine setup failed: \(error)")
        }
      }
    }
  }
}

// highlight-integrateSwiftUI-canvas

#if DEBUG
  // Live preview that boots a real engine so the file can be exercised inside
  // Xcode without launching a host app. Requires Xcode 15+.
  @available(iOS 17, macOS 14, *)
  #Preview {
    IntegrateWithSwiftUI()
  }
#endif
