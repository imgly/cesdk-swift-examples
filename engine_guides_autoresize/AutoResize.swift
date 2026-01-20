import IMGLYEngine // Canvas + Engine
import SwiftUI

struct AutoResizeDemo: View {
  @State private var engine: Engine?
  @State private var page: DesignBlockID?
  @State private var backgroundBlock: DesignBlockID?

  @State private var useFillParent = true
  @State private var wPercent = 1.0
  @State private var hPercent = 1.0

  @State private var frameWidth: Float = 0
  @State private var frameHeight: Float = 0

  var body: some View {
    VStack(spacing: 12) {
      if let engine {
        Canvas(engine: engine)
          .frame(maxWidth: .infinity, maxHeight: 320)
          .background(Color.black.opacity(0.06))
          .clipShape(RoundedRectangle(cornerRadius: 12))
      } else {
        ProgressView("Initializing engine…")
      }

      Toggle("Use fillParent()", isOn: $useFillParent)
        .onChange(of: useFillParent) { _, _ in
          applySizing()
        }

      if !useFillParent {
        HStack {
          Text("Width")
          Slider(value: $wPercent, in: 0 ... 1, step: 0.05) { _ in applySizing() }
          Text("\(Int(wPercent * 100))%").monospaced()
        }
        HStack {
          Text("Height")
          Slider(value: $hPercent, in: 0 ... 1, step: 0.05) { _ in applySizing() }
          Text("\(Int(hPercent * 100))%").monospaced()
        }
      }

      HStack {
        Text("Computed Size:")
        Text("\(Int(frameWidth)) × \(Int(frameHeight)) px").monospaced()
      }
      .font(.callout)

      Spacer(minLength: 0)
    }
    .padding()
    .task {
      await setupScene()
    }
  }

  func setupScene() async {
    do {
      engine = try await Engine(
        license: "<your license key>",
      )
      guard let engine else { return }

      let scene = try engine.scene.create()
      let page = try engine.block.create(.page)
      self.page = page

      try engine.block.appendChild(to: scene, child: page)

      let bg = try engine.block.create(.graphic)
      let shape = try engine.block.createShape(.rect)
      try engine.block.setShape(bg, shape: shape)
      let solidColor = try engine.block.createFill(.color)
      try engine.block.setFill(bg, fill: solidColor)

      let rgbaGreen = Color.rgba(r: 0.5, g: 1, b: 0.5, a: 1)
      try engine.block.setColor(solidColor, property: "fill/color/value", color: rgbaGreen)
      try engine.block.appendChild(to: page, child: bg)
      try engine.block.sendToBack(bg)
      backgroundBlock = bg

      try engine.block.fillParent(bg)
      try await engine.scene.zoom(to: scene)
      Task { await refreshComputedSize() }
    } catch {
      print("Setup error: \(error)")
    }
  }

  func applySizing() {
    guard let engine, let backgroundBlock else { return }
    do {
      if useFillParent {
        try engine.block.fillParent(backgroundBlock)
      } else {
        try engine.block.setWidthMode(backgroundBlock, mode: .percent)
        try engine.block.setHeightMode(backgroundBlock, mode: .percent)
        try engine.block.setWidth(backgroundBlock, value: Float(wPercent))
        try engine.block.setHeight(backgroundBlock, value: Float(hPercent))
      }

      Task { await refreshComputedSize() }

    } catch {
      print("Sizing error: \(error)")
    }
  }

  func refreshComputedSize() async {
    await Task.yield()
    guard let engine, let backgroundBlock else { return }
    do {
      frameWidth = try engine.block.getFrameWidth(backgroundBlock)
      frameHeight = try engine.block.getFrameHeight(backgroundBlock)
    } catch {
      print("Read frame error: \(error)")
    }
  }
}
