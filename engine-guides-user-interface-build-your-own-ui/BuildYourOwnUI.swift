import Foundation
import IMGLYEngine
import SwiftUI

// MARK: - View-model — drives the demo UI and every highlight block

// highlight-buildYourOwnUI-viewModel
@MainActor
final class BuildYourOwnUIViewModel: ObservableObject {
  @Published private(set) var selectedBlockID: DesignBlockID?
  @Published private(set) var selectedType: String?
  @Published var positionX: Float = 0
  @Published var positionY: Float = 0
  @Published var width: Float = 0
  @Published var height: Float = 0
  @Published var rotationDegrees: Float = 0

  let engine: Engine
  private var pageID: DesignBlockID?
  private var eventTask: Task<Void, Never>?

  init(engine: Engine) {
    self.engine = engine
  }

  deinit { eventTask?.cancel() }

  // highlight-buildYourOwnUI-viewModel

  // highlight-buildYourOwnUI-setup
  func setupScene() async {
    do {
      let scene = try engine.scene.create()
      let page = try engine.block.create(.page)
      try engine.block.setWidth(page, value: 800)
      try engine.block.setHeight(page, value: 600)
      try engine.block.appendChild(to: scene, child: page)
      pageID = page

      try createInitialContent(on: page)
      try await engine.scene.zoom(
        to: page,
        paddingLeft: 40,
        paddingTop: 40,
        paddingRight: 40,
        paddingBottom: 40,
      )
      startEventLoop()
    } catch {
      print("Scene setup failed: \(error)")
    }
  }

  // highlight-buildYourOwnUI-setup

  // highlight-buildYourOwnUI-createInitialContent
  private func createInitialContent(on page: DesignBlockID) throws {
    let textBlock = try engine.block.create(.text)
    try engine.block.setString(textBlock, property: "text/text", value: "Click to Edit")
    try engine.block.setPositionX(textBlock, value: 80)
    try engine.block.setPositionY(textBlock, value: 80)
    try engine.block.setWidth(textBlock, value: 300)
    try engine.block.setHeight(textBlock, value: 80)
    try engine.block.appendChild(to: page, child: textBlock)

    let shapeBlock = try engine.block.create(.graphic)
    try engine.block.setShape(shapeBlock, shape: engine.block.createShape(.rect))
    let fill = try engine.block.createFill(.color)
    try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.6, b: 0.9, a: 1))
    try engine.block.setFill(shapeBlock, fill: fill)
    try engine.block.setPositionX(shapeBlock, value: 450)
    try engine.block.setPositionY(shapeBlock, value: 200)
    try engine.block.setWidth(shapeBlock, value: 150)
    try engine.block.setHeight(shapeBlock, value: 150)
    try engine.block.appendChild(to: page, child: shapeBlock)

    try engine.block.select(textBlock)
  }

  // highlight-buildYourOwnUI-createInitialContent

  // highlight-buildYourOwnUI-handleEvents
  private func startEventLoop() {
    // Capture `engine` and reference `self` weakly: a strong `self` held across
    // the `for await` suspension would retain the view-model and its engine for
    // the lifetime of the subscription.
    eventTask = Task { [weak self, engine] in
      for await events in engine.event.subscribe(to: []) {
        self?.refreshSelection(from: events)
      }
    }
  }

  private func refreshSelection(from _: [BlockEvent]) {
    let selected = engine.block.findAllSelected().first
    selectedBlockID = selected
    guard let selected, engine.block.isValid(selected) else {
      selectedType = nil
      return
    }
    do {
      selectedType = try engine.block.getType(selected)
      positionX = try engine.block.getPositionX(selected)
      positionY = try engine.block.getPositionY(selected)
      width = try engine.block.getWidth(selected)
      height = try engine.block.getHeight(selected)
      rotationDegrees = try engine.block.getRotation(selected) * 180 / .pi
    } catch {
      selectedType = nil
    }
  }

  // highlight-buildYourOwnUI-handleEvents

  // highlight-buildYourOwnUI-addBlocks
  func addText() {
    guard let pageID else { return }
    do {
      let textBlock = try engine.block.create(.text)
      try engine.block.setString(textBlock, property: "text/text", value: "Lorem ipsum dolor sit amet")
      try engine.block.setPositionX(textBlock, value: 80)
      try engine.block.setPositionY(textBlock, value: 80)
      try engine.block.setWidth(textBlock, value: 300)
      try engine.block.setHeight(textBlock, value: 100)
      try engine.block.appendChild(to: pageID, child: textBlock)
      try engine.block.select(textBlock)
    } catch {
      print("Add text failed: \(error)")
    }
  }

  func addShape() {
    guard let pageID else { return }
    do {
      let shapeBlock = try engine.block.create(.graphic)
      try engine.block.setShape(shapeBlock, shape: engine.block.createShape(.rect))
      let fill = try engine.block.createFill(.color)
      try engine.block.setColor(fill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.6, b: 0.9, a: 1))
      try engine.block.setFill(shapeBlock, fill: fill)
      try engine.block.setPositionX(shapeBlock, value: 80)
      try engine.block.setPositionY(shapeBlock, value: 80)
      try engine.block.setWidth(shapeBlock, value: 150)
      try engine.block.setHeight(shapeBlock, value: 150)
      try engine.block.appendChild(to: pageID, child: shapeBlock)
      try engine.block.select(shapeBlock)
    } catch {
      print("Add shape failed: \(error)")
    }
  }

  // highlight-buildYourOwnUI-addBlocks

  // highlight-buildYourOwnUI-propertyPanel
  func setPositionX(_ value: Float) {
    guard let id = selectedBlockID else { return }
    try? engine.block.setPositionX(id, value: value)
  }

  func setPositionY(_ value: Float) {
    guard let id = selectedBlockID else { return }
    try? engine.block.setPositionY(id, value: value)
  }

  func setWidth(_ value: Float) {
    guard let id = selectedBlockID else { return }
    try? engine.block.setWidth(id, value: value)
  }

  func setHeight(_ value: Float) {
    guard let id = selectedBlockID else { return }
    try? engine.block.setHeight(id, value: value)
  }

  func setRotationDegrees(_ value: Float) {
    guard let id = selectedBlockID else { return }
    try? engine.block.setRotation(id, radians: value * .pi / 180)
  }

  // highlight-buildYourOwnUI-propertyPanel

  // highlight-buildYourOwnUI-export
  func export() async -> Data? {
    guard let pageID else { return nil }
    return try? await engine.block.export(pageID, mimeType: .png)
  }
  // highlight-buildYourOwnUI-export
}

// MARK: - The view — Canvas on top, controls below

// highlight-buildYourOwnUI-view
struct BuildYourOwnUIView: View {
  @StateObject private var viewModel: BuildYourOwnUIViewModel

  init(engine: Engine) {
    _viewModel = StateObject(wrappedValue: BuildYourOwnUIViewModel(engine: engine))
  }

  var body: some View {
    VStack(spacing: 0) {
      Canvas(engine: viewModel.engine)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      Divider()
      controls
        .padding()
        .background(Color(white: 0.95))
    }
    .onAppear {
      Task { await viewModel.setupScene() }
    }
  }

  // highlight-buildYourOwnUI-view

  // highlight-buildYourOwnUI-uiControls
  private var controls: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Button("Add Text") { viewModel.addText() }
        Button("Add Shape") { viewModel.addShape() }
        Spacer()
        Button("Export PNG") {
          Task { _ = await viewModel.export() }
        }
      }

      if viewModel.selectedBlockID != nil {
        Text("Selected: \(viewModel.selectedType ?? "—")")
          .font(.caption)
          .foregroundColor(.secondary)

        propertyRow("X", value: $viewModel.positionX, in: 0 ... 800, onChange: viewModel.setPositionX)
        propertyRow("Y", value: $viewModel.positionY, in: 0 ... 600, onChange: viewModel.setPositionY)
        propertyRow("W", value: $viewModel.width, in: 1 ... 800, onChange: viewModel.setWidth)
        propertyRow("H", value: $viewModel.height, in: 1 ... 600, onChange: viewModel.setHeight)
        propertyRow(
          "Rot°",
          value: $viewModel.rotationDegrees,
          in: -180 ... 180,
          onChange: viewModel.setRotationDegrees,
        )
      } else {
        Text("Tap a block on the canvas to edit its properties.")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
  }

  private func propertyRow(
    _ label: String,
    value: Binding<Float>,
    in range: ClosedRange<Float>,
    onChange: @escaping (Float) -> Void,
  ) -> some View {
    HStack {
      Text(label).font(.caption).frame(width: 36, alignment: .leading)
      Slider(value: value, in: range) { editing in
        if !editing { onChange(value.wrappedValue) }
      }
      Text("\(Int(value.wrappedValue))")
        .font(.caption.monospacedDigit())
        .frame(width: 44, alignment: .trailing)
    }
  }
  // highlight-buildYourOwnUI-uiControls
}

// MARK: - Minimal Canvas host used in "Initialize Engine and Setup Canvas"

// highlight-buildYourOwnUI-canvasView
struct MinimalCanvasView: View {
  @State private var engine: Engine?

  var body: some View {
    Group {
      if let engine {
        Canvas(engine: engine)
      } else {
        ProgressView("Initializing engine…")
      }
    }
    .onAppear {
      Task {
        engine = try? await Engine(
          license: secrets.licenseKey, // pass nil for evaluation mode with watermark
          userID: "<your unique user id>",
        )
      }
    }
  }
}

// highlight-buildYourOwnUI-canvasView

// MARK: - UIKit and AppKit hosts — for apps that own their own MTKView

#if canImport(UIKit) && !os(watchOS)
  import MetalKit
  import UIKit

  // highlight-buildYourOwnUI-uikitHost
  final class BuildYourOwnUIController: UIViewController {
    private var engine: Engine?
    private lazy var canvas = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())

    override func viewDidLoad() {
      super.viewDidLoad()
      view.addSubview(canvas)
      canvas.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
        canvas.rightAnchor.constraint(equalTo: view.rightAnchor),
        canvas.topAnchor.constraint(equalTo: view.topAnchor),
        canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      Task {
        engine = try await Engine(
          context: .metalView(view: canvas),
          license: secrets.licenseKey, // pass nil for evaluation mode with watermark
          userID: "<your unique user id>",
        )
        engine?.onAppear()
      }
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      engine?.onDisappear()
    }
  }
  // highlight-buildYourOwnUI-uikitHost
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  import AppKit
  import MetalKit

  // highlight-buildYourOwnUI-appkitHost
  final class BuildYourOwnUIControllerMac: NSViewController {
    private var engine: Engine?
    private lazy var canvas = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())

    override func loadView() {
      view = NSView(frame: .init(x: 0, y: 0, width: 1000, height: 700))
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      view.addSubview(canvas)
      canvas.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
        canvas.rightAnchor.constraint(equalTo: view.rightAnchor),
        canvas.topAnchor.constraint(equalTo: view.topAnchor),
        canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
    }

    override func viewDidAppear() {
      super.viewDidAppear()
      Task {
        engine = try await Engine(
          context: .metalView(view: canvas),
          license: secrets.licenseKey, // pass nil for evaluation mode with watermark
          userID: "<your unique user id>",
        )
        engine?.onAppear()
      }
    }

    override func viewWillDisappear() {
      super.viewWillDisappear()
      engine?.onDisappear()
    }
  }
  // highlight-buildYourOwnUI-appkitHost
#endif

// MARK: - #Preview — boot a real engine in evaluation mode

#if DEBUG
  /// Live preview that boots a real engine in evaluation mode so the file
  /// can be exercised inside Xcode without launching a host app.
  /// Requires Xcode 15+ for the `#Preview` macro.
  @available(iOS 17, macOS 14, *)
  #Preview {
    BuildYourOwnUIPreview()
  }

  /// `#Preview` bodies cannot host async initialization directly on the
  /// iOS 14 / macOS 11 deployment targets the package supports, so the
  /// preview body uses `.onAppear` instead of `.task`.
  private struct BuildYourOwnUIPreview: View {
    @State private var engine: Engine?

    var body: some View {
      Group {
        if let engine {
          BuildYourOwnUIView(engine: engine)
        } else {
          ProgressView("Booting engine…")
        }
      }
      .onAppear {
        Task {
          engine = try? await Engine(
            license: nil, // evaluation mode with watermark — fine for previews
            userID: "<your unique user id>",
          )
        }
      }
    }
  }
#endif

// MARK: - Test-runnable entry point

/// Drives every code path that `BuildYourOwnUIView` exercises against a
/// shared offscreen test engine — `setupScene`, the event loop, intent
/// methods on the view-model, and the export call. Verifies that the
/// rendered guide's highlights stay runtime-correct without spinning up
/// a SwiftUI view.
@MainActor
func buildYourOwnUI(engine: Engine) async throws {
  let viewModel = BuildYourOwnUIViewModel(engine: engine)
  await viewModel.setupScene()

  viewModel.addText()
  viewModel.addShape()

  viewModel.setPositionX(120)
  viewModel.setPositionY(140)
  viewModel.setRotationDegrees(15)

  let png = await viewModel.export()
  print("Exported \(png?.count ?? 0) bytes")
}
