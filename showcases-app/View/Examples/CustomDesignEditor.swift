import IMGLYDesignEditor
import SwiftUI

struct CustomDesignEditor: View {
  var body: some View {
    let url = Bundle.main.url(forResource: "template_01_ig_post_1_1", withExtension: "scene")!
    DesignEditor(settings)
      .customEditorConfiguration(scene: url)
  }
}
