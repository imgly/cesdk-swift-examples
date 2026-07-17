// highlight-uikit-import
import IMGLYCamera

// highlight-uikit-import
import SwiftUI

class CameraUIKit: UIViewController {
  private var camera: UIViewController {
    // highlight-uikit-hosting
    UIHostingController(rootView:
      // highlight-uikit-initialization
      Camera(.init(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                   userID: "<your unique user id>")) { result in
        // highlight-uikit-initialization
        // highlight-uikit-result
        switch result {
        case let .success(.capture(captures)):
          for capture in captures {
            switch capture {
            case let .photo(photo):
              if let url = photo.images.first?.url {
                print("Captured photo: \(url)")
              }
            case let .video(recording):
              print("Recorded videos: \(recording.videos.map(\.url))")
            }
          }

        case .success(.reaction):
          print("Reaction case not handled here")

        case let .failure(error):
          print(error.localizedDescription)
        }
        self.presentedViewController?.dismiss(animated: true)
        // highlight-uikit-result
      })
    // highlight-uikit-hosting
  }

  // highlight-uikit-modal
  private lazy var button = UIButton(
    type: .system,
    primaryAction: UIAction(title: "Use the Camera") { [unowned self] _ in
      let camera = camera
      camera.modalPresentationStyle = .fullScreen
      present(camera, animated: true)
    },
  )
  // highlight-uikit-modal

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
