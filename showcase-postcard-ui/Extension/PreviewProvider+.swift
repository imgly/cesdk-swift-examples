import IMGLYEditorUI
import SwiftUI

extension PreviewProvider {
  private static var url: URL { Bundle.main.url(forResource: "thank_you", withExtension: "scene")! }

  @ViewBuilder static var postcardUI: some View {
    NavigationView {
      PostcardUI(scene: Self.url)
    }
  }

  @ViewBuilder static var defaultPreviews: some View {
    Group {
      postcardUI
      postcardUI.nonDefaultPreviewSettings()
    }
    .navigationViewStyle(.stack)
  }
}
