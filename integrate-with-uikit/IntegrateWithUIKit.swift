#if os(iOS)
  // highlight-import
  import IMGLYEngine
  // highlight-import
  import MetalKit
  import UIKit

  class IntegrateWithUIKit: UIViewController {
    // highlight-setup
    private var engine: Engine?
    private lazy var canvas = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    // highlight-setup

    private lazy var spinner = UIActivityIndicatorView()
    private lazy var button = UIButton(
      type: .system,
      primaryAction: UIAction(title: "Use the Engine", handler: { [unowned self] _ in
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
      })
    )

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
      spinner.startAnimating()
      spinner.hidesWhenStopped = true

      view.addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      ])
      button.isHidden = true
    }

    // highlight-lifecycle
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      Task {
        // highlight-license
        engine = try await Engine(
          context: .metalView(view: canvas),
          license: secrets.licenseKey,
          userID: "<your unique user id>"
        )
        // highlight-license
        engine?.onAppear()
        spinner.stopAnimating()
        button.isHidden = false
      }
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      engine?.onDisappear()
    }
    // highlight-lifecycle
  }
#endif
