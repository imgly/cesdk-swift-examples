#if os(macOS)
  // highlight-integrateAppKit-import
  import AppKit
  import IMGLYEngine
  import MetalKit

  // highlight-integrateAppKit-import

  // highlight-integrateAppKit-canvas
  final class IntegrateWithAppKit: NSViewController {
    private var engine: Engine?
    private lazy var canvas = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    private lazy var spinner: NSProgressIndicator = {
      let indicator = NSProgressIndicator()
      indicator.style = .spinning
      indicator.translatesAutoresizingMaskIntoConstraints = false
      return indicator
    }()

    override func loadView() {
      view = NSView(frame: .init(x: 0, y: 0, width: 1000, height: 1000))
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

      view.addSubview(spinner)
      NSLayoutConstraint.activate([
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      ])
      spinner.startAnimation(nil)
    }

    override func viewDidAppear() {
      super.viewDidAppear()
      guard engine == nil else { return }
      Task {
        do {
          let engine = try await Engine(
            context: .metalView(view: canvas),
            license: secrets.licenseKey, // pass nil for evaluation mode with watermark
            userID: "<your unique user id>",
          )
          engine.onAppear()

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
          spinner.stopAnimation(nil)
          spinner.isHidden = true
        } catch {
          print("Engine setup failed: \(error)")
        }
      }
    }

    override func viewWillDisappear() {
      super.viewWillDisappear()
      engine?.onDisappear()
    }
  }

  // highlight-integrateAppKit-canvas
#endif
