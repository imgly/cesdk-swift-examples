// highlight-import
import IMGLYCamera

// highlight-import
import SwiftUI

class CameraUIKit: UIViewController {
  private var camera: UIViewController {
    // highlight-ui-hosting-controller
    UIHostingController(rootView:
      // highlight-initialization
      Camera(.init(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>")) { result in
        // highlight-initialization
        // highlight-result
        switch result {
        case let .success(.capture(captures)):
          // Do something with the captured photos and videos
          let recordedVideos = captures.videos.flatMap { $0.videos.map(\.url) }
          print(recordedVideos)
          print(captures)

        case .success(.reaction):
          print("Reaction case not handled here")

        case let .failure(error):
          print(error.localizedDescription)
          self.presentedViewController?.dismiss(animated: true)
        }
        // highlight-result
      })
    // highlight-ui-hosting-controller
  }

  // highlight-modal
  private lazy var button = UIButton(
    type: .system,
    primaryAction: UIAction(title: "Use the Camera") { [unowned self] _ in
      let camera = camera
      camera.modalPresentationStyle = .fullScreen
      present(camera, animated: true)
    },
  )
  // highlight-modal

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }
}
