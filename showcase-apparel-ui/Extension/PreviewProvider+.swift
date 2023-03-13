import IMGLYEditorUI
import SwiftUI

extension PreviewProvider {
  private static var url: URL { Bundle.main.url(forResource: "apparel-ui-b-1-default", withExtension: "scene")! }

  @ViewBuilder static var apparelUI: some View {
    NavigationView {
      ApparelUI(scene: Self.url)
    }
  }

  @ViewBuilder static var defaultPreviews: some View {
    Group {
      apparelUI
      apparelUI.nonDefaultPreviewSettings()
    }
    .navigationViewStyle(.stack)
  }
}
