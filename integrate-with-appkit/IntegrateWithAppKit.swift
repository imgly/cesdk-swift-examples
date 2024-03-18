#if os(macOS)
  import Cocoa
  // highlight-import
  import IMGLYEngine
  // highlight-import
  import MetalKit

  class IntegrateWithAppKit: NSViewController {
    // highlight-setup
    private var engine: Engine?
    private lazy var canvas = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    // highlight-setup

    private lazy var spinner = NSProgressIndicator()
    private lazy var button = NSButton(title: "Use the Engine", target: self, action: #selector(buttonClicked))

    override func loadView() {
      view = .init(frame: .init(x: 0, y: 0, width: 1000, height: 1000))
    }

    override func viewDidLoad() {
      super.viewDidLoad()

      // highlight-view
      view.addSubview(canvas)
      canvas.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
        canvas.rightAnchor.constraint(equalTo: view.rightAnchor),
        canvas.topAnchor.constraint(equalTo: view.topAnchor),
        canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
      // highlight-view

      view.addSubview(spinner)
      spinner.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      ])
      spinner.startAnimation(self)
      spinner.isDisplayedWhenStopped = false

      view.addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      ])
      button.isHidden = true
    }

    @objc func buttonClicked() {
      guard let engine else {
        return
      }
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

    // highlight-lifecycle
    override func viewDidAppear() {
      super.viewDidAppear()
      Task {
        // highlight-license
        engine = try await Engine(context: .metalView(view: canvas), license: secrets.licenseKey, userID: "guides-user")
        // highlight-license
        engine?.onAppear()
        spinner.stopAnimation(self)
        button.isHidden = false
      }
    }

    override func viewWillDisappear() {
      super.viewWillDisappear()
      engine?.onDisappear()
    }
    // highlight-lifecycle
  }
#endif
