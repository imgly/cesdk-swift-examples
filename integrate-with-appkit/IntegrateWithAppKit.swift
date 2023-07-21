#if os(macOS)
  import Cocoa
  // highlight-import
  import IMGLYEngine
  // highlight-import
  import MetalKit

  class IntegrateWithAppKit: NSViewController {
    // highlight-setup
    private lazy var engine = Engine(context: .metalView(view: canvas))
    private lazy var canvas = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    // highlight-setup

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

      let button = NSButton(title: "Use the engine", target: self, action: #selector(buttonClicked))
      view.addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      ])
    }

    @objc func buttonClicked() {
      // highlight-work
      Task {
        let url = URL(string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene")!
        try? await engine.scene.load(from: url)

        try? self.engine.block.find(byType: .text).forEach { id in
          try? self.engine.block.setOpacity(id, value: 0.5)
        }
      }
      // highlight-work
    }

    // highlight-lifecycle
    override func viewDidAppear() {
      super.viewDidAppear()
      engine.onAppear()
    }

    override func viewWillDisappear() {
      super.viewWillDisappear()
      engine.onDisappear()
    }
    // highlight-lifecycle
  }
#endif
