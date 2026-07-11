#if os(iOS)
  // highlight-integrateUIKit-import
  import IMGLYEngine
  import MetalKit
  import UIKit

  // highlight-integrateUIKit-import

  // highlight-integrateUIKit-canvas
  final class IntegrateWithUIKit: UIViewController {
    private var engine: Engine?
    private lazy var canvas = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    private lazy var spinner: UIActivityIndicatorView = {
      let indicator = UIActivityIndicatorView(style: .large)
      indicator.translatesAutoresizingMaskIntoConstraints = false
      indicator.hidesWhenStopped = true
      return indicator
    }()

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
      spinner.startAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
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
          spinner.stopAnimating()
        } catch {
          print("Engine setup failed: \(error)")
        }
      }
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      engine?.onDisappear()
    }
  }

  // highlight-integrateUIKit-canvas
#endif
