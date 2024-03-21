import IMGLYDesignEditor
import SwiftUI

struct CustomDesignEditor: View {
  var body: some View {
    let url = Bundle.main.url(forResource: "booklet", withExtension: "scene")!
    DesignEditor(settings)
      .customEditorConfiguration(scene: url)
  }
}
