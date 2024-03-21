// highlight-import
import IMGLYDesignEditor
// highlight-import
import SwiftUI

class EditorUIKit: UIViewController {
  // highlight-ui-hosting-controller
  private lazy var editor = UIHostingController(rootView:
    // highlight-environment
    ModalEditor {
      // highlight-editor
      DesignEditor(.init(license: secrets.licenseKey,
                         userID: "<your unique user id>"))
      // highlight-editor
    }
    // highlight-environment
  )
  // highlight-ui-hosting-controller

  // highlight-modal
  private lazy var button = UIButton(
    type: .system,
    primaryAction: UIAction(title: "Use the Editor") { [unowned self] _ in
      editor.modalPresentationStyle = .fullScreen
      present(editor, animated: true)
    }
  )
  // highlight-modal

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
}
