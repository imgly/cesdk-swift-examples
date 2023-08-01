// highlight-import
import IMGLYEngine
// highlight-import
import MetalKit
import UIKit

class IntegrateWithUIKit: UIViewController {
  // highlight-setup
  private lazy var engine = Engine(context: .metalView(view: canvas))
  private lazy var canvas = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
  // highlight-setup

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

    let button = UIButton(type: .system, primaryAction: UIAction(title: "Use the engine", handler: { [unowned self] _ in
      // highlight-work
      Task {
        _ = try? await self.engine.scene
          .load(
            fromURL: .init(
              string: "https://cdn.img.ly/assets/demo/v1/ly.img.template/templates/cesdk_postcard_1.scene"
            )!
          )

        try? self.engine.block.find(byType: .text).forEach { id in
          try? self.engine.block.setOpacity(id, value: 0.5)
        }
      }
      // highlight-work
    }))

    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  // highlight-lifecycle
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    engine.onAppear()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    engine.onDisappear()
  }
  // highlight-lifecycle
}
