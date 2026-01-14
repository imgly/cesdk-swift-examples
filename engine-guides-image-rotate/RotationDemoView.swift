import IMGLYEngine
import SwiftUI

struct RotationDemoView: View {
  @State private var engine: Engine?
  @State private var imageID: DesignBlockID?
  @State private var rotation: Float = 0

  var body: some View {
    VStack(spacing: 16) {
      if let engine {
        Canvas(engine: engine)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ProgressView("Initializing engine…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }

      Spacer()

      VStack(spacing: 12) {
        HStack {
          Button("-15°") { rotate(byDegrees: -15) }
          Spacer()
          Button("Reset") { setRotation(0) }
          Spacer()
          Button("+15°") { rotate(byDegrees: 15) }
        }

        Text("Rotation: \(rotation, specifier: "%.2f") rad")
          .font(.caption)
          .foregroundColor(.secondary)
        Slider(value: Binding(
          get: { Double(rotation) },
          set: { setRotation(Float($0)) },
        ), in: -Double.pi ... Double.pi)
      }
      .padding()
    }
    .onAppear { Task { await setupScene() } }
  }

  // MARK: - Setup

  func setupScene() async {
    do {
      engine = try await Engine(license: "your license key")
      guard let engine else { return }

      let scene = try engine.scene.create()
      let page = try engine.block.create(.page)
      try engine.block.appendChild(to: scene, child: page)

      let image = try engine.block.create(.graphic)
      let shape = try engine.block.createShape(.rect)
      try engine.block.setShape(image, shape: shape)

      let fill = try engine.block.createFill(.image)
      try engine.block.setString(
        fill,
        property: "fill/image/imageFileURI",
        value: "https://img.ly/static/ubq_samples/sample_4.jpg",
      )
      try engine.block.setFill(image, fill: fill)
      try engine.block.appendChild(to: page, child: image)

      try await engine.scene.zoom(to: image)

      imageID = image

      // This is so if the user taps the image and rotates it with the gizmo
      // the UI will update. It's not rotation specific, but it polishes the UI.
      watchRotation()
    } catch {
      print("Setup failed:", error)
    }
  }

  // MARK: - Rotation Helpers

  func setRotation(_ value: Float) {
    guard let engine, let imageID else { return }
    do {
      rotation = value
      try engine.block.setRotation(imageID, radians: value)
    } catch {
      print("Rotation failed:", error)
    }
  }

  func rotate(byDegrees degrees: Double) {
    let radians = degreesToRadians(degrees)
    setRotation(rotation + radians)
  }

  func degreesToRadians(_ degrees: Double) -> Float {
    Float(degrees * .pi / 180)
  }

  // Event subscription
  // Learn about events at https://img.ly/docs/cesdk/ios/concepts/events-353f97/
  func watchRotation() {
    guard let engine, let imageID else { return }

    Task {
      for await events in engine.event.subscribe(to: [imageID]) {
        // Look for updates to this specific block
        guard events.contains(where: { $0.type == .updated && $0.block == imageID }) else {
          continue
        }

        // Read the updated rotation value from the engine and update the UI
        // this will fire on _all_ updates, not just rotation
        if let newValue = try? engine.block.getRotation(imageID) {
          rotation = newValue
        }
      }
    }
  }
}
