import IMGLYDesignEditor
import SwiftUI

struct CustomDesignEditor: View {
  var body: some View {
    DesignEditor(settings)
      .customEditorConfiguration(scene: DesignEditor.defaultScene)
  }
}
