// highlight-import
import IMGLYCamera
// highlight-import
import SwiftUI

class CameraUIKit: UIViewController {
  // highlight-ui-hosting-controller
  private lazy var camera = UIHostingController(rootView:
    // highlight-initialization
    Camera(.init(license: secrets.licenseKey,
                 userID: "<your unique user id>")) { result in
      // highlight-initialization
      // highlight-result
      switch result {
      case let .success(recordings):
        let urls = recordings.flatMap { $0.videos.map(\.url) }
        let recordedVideos = urls
        // Do something with the recorded videos
        print(recordedVideos)
      case let .failure(error):
        print(error.localizedDescription)
        self.presentedViewController?.dismiss(animated: true)
      }
      // highlight-result
    })
  // highlight-ui-hosting-controller

  // highlight-modal
  private lazy var button = UIButton(
    type: .system,
    primaryAction: UIAction(title: "Use the Camera") { [unowned self] _ in
      camera.modalPresentationStyle = .fullScreen
      present(camera, animated: true)
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
