import IMGLYEditor
import SwiftUI
import UIKit

// highlight-navigation-swiftui
struct EditorNavigationContainerSwiftUI: View {
  let engineSettings = EngineSettings(
    license: secrets.licenseKey, // pass nil for evaluation mode with watermark
    userID: "<your unique user id>",
  )

  var body: some View {
    NavigationStack {
      Editor(engineSettings)
        .imgly.configuration { DesignEditorConfiguration() }
    }
  }
}

// highlight-navigation-swiftui

class EditorNavigationContainerUIKit: UIViewController {
  let engineSettings = EngineSettings(
    license: secrets.licenseKey, // pass nil for evaluation mode with watermark
    userID: "<your unique user id>",
  )

  // highlight-navigation-uikit
  func presentEditor() {
    let editor = NavigationStack {
      Editor(engineSettings)
        .imgly.configuration { DesignEditorConfiguration() }
    }
    let editorVC = UIHostingController(rootView: editor)
    editorVC.modalPresentationStyle = .fullScreen
    present(editorVC, animated: true)
  }
  // highlight-navigation-uikit
}
